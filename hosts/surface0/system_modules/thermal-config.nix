# Surface Pro Intel Thermal Configuration
# Implements aggressive thermal management to prevent overheating
# Based on nixos-hardware thermal configuration for Surface Pro Intel devices
{
  config,
  lib,
  pkgs,
  ...
}: {
  # **THERMAL MANAGEMENT CONFIGURATION**
  services = {
    # Enable thermald with custom configuration
    thermald = {
      enable = true;
      configFile = pkgs.writeText "thermal-conf.xml" ''
        <?xml version="1.0"?>
        <ThermalConfiguration>
        <Platform>
        	<Name>Surface Pro Intel Thermal Workaround</Name>
        	<ProductName>*</ProductName>
        	<Preference>QUIET</Preference>
        	<ThermalZones>
        		<ThermalZone>
        			<Type>cpu</Type>
        			<TripPoints>
        				<TripPoint>
        					<SensorType>x86_pkg_temp</SensorType>
        					<Temperature>65000</Temperature>
        					<type>passive</type>
        					<ControlType>SEQUENTIAL</ControlType>
        					<CoolingDevice>
        						<index>1</index>
        						<type>rapl_controller</type>
        						<influence>100</influence>
        						<SamplingPeriod>10</SamplingPeriod>
        					</CoolingDevice>
        				</TripPoint>
        			</TripPoints>
        		</ThermalZone>
        	</ThermalZones>
        </Platform>
        </ThermalConfiguration>
      '';
    };
  };

  # **THERMAL KERNEL MODULES**
  # Ensure required thermal management modules are loaded
  boot.kernelModules = [
    # RAPL (Running Average Power Limit) modules for thermal control
    "intel_rapl_msr"
    "intel_rapl_common"

    # Core temperature monitoring
    "coretemp"

    # Intel power clamping for thermal management
    "intel_powerclamp"

    # Processor thermal device support
    "processor_thermal_device"
    "processor_thermal_device_pci_legacy"
    "processor_thermal_device_pci"
    "processor_thermal_rfim"
    "processor_thermal_mbox"
    "processor_thermal_rapl"

    # Intel SoC DTS (Digital Thermal Sensor)
    "intel_soc_dts_iosf"
    "intel_soc_dts_thermal"
  ];

  # **THERMAL KERNEL PARAMETERS**
  boot.kernelParams = [
    # Enable Intel P-State driver for better thermal management
    "intel_pstate=active"

    # Enable thermal zone polling
    "thermal.polling_delay=1000"

    # Set thermal governor to step_wise for gradual thermal response
    "thermal.governor=step_wise"

    # Enhanced performance parameters for AC power
    "intel_iommu=on"  # Better DMA performance
    "iommu=pt"        # Pass-through for better device performance
    "nvme_core.default_ps_max_latency_us=0"  # Disable NVMe power saving on AC
    "processor.max_cstate=1"  # Limit C-states for better responsiveness on AC
  ];

  # **THERMAL MONITORING PACKAGES**
  environment.systemPackages = with pkgs; [
    # Temperature monitoring utilities
    lm_sensors

    # Thermal monitoring and control
    thermald

    # Power and thermal analysis
    powertop

    # System monitoring with thermal info
    htop
    btop
  ];

  # **THERMAL SYSTEMD SERVICES**
  systemd.services = {
    # Service to monitor thermal status
    thermal-monitor = {
      description = "Surface Thermal Monitor";
      wantedBy = ["multi-user.target"];
      after = ["thermald.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.lm_sensors}/bin/sensors > /tmp/thermal-status.log'";
      };
      # Run every 30 seconds
      startAt = "*:*:0/30";
    };

    # AC performance optimization service
    ac-performance-optimizer = {
      description = "Surface AC Performance Optimizer";
      wantedBy = ["multi-user.target"];
      after = ["auto-cpufreq.service" "thermald.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c ''
          # Optimize for AC power when connected
          if [ -e /sys/class/power_supply/AC/online ] && [ \"$(cat /sys/class/power_supply/AC/online)\" = \"1\" ]; then
            # Disable power saving features on AC
            echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
            echo 0 > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
            echo on > /sys/bus/pci/devices/*/power/control 2>/dev/null || true
            echo max_performance > /sys/class/scsi_host/host*/link_power_management_policy 2>/dev/null || true
          fi
        ''";
      };
    };

    # AC state monitoring service
    ac-state-monitor = {
      description = "Surface AC State Monitor";
      wantedBy = ["multi-user.target"];
      after = ["ac-performance-optimizer.service"];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = "${pkgs.bash}/bin/bash -c ''
          # Monitor AC state changes and optimize accordingly
          while true; do
            if [ -e /sys/class/power_supply/AC/online ]; then
              if [ \"$(cat /sys/class/power_supply/AC/online)\" = \"1\" ]; then
                # AC connected - ensure performance mode
                echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
              else
                # On battery - let auto-cpufreq handle it
                echo \"On battery - auto-cpufreq managing\" > /dev/null
              fi
            fi
            sleep 10
          done
        ''";
      };
    };
  };

  # **THERMAL UDEV RULES**
  services.udev.extraRules = ''
    # Thermal zone permissions for monitoring
    SUBSYSTEM=="thermal", MODE="0664", GROUP="users"

    # RAPL energy monitoring permissions
    SUBSYSTEM=="powercap", MODE="0664", GROUP="users"

    # Temperature sensor permissions
    KERNEL=="coretemp.*", MODE="0664", GROUP="users"
  '';
}
