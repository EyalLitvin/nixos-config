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
          buildInputs  = with androidPkgs; [ flutter androidSdk jdk17 ];
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
    };
  };
}
