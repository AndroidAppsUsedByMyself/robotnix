{
  description = "A basic example robotnix configuration";

  inputs.robotnix.url = "..";

  outputs = { self, robotnix }: {
    # Declare your robotnix configurations. You can build the images and OTA
    # zips via the `img` and `ota` attrs, for instance `nix build .#robotnixConfigurations.myLineageOS.ota`.
    robotnixConfigurations."myLineageOS" = robotnix.lib.robotnixSystem ./lineageos.nix;
    robotnixConfigurations."myGrapheneOS" = robotnix.lib.robotnixSystem ./grapheneos.nix;
    robotnixConfigurations."pstar_lineageos_22_1" = robotnix.lib.robotnixSystem ./lineageos_22.1_pstar.nix;
    robotnixConfigurations."pstar_lineageos_22_2" = robotnix.lib.robotnixSystem ./lineageos_22.2_pstar.nix;

    # This provides a convenient output which allows you to build the image by
    # simply running "nix build" on this flake.
    packages.x86_64-linux.default = self.robotnixConfigurations."pstar_lineageos_22_1".img;
  };
}
