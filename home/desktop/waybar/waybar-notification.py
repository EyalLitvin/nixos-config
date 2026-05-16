import json
import os
import re
import subprocess
import sys
import threading

ALLOWED = {"waybar-notify"}
MAX_WIDTH = 12          # characters always reserved in the bar
STATIC_SECS = 10.0     # how long a notification stays visible
HISTORY_FILE = os.path.expanduser("~/.local/state/waybar-notifications.json")
MAX_HISTORY = 50
MATCH = (
    "type=method_call,"
    "interface=org.freedesktop.Notifications,"
    "member=Notify"
)

_lock = threading.Lock()
_wake = threading.Event()
_thread = None
_current = ("", "")


def pad(text):
    """Return exactly MAX_WIDTH chars: truncate with … or right-pad."""
    if len(text) <= MAX_WIDTH:
        return text.ljust(MAX_WIDTH)
    return text[:MAX_WIDTH - 1] + "…"


def emit(text, tooltip=""):
    data = {"text": pad(text)}
    if tooltip:
        data["tooltip"] = tooltip
    sys.stdout.write(json.dumps(data) + "\n")
    sys.stdout.flush()


def display_loop():
    while True:
        _wake.clear()
        with _lock:
            summary, body = _current
        tooltip = f"{summary}\n{body}" if body else summary
        emit(summary, tooltip)
        if _wake.wait(timeout=STATIC_SECS):
            continue  # a new notification interrupted — loop again
        emit(" " * MAX_WIDTH)  # clear after timeout
        return


def save_history(summary, body):
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    try:
        with open(HISTORY_FILE) as f:
            history = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        history = []
    history.insert(0, {"summary": summary, "body": body})
    history = history[:MAX_HISTORY]
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f)


def handle(app_name, summary, body):
    global _thread, _current
    if app_name not in ALLOWED:
        return
    save_history(summary, body)
    with _lock:
        _current = (summary, body)
    if _thread is None or not _thread.is_alive():
        _thread = threading.Thread(target=display_loop, daemon=True)
        _thread.start()
    else:
        _wake.set()


proc = subprocess.Popen(
    ["dbus-monitor", "--session", MATCH],
    stdout=subprocess.PIPE,
    text=True,
    bufsize=1,
)

emit(" " * MAX_WIDTH)  # initial blank state

# Parse dbus-monitor output.
# Notify signature: app_name (string), replaces_id (uint32), icon (string),
#                   summary (string), body (string), actions (array), ...
# Collected strings in order: [app_name, icon, summary, body]
in_notify = False
strings = []

for line in proc.stdout:
    stripped = line.strip()

    if "member=Notify" in line and "method call" in line:
        in_notify = True
        strings = []
        continue

    if not in_notify:
        continue

    if stripped.startswith("array ["):
        if len(strings) >= 3:
            handle(
                strings[0],
                strings[2],
                strings[3] if len(strings) > 3 else "",
            )
        in_notify = False
        strings = []
        continue

    m = re.match(r'^string "(.*)"$', stripped)
    if m:
        strings.append(m.group(1))
