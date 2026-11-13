{pkgs, ... }:

let
  # The Android SDK requires license acceptance — needs its own pkgs instance.
  androidPkgs = import pkgs.path {
    inherit (pkgs) system;
    config = {
      allowUnfree              = true;
      android_sdk.accept_license = true;
    };
  };

  buildToolsVersion = "35.0.0";

  androidComposition = androidPkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion "30.0.3" ];
    platformVersions   = [ "36" "35" "34" "33" ];
    abiVersions        = [ "armeabi-v7a" "arm64-v8a" ];
    includeNDK         = true;
    ndkVersions        = [ "28.2.13676358" ];
    cmakeVersions      = [ "3.22.1" ];
  };

  androidSdk = androidComposition.androidsdk;

  # Shiron builds a Capacitor APK, which contains no native code: no NDK, no
  # cmake, one platform and one build-tools. Separate from the composition above
  # so the Flutter projects' needs and this one's can move independently;
  # androidenv composes from per-component derivations, so the pieces both
  # compositions use are fetched once and shared.
  shironAndroidSdk = (androidPkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion ];
    platformVersions   = [ "35" ];
    includeNDK         = false;
    cmakeVersions      = [ ];   # androidenv pulls one in unless told otherwise
  }).androidsdk;

  # Mosaic is a plain Kotlin/Compose app with no native code, so no NDK and no
  # cmake, and one platform and one build-tools version. compileSdk 36 means
  # platform 36, and AGP expects the matching 36.0.0 build-tools -- which is why
  # this is a separate composition from the 35.0.0 the Flutter projects pin.
  # androidenv composes from per-component derivations, so anything two
  # compositions share is still fetched once.
  mosaicBuildTools = "36.0.0";
  mosaicAndroidSdk = (androidPkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ mosaicBuildTools ];
    platformVersions   = [ "36" ];
    includeNDK         = false;
    cmakeVersions      = [ ];
  }).androidsdk;

  # Flutter 3.41.x gradle plugin unconditionally calls .readText() on
  # bin/cache/engine.realm, but the Nix store is read-only so flutter precache
  # can't create it.  Patch the package to include the empty file that a stable
  # release would normally have.
  flutter = androidPkgs.symlinkJoin {
    name    = "flutter-with-engine-realm";
    paths   = [
      androidPkgs.flutter
      (androidPkgs.writeTextFile {
        name        = "engine.realm";
        text        = "";
        destination = "/bin/cache/engine.realm";
      })
    ];
    nativeBuildInputs = [ androidPkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/flutter" --set FLUTTER_ROOT "$out"
    '';
  };
in

{
  prolix = {
    enable          = true;
    baseDir         = "~/dev";
    systemFlakePath = "~/.dotfiles";

    projects = {
      game_logic = {
        url = "git@github.com:EyalLitvin/game_logic.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ rustc cargo rust-analyzer ];
        };
      };

      sokobantron = {
        url = "git@github.com:EyalLitvin/sokobantron.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ rustc cargo rust-analyzer ];
        };
      };

      Thesis = {
        url = "git@github.com:EyalLitvin/Thesis.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ typst tinymist nodejs gap ];
        };
      };

      "personal-site" = {
        url = "git@github.com:EyalLitvin/personal-site.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ bun nodejs ];
        };
      };

      chronicles = {
        url = "git@github.com:EyalLitvin/chronicles.git";
        shell.autoAllow = true;
        shell.enable = true;
        # nodejs ships npm, so this is all a plain web project needs to start.
        shell.drv = pkgs.mkShell {
          packages = [ pkgs.nodejs ];
        };
      };

      "opti-do" = {
        url = "git@github.com:EyalLitvin/opti-do.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = androidPkgs.mkShell {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          buildInputs  = [ flutter androidSdk androidPkgs.jdk17 ];
          shellHook    = ''
            aapt2="${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2"
            gradle_props="android/gradle.properties"
            if [ -f "$gradle_props" ]; then
              sed -i '/^android.aapt2FromMavenOverride=/d' "$gradle_props"
            fi
            echo "android.aapt2FromMavenOverride=$aapt2" >> "$gradle_props"
          '';
        };
      };

      "saddle-point" = {
        url = "git@github.com:EyalLitvin/saddle-point.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = [ pkgs.python3 pkgs.stdenv.cc.cc.lib ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
            if [ ! -d .venv ]; then
              python3 -m venv .venv
            fi
            source .venv/bin/activate
          '';
        };
      };

      "prolix" = {
        url = "git@github.com:EyalLitvin/prolix.git";
        shell.autoAllow = true;
        shell.enable = false;
      };

      hoopoe = {
        url = "git@github.com:EyalLitvin/hoopoe.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            rustc cargo rust-analyzer
            udev alsa-lib vulkan-loader
            libxkbcommon wayland
            xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
            python312 uv stdenv.cc.cc.lib
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      };

      taskman = {
        url = "git@github.com:EyalLitvin/taskman.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = androidPkgs.mkShell {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          buildInputs  = [ flutter androidSdk androidPkgs.jdk17 ];
          shellHook    = ''
            aapt2="${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2"
            gradle_props="opti_do/android/gradle.properties"
            if [ -f "$gradle_props" ]; then
              sed -i '/^android.aapt2FromMavenOverride=/d' "$gradle_props"
            fi
            echo "android.aapt2FromMavenOverride=$aapt2" >> "$gradle_props"
          '';
        };
      };

      shiron = {
        url = "git@github.com:EyalLitvin/shiron.git";
        shell.autoAllow = true;
        shell.enable = true;
        # androidPkgs.mkShell, not pkgs.mkShell: the Android SDK is unfree and
        # needs the licence flag, so it only exists in that pkgs instance.
        shell.drv = androidPkgs.mkShell {
          packages = [
            # tools/build.py is pure stdlib; numpy + ffmpeg are only needed by
            # tools/process_samples.py, which regenerates assets/samples.
            (pkgs.python3.withPackages (ps: [ ps.numpy ]))
            pkgs.ffmpeg
            pkgs.nodejs
            # rsvg-convert, for tools/icons.py: bakes the launcher icon PNGs
            # out of assets/icon/shiron.svg.
            pkgs.librsvg
            # Ships lib/node_modules/{playwright,playwright-core}, so the browser
            # tests resolve require('playwright') with no npm install at all.
            pkgs.playwright-test
            # The Capacitor shell in mobile/ wraps dist/index.html into an APK.
            shironAndroidSdk
            # Capacitor 7's android library compiles with --source 21, so this is
            # 21 and not the 17 the Flutter projects above pin.
            androidPkgs.jdk21
          ];
          # Playwright normally downloads its own Chromium, which cannot run on
          # NixOS. Point it at the Nix-built browsers instead; the npm package
          # and the browser revision must come from the same version, which is
          # why both of these are taken from the same nixpkgs.
          NODE_PATH                              = "${pkgs.playwright-test}/lib/node_modules";
          PLAYWRIGHT_BROWSERS_PATH               = "${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD       = "1";
          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

          ANDROID_HOME = "${shironAndroidSdk}/libexec/android-sdk";
          # The Android Gradle plugin pulls a prebuilt aapt2 from Maven, and that
          # binary is dynamically linked against paths NixOS does not have. Point
          # Gradle at the Nix-built one instead. The path is only exported;
          # tools/release.py passes it as -P, so unlike the Flutter projects
          # above nothing rewrites a tracked gradle.properties on shell entry.
          AAPT2 = "${shironAndroidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
          # The Android Gradle plugin defaults to whatever build-tools version it
          # shipped against and tries to auto-install it, which fails against a
          # read-only store. tools/release.py forwards this so Gradle asks for the
          # one version this shell actually provides.
          ANDROID_BUILD_TOOLS = buildToolsVersion;
        };
      };

      mosaic = {
        url = "git@github.com:EyalLitvin/mosaic.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = androidPkgs.mkShell {
          # JDK 21: what the project's Java toolchain declares, and what current
          # AGP and Kotlin build on. The Flutter projects above are still on 17.
          packages = [ mosaicAndroidSdk androidPkgs.jdk21 ];

          ANDROID_HOME = "${mosaicAndroidSdk}/libexec/android-sdk";
          # AGP pulls a prebuilt aapt2 from Maven which is dynamically linked
          # against paths NixOS does not have. The repo's ./gw forwards this as
          # -Pandroid.aapt2FromMavenOverride, so -- unlike the Flutter projects
          # above -- nothing rewrites a tracked gradle.properties on shell entry.
          AAPT2 = "${mosaicAndroidSdk}/libexec/android-sdk/build-tools/${mosaicBuildTools}/aapt2";
          # AGP otherwise asks for whatever build-tools version it shipped
          # against and tries to install it into the read-only store.
          ANDROID_BUILD_TOOLS = mosaicBuildTools;
        };
      };
    };
  };
}
