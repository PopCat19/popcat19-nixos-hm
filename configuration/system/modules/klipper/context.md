# Context

- `default.nix` — Entry point that gates the Klipper stack on `userConfig.klipper.enable`; seeds the client WiFi profile once and wires the AP fallback
- `ap-fallback.nix` — Fallback access point (`Klipper-Setup`) with auto/manual toggle via `klipper_ap_on` / `klipper_ap_off`
- `users.nix` — `klipper` and `moonraker` system users and groups
- `printer.nix` — Klipper firmware service with mutable `printer.cfg`
- `moonraker.nix` — Moonraker API server for Klipper
- `mainsail.nix` — Mainsail web UI on port 80 via nginx
