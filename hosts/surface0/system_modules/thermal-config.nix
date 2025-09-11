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
