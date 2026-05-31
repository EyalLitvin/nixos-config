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

      Thesis = {
        url = "git@github.com:EyalLitvin/Thesis.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ typst tinymist ];
        };
      };

      "personal-site" = {
        url = "git@github.com:EyalLitvin/personal-site.git";
        shell.autoAllow = true;
        shell.enable = true;
        shell.drv = pkgs.mkShell {
          packages = with pkgs; [ bun ];
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

      "prolix" = {
        url = "git@github.com:EyalLitvin/prolix.git";
        shell.autoAllow = true;
        shell.enable = false;
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
    };
  };
}
