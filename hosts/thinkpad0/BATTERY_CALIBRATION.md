# ThinkPad Battery Calibration Instructions

## Purpose
This branch contains TLP configuration specifically for calibrating the ThinkPad battery to improve health and accuracy.

## Configuration Details

### Battery Charge Thresholds
- **Start Charging**: 40%
- **Stop Charging**: 80%

These thresholds help prolong battery life by avoiding full charges and deep discharges.

### TLP Settings
- TLP replaces auto-cpufreq during calibration
- Optimized power management for battery health
- ThinkPad-specific configurations enabled

## Calibration Process

### 1. Apply Configuration
```bash
sudo nixos-rebuild switch --flake .#popcat19-thinkpad0
```

### 2. Monitor Battery Status
```bash
# Check battery information
tlp-stat -b

# Monitor power consumption
powertop

# Check ACPI battery status
acpi -V
```

### 3. Calibration Steps

#### Option A: Automated Recalibration (Recommended)
```bash
# Perform complete battery recalibration automatically
sudo tlp recalibrate

# For secondary battery (if present)
sudo tlp recalibrate BAT1
```
This will:
- Completely discharge the battery
- Recharge to 100% automatically
- Restore configured thresholds (40-80%) after completion

#### Option B: Manual Calibration Cycle
1. **Discharge**: Use the laptop until battery reaches ~40%
2. **Charge**: Connect charger and let it charge to 80% (TLP will stop automatically)
3. **Repeat**: Cycle 2-3 times for best results

#### Option C: Temporary Full Charge
```bash
# Temporarily charge to 100% for calibration
sudo tlp fullcharge

# Charge once to stop threshold (80%)
sudo tlp chargeonce

# Custom thresholds (temporary)
sudo tlp setcharge 70 90
```

### 4. Monitor Progress
```bash
# Check battery wear level
sudo tlp-stat --battery

# View detailed battery information
cat /sys/class/power_supply/BAT0/uevent
```

## Temporary Nature
This configuration is **temporary** and should be:
- Used for 2-3 weeks for proper calibration
- Reverted afterward to restore auto-cpufreq
- Monitored for battery health improvements

## Reverting Changes
After calibration period:
```bash
git checkout devixos-config
git branch -D tlp-thinkpad0-battery
sudo nixos-rebuild switch --flake .#popcat19-thinkpad0
```

## Expected Results
- More accurate battery percentage reporting
- Improved battery health over time
- Consistent charge/discharge behavior

## Troubleshooting
- If TLP doesn't start: `sudo systemctl restart tlp`
- Check service status: `systemctl status tlp`
- View logs: `journalctl -u tlp`