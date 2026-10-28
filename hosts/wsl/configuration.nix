# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
  nixos-wsl,
  ...
}:
let
  user = import ../../modules/base/user.nix { };
  hasFlashAttention = false;
in
{
  imports = [
    nixos-wsl.nixosModules.default
    ../../modules/base
    ../../modules/development
    ../../modules/local-llm
  ];

  # My work laptop running WSL doesn't have CUDA support
  hasCudaSupport = false;
  hasVulkanSupport = true;
  hasFlashAttention = hasFlashAttention;

  wsl = {
    enable = true;
    defaultUser = user.userName; # Set your primary login username - from user.nix
    useWindowsDriver = true; # Expose Windows D3D12 libs so Mesa's Dozen Vulkan driver can reach the Intel Arc GPU

    wslConf.interop.appendWindowsPath = true;
  };

  # Don't run any NixOS native stuff
  systemd.services.libvirtd.enable = lib.mkForce false;
  systemd.services.fix-wifi.enable = lib.mkForce false;

  # Use Windows networking
  networking.networkmanager.enable = lib.mkForce false;

  # Disable everything to do with display and Hyprland
  services.xserver.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  programs.ssh.startAgent = lib.mkForce true;
  xdg.portal.enable = lib.mkForce false;
  systemd.user.services.change-wallpaper.enable = lib.mkForce false;

  # The prompt UI for SSH doesn't show up. Ask in the tty instead
  programs.ssh.enableAskPassword = lib.mkForce false;

  environment.sessionVariables = {
    SSH_ASKPASS_REQUIRE = lib.mkForce "never";
    DEFAULT_ZELLIJ_PROFILE = lib.mkForce "oktopi";

    # Mesa's Dozen Vulkan driver dlopens libd3d12.so by name, which only lives in the driver dir
    LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];

    # Flash attention crashes with the Intel Arc GPU on the Oktopi laptop
    LLAMA_SERVER_FLASH_ATTN = if hasFlashAttention then "on" else "off";
  };

  # WSL has no /dev/dri, so native Intel drivers can't see the GPU. Mesa's Dozen
  # Vulkan driver goes through D3D12 (/dev/dxg) to the Windows Intel Arc driver instead
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    intel-media-driver
    intel-ocl
    intel-vaapi-driver
    vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
    vulkan-tools # vulkaninfo, to check the Arc GPU is visible
  ];

  # WSL handles everything else, including hardware configuration
}
