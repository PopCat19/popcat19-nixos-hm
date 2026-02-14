# thermal-config.nix
#
# Purpose: Thermal management configuration for Surface Pro Intel
#
# This module:
# - Configures thermald with custom thermal zones
# - Loads thermal management kernel modules
{ pkgs, ... }:
{
  services = {
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

  boot.kernelModules = [
    "coretemp"
    "intel_powerclamp"
    "intel_rapl_common"
    "intel_rapl_msr"
    "intel_soc_dts_iosf"
    "intel_soc_dts_thermal"
    "processor_thermal_device"
    "processor_thermal_device_pci"
    "processor_thermal_mbox"
    "processor_thermal_rapl"
    "processor_thermal_rfim"
  ];

  boot.kernelParams = [
    "intel_iommu=on"
    "intel_pstate=active"
    "iommu=pt"
    "nvme_core.default_ps_max_latency_us=2500"
    "processor.max_cstate=2"
    "thermal.governor=step_wise"
    "thermal.polling_delay=1000"
  ];

  environment.systemPackages = with pkgs; [
    btop
    htop
    intel-gpu-tools
    lm_sensors
    powertop
    thermald
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="thermal", MODE="0664", GROUP="users"
    SUBSYSTEM=="powercap", MODE="0664", GROUP="users"
    KERNEL=="coretemp.*", MODE="0664", GROUP="users"
  '';
}
