# Surface Pro Intel Thermal Configuration
# Implements aggressive thermal management to prevent overheating
# Based on nixos-hardware thermal configuration for Surface Pro Intel devices
{ pkgs, ... }:
{
  # **THERMAL MANAGEMENT CONFIGURATION**
  services = {
    # Enable thermald with custom configuration
    thermald = {
      enable = true;
      configFile = pkgs.writeText "thermal-conf.xml" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <ThermalConfiguration>
          <Platform>
            <Name>Surface Pro Intel Thermal Workaround</Name>
            <ProductName>*</ProductName>
            <Preference>QUIET</Preference>
            <ThermalZones>

              <ThermalZone>
                <Type>cpu</Type>
                <TripPoints>

                  <!-- Soft mitigation: start mild powerclamp -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>60000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <index>1</index>
                      <type>intel_powerclamp</type>
                      <influence>25</influence>
                      <SamplingPeriod>5</SamplingPeriod>
                    </CoolingDevice>
                  </TripPoint>

                  <!-- Moderate mitigation @70 °C -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>70000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <index>2</index>
                      <type>rapl_controller</type>
                      <influence>60</influence>
                      <SamplingPeriod>5</SamplingPeriod>
                    </CoolingDevice>
                  </TripPoint>

                  <!-- HARD limit @90 °C (sustained) -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>90000</Temperature>
                    <type>hot</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <index>3</index>
                      <type>rapl_controller</type>
                      <influence>100</influence>
                      <SamplingPeriod>3</SamplingPeriod>
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
    "intel_rapl_msr"
    "intel_rapl_common"
    "intel_powerclamp"
    "coretemp"
    "processor_thermal_device"
    "processor_thermal_device_pci"
    "processor_thermal_rfim"
    "processor_thermal_mbox"
    "processor_thermal_rapl"
    "intel_soc_dts_iosf"
    "intel_soc_dts_thermal"
  ];

  # **THERMAL KERNEL PARAMETERS**
  boot.kernelParams = [
    "intel_pstate=active"
    "thermal.governor=step_wise"
    "thermal.polling_delay=1000"
    "processor.max_cstate=2"
    "intel_iommu=on"
    "iommu=pt"
    "nvme_core.default_ps_max_latency_us=2500"
  ];

  # **THERMAL MONITORING PACKAGES**
  environment.systemPackages = with pkgs; [
    lm_sensors
    thermald
    powertop
    htop
    btop
    intel-gpu-tools
  ];

  # **THERMAL UDEV RULES**
  services.udev.extraRules = ''
    SUBSYSTEM=="thermal", MODE="0664", GROUP="users"
    SUBSYSTEM=="powercap", MODE="0664", GROUP="users"
    KERNEL=="coretemp.*", MODE="0664", GROUP="users"
  '';
}
