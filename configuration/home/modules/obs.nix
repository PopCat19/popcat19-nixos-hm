# obs.nix
#
# Purpose: Configures OBS Studio with plugins and an optional seed-once
# streaming/recording profile tuned for AMD VAAPI hardware encoding.
#
# This module:
# - Enables OBS Studio with a plugin suite
# - Sets Wayland environment variables for OBS
# - Optionally seeds an OBS profile (basic.ini + encoder JSONs) on first
#   deploy only. Files are copied, not symlinked, so OBS can keep writing
#   them at runtime. Re-seed by deleting the profile files and rebuilding.
#
# Limitation: the seeded encoder configs are VAAPI-shaped (AMD). Intel QSV
# hosts should not enable streamingProfile; configure OBS manually instead.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  obs-plugins = with pkgs.obs-studio-plugins; [
    advanced-scene-switcher
    input-overlay
    obs-advanced-masks
    obs-pipewire-audio-capture
    obs-tuna
    obs-vkcapture
  ];

  cfg = config.programs.obs-studio;
  profileCfg = cfg.streamingProfile;

  # Push-to-mute helper: sends an explicit SetInputMute (true/false) to OBS
  # via obs-websocket v5. Reads the password from OBS's own config so no
  # secret enters the Nix store. Fails gracefully when OBS is offline or the
  # websocket server is disabled.
  obsSetMute =
    pkgs.writers.writePython3Bin "obs-set-mute"
      {
        libraries = [ pkgs.python3Packages.websocket-client ];
        flakeIgnore = [ "E501" ];
      }
      ''
        import sys
        import os
        import json
        import hashlib
        import base64
        from websocket import create_connection

        CONFIG = os.path.expanduser("~/.config/obs-studio/plugin_config/obs-websocket/config.json")
        SOURCE = "Mic/Aux"


        def main():
            if len(sys.argv) != 2 or sys.argv[1] not in ("mute", "unmute"):
                sys.stderr.write("usage: obs-set-mute {mute|unmute}\n")
                sys.exit(1)
            muted = sys.argv[1] == "mute"

            try:
                with open(CONFIG) as f:
                    cfg = json.load(f)
            except (OSError, ValueError) as e:
                sys.stderr.write(f"obs-set-mute: cannot read websocket config: {e}\n")
                sys.exit(1)

            if not cfg.get("server_enabled", False):
                sys.stderr.write("obs-set-mute: websocket server not enabled in OBS\n")
                sys.exit(1)

            password = cfg.get("server_password", "")
            port = cfg.get("server_port", 4455)

            try:
                ws = create_connection(f"ws://localhost:{port}", timeout=3)
            except Exception as e:
                sys.stderr.write(f"obs-set-mute: cannot connect (is OBS running?): {e}\n")
                sys.exit(1)

            try:
                hello = json.loads(ws.recv())
                auth_data = hello["d"].get("authentication", {})
                salt = auth_data["salt"]
                challenge = auth_data["challenge"]

                secret = base64.b64encode(
                    hashlib.sha256((password + salt).encode()).digest()
                ).decode()
                auth = base64.b64encode(
                    hashlib.sha256((secret + challenge).encode()).digest()
                ).decode()

                ws.send(json.dumps({
                    "op": 1,
                    "d": {"rpcVersion": 1, "authentication": auth}
                }))

                resp = json.loads(ws.recv())
                if resp.get("op") != 2:
                    sys.stderr.write(f"obs-set-mute: auth failed: {resp}\n")
                    sys.exit(1)

                ws.send(json.dumps({
                    "op": 6,
                    "d": {
                        "requestType": "SetInputMute",
                        "requestId": "mute-req",
                        "requestData": {"inputName": SOURCE, "inputMuted": muted}
                    }
                }))

                resp = json.loads(ws.recv())
                while resp.get("op") == 5:
                    resp = json.loads(ws.recv())
                if resp.get("op") != 7:
                    sys.stderr.write(f"obs-set-mute: request failed: {resp}\n")
                    sys.exit(1)
            finally:
                ws.close()


        main()
      '';

  # VAAPI stream encoder config (H.264, CBR). Keys mirror the schema OBS
  # logs under "[FFmpeg VAAPI encoder: ...] settings:".
  streamEncoderJson = pkgs.writeText "streamEncoder.json" (
    builtins.toJSON {
      vaapi_device = profileCfg.vaapiDevice;
      rate_control = "CBR";
      bitrate = profileCfg.streamBitrate;
      maxrate = profileCfg.streamBitrate;
      keyint = 120;
      bframes = 0;
      profile = 100;
      level = -99;
      qp = 0;
      ffmpeg_opts = "";
    }
  );

  # VAAPI record encoder config (AV1, CQP). QP 0-63, lower = higher quality.
  recordEncoderJson = pkgs.writeText "recordEncoder.json" (
    builtins.toJSON {
      vaapi_device = profileCfg.vaapiDevice;
      rate_control = "CQP";
      qp = profileCfg.recordQp;
      keyint = 120;
      bframes = 0;
      profile = 0;
      level = -99;
      bitrate = 0;
      maxrate = 0;
      ffmpeg_opts = "";
    }
  );

  # Minimal Advanced-mode basic.ini. Only the output/encoder knobs we care
  # about are opinionated; the rest mirrors a stock OBS profile so the file
  # is valid on first launch. Seed-once means existing files are never
  # overwritten, so host-specific edits made via the OBS UI persist.
  basicIni = pkgs.writeText "basic.ini" ''
    [General]
    Name=${profileCfg.profileName}

    [Output]
    Mode=Advanced
    FilenameFormatting=%CCYY-%MM-%DD %hh-%mm-%ss
    DelayEnable=false
    DelaySec=20
    DelayPreserve=true
    Reconnect=true
    RetryDelay=2
    MaxRetries=25
    BindIP=default
    IPFamily=IPv4+IPv6
    NewSocketLoopEnable=false
    LowLatencyEnable=false
    DynamicBitrate=true
    AutoRemux=false

    [Stream1]
    IgnoreRecommended=false
    EnableMultitrackVideo=false
    MultitrackVideoMaximumAggregateBitrateAuto=true
    MultitrackVideoMaximumVideoTracksAuto=true
    MultitrackExtraCanvas=

    [AdvOut]
    ApplyServiceSettings=false
    UseRescale=false
    TrackIndex=1
    VodTrackIndex=2
    Encoder=ffmpeg_vaapi_tex
    RecType=Standard
    RecFilePath=${config.home.homeDirectory}/Videos
    RecFormat2=mkv
    RecUseRescale=false
    RecTracks=1
    RecEncoder=av1_ffmpeg_vaapi_tex
    FLVTrack=1
    StreamMultiTrackAudioMixes=1
    FFOutputToFile=true
    FFFilePath=${config.home.homeDirectory}
    FFVBitrate=${toString profileCfg.streamBitrate}
    FFVGOPSize=250
    FFUseRescale=false
    FFIgnoreCompat=false
    FFABitrate=160
    FFAudioMixes=1
    Track1Bitrate=320
    Track2Bitrate=320
    Track3Bitrate=160
    Track4Bitrate=160
    Track5Bitrate=160
    Track6Bitrate=160
    RecSplitFileTime=15
    RecSplitFileSize=2048
    RecRB=true
    RecRBTime=20
    RecRBSize=512
    AudioEncoder=libfdk_aac
    RecAudioEncoder=libfdk_aac
    RecSplitFileType=Time
    FFFormat=
    FFFormatMimeType=
    FFVEncoderId=0
    FFVEncoder=
    FFAEncoderId=0
    FFAEncoder=
    RecFileNameWithoutSpace=true
    VodTrackEnabled=true
    RecSplitFile=false

    [Video]
    BaseCX=1920
    BaseCY=1080
    OutputCX=1920
    OutputCY=1080
    FPSType=0
    FPSCommon=60
    FPSInt=30
    FPSNum=30
    FPSDen=1
    ScaleType=bicubic
    ColorFormat=NV12
    ColorSpace=709
    ColorRange=Full
    SdrWhiteLevel=300
    HdrNominalPeakLevel=1000
    AutoRemux=false

    [Audio]
    MonitoringDeviceId=default
    MonitoringDeviceName=Default
    SampleRate=48000
    ChannelSetup=Stereo
    MeterDecayRate=23.53
    PeakMeterType=0

    [Panels]
    CookieId=0000000000000000
  '';
in
{
  options.programs.obs-studio.streamingProfile = {
    enable = lib.mkEnableOption "seed-once OBS streaming/recording profile (Advanced mode, AMD VAAPI encoders)";

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "Untitled";
      description = ''
        OBS profile directory name to seed under
        ~/.config/obs-studio/basic/profiles/. Must match the profile OBS
        loads by default, or the seed will not take effect.
      '';
    };

    vaapiDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/dri/by-path/pci-0000:12:00.0-render";
      description = ''
        Render node path passed to the VAAPI encoders. Host-specific.
        Find with: ls /dev/dri/by-path/ | grep render
      '';
    };

    streamBitrate = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8000;
      description = "CBR bitrate (kbps) for the H.264 VAAPI stream encoder.";
    };

    recordQp = lib.mkOption {
      type = lib.types.ints.between 0 63;
      default = 22;
      description = ''
        CQP QP for the AV1 VAAPI record encoder. AV1/HEVC scale 0-63;
        lower = higher quality. 18 near-lossless, 22 balanced, 26 small.
      '';
    };
  };

  config = {
    home.sessionVariables = {
      OBS_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
    };

    programs.obs-studio = {
      enable = true;
      plugins = obs-plugins;
    };

    home.packages = [ obsSetMute ];

    # Seed the profile files on first activation only. Copies (not symlinks)
    # so OBS can keep writing them. Existing files are never touched, which
    # means host-specific UI edits persist across rebuilds. To re-seed with
    # new HM defaults, delete the files and rebuild.
    #
    # Runs after writeBoundary so the activation environment is ready; these
    # files are not HM-managed symlinks so linkGeneration order is irrelevant.
    home.activation.obsStreamingProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.optionalString profileCfg.enable ''
        profile_dir="$HOME/.config/obs-studio/basic/profiles/${profileCfg.profileName}"
        mkdir -p "$profile_dir"

        seed() {
          local src="$1" dst="$2"
          if [ ! -e "$dst" ]; then
            cp "$src" "$dst"
            echo "obs-streaming-profile: seeded $dst"
          fi
        }

        seed "${basicIni}" "$profile_dir/basic.ini"
        seed "${streamEncoderJson}" "$profile_dir/streamEncoder.json"
        seed "${recordEncoderJson}" "$profile_dir/recordEncoder.json"
      ''
    );
  };
}
