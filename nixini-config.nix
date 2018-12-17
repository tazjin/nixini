# System configuration for a Nixini container. This contains the cros
# guest tools which includes sommelier (Wayland compositor deferring
# to ChromeOS on the outside) and garcon (desktop integration daemon).
#
# Please see the documentation for Crostini for more information.

{ config, pkgs, lib, ... }:

let crosTools = builtins.fetchgit {
  url = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools";
  rev = "376aeb69b6f4fe9c01d8ddab3d570987c92b0499";
};

in {
  # Using the sandbox causes builds to be attempted in a chroot,
  # which fails in the permission setup given to the LXC container
  # inside the crosvm.
  #
  # As of NixOS 18.09 sandboxing is the default, hence it is
  # disabled here.
  nix.useSandbox = false;

  # cros tools configuration
  #
  # crostini bind-mounts a set of tools and configuration files into
  # the container, which are then normally run via systemd units
  # contained in the `cros-container-guest-tools` repository.
  #
  # In NixOS, we instead configure these units via Nix configuration.

  # cros-adapta
  #
  # TODO: bind-mounted GTK theme

  # cros-apt-config: Not applicable to NixOS

  # cros-garcon
  #
  # Garcon is the application bridge to Chromium OS, which provides
  # features such as URL opening.
  #
  # TODO: add helper tools & figure out environment overrides
  systemd.services.garcon = {
    enable      = true;
    description = "Chromium OS Garcon Bridge";
    after       = [ "sommelier@0.service" "sommelier-x@0.service" ];
    script      = "/opt/google/cros-containers/bin/garcon --server";
    wantedBy    = [ "default.target" ];
  };
}
