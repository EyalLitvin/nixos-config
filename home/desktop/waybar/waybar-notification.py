import json
import os
import re
import subprocess
import sys
import threading

ALLOWED = {"waybar-notify"}
DEFAULT_TEXT = "..."
STATIC_SECS = 10.0
SCROLL_SPEED = 0.12   # seconds per character step
MAX_WIDTH = 28
MAX_HISTORY = 50
HISTORY_FILE = os.path.expanduser(
    "~/.local/state/waybar-notifications.json"
)
MATCH = (
    "type=method_call,"
    "interface=org.freedesktop.Notifications,"
    "member=Notify"
)

_lock = threading.Lock()
_wake = threading.Event()
_thread = None
_current = ("", "")  # (summary, body)


def emit(text, tooltip=""):
    data = {"text": text}
    if tooltip:
        data["tooltip"] = tooltip
    sys.stdout.write(json.dumps(data) + "\n")
    sys.stdout.flush()


def scroll(text, tooltip):
    """Slide a MAX_WIDTH window through text. Returns True if interrupted."""
    padded = text + "   "
    n = len(padded)
    for start in range(n):
        chunk = "".join(padded[(start + i) % n] for i in range(MAX_WIDTH))
        emit(chunk, tooltip)
        if _wake.wait(timeout=SCROLL_SPEED):
            return True
    return False


def display_loop():
    while True:
        _wake.clear()
        with _lock:
            summary, body = _current

        tooltip = body if body else summary

        if len(summary) <= MAX_WIDTH:
            emit(summary, tooltip)
            if _wake.wait(timeout=STATIC_SECS):
                continue
        else:
            if scroll(summary, tooltip):
                continue

        emit(DEFAULT_TEXT)
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

emit(DEFAULT_TEXT)

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
