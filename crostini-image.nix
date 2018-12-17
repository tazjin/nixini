# This derivation builds an LXC-compatible image that is prepared to
# run within crosvm.
#
# Configuration in this file is only responsible for the build setup.
# For the NixOS configuration, please see nixini-config.nix.

{ nixpkgs ? <nixos-unstable> }:

let pkgs = import nixpkgs {};
rootfs = (import "${nixpkgs}/nixos/release.nix" {
  configuration = {
    imports = [ ./nixini-config.nix ];
  };
}).containerTarball.x86_64-linux;

# Prepare LXC metadata for this container.
hostnameTpl = pkgs.writeText "hostname.tpl" "{{ container.name }}";
metadata = pkgs.writeText "metadata.yaml" ''
architecture: "x86_64"
# TODO: template from Nix
creation_date: 1519291500
properties:
    architecture: "x86_64"
    # TODO: template
    description: "NixOS 18.09"
    os: "nixos"
    release: "18.09"
templates:
    /etc/hostname:
        when:
            - create
            - copy
        template: hostname.tpl
'';
name = "nixini-18.09";
in pkgs.stdenv.mkDerivation ({
  name = "${name}-tarballs";
  buildCommand = ''
    # Create configuration tarball:
    mkdir $out templates
    cp ${hostnameTpl} templates/hostname.tpl
    cp ${metadata} metadata.yaml
    tar -czvf $out/nixos-system-x86_64-linux.tar.gz *

    # Create rootfs tarball:
    xzcat ${rootfs}/tarball/nixos-system-x86_64-linux.tar.xz | \
      gzip > $out/nixos-system-x86_64-linux.tar.gz.root
'';
})
