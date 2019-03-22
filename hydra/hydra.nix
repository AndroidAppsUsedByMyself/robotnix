{ }: with builtins;
let
  defaultNixDroid = {
    nixexprpath = "release.nix";
    checkinterval = 300;
    schedulingshares = 1000;
    keepnr = 3;
  };
  mkInput = t: v: e: { type = t; value = v; emailresponsible = e; };
  defaultInputs = args: {
    nixdroid = mkInput "git" "https://github.com/ajs124/NixDroid dev" true;
    nixpkgs = mkInput "git" "https://github.com/nixos/nixpkgs-channels nixos-18.09" false;
    rev = mkInput "string" (optConf args "rev" "lineage-16.0") false;
    keyStorePath = mkInput "string" "/var/lib/nixdroid/keystore" false;
    device = mkInput "string" args.device false;
    manifest = mkInput "string" (optConf args "manifest" "https://github.com/LineageOS/android.git") false;
    sha256Path = mkInput "path" ("/var/lib/nixdroid/hashes/" + args.device + ".sha256") false;
    extraFlags = mkInput "string" (optConf args "extraFlags" "-g all,-darwin,-infra,-sts --no-repo-verify") false;
    localManifests = {
      type = "string";
      value = [ (../roomservice- + "${args.device}.xml") ] ++
        (if (hasAttr "enableWireguard" args && args.enableWireguard) then [ ../wireguard.xml ] else []) ++
        (if (hasAttr "opengappsVariant" args) then [ ../opengapps.xml ] else []);
      emailresponsible = false;
    };
  };
  optConf = set: attr: default: if (hasAttr attr set) then set.${attr} else default;
in {
  defaultJobset = {
    enabled = 1;
    hidden = false;
    nixexprinput = "nixdroid";
    nixexprpath = "release.nix";
    checkinterval = 300;
    schedulingshares = 1000;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
  };
  jobsets = {
    "los-15.1-hammerhead" = defaultNixDroid // {
      description = "LineageOS 15.1 for Hammerhead";
      inputs = defaultInputs {
        device = "hammerhead";
        rev = "lineage-15.1";
        opengappsVariant = "pico";
      };
    };
    "los-15.1-payton" = defaultNixDroid // {
      description = "LineageOS 15.1 for Payton";
      inputs = defaultInputs {
        device = "payton";
        rev = "lineage-15.1";
        enableWireguard = true;
        opengappsVariant = "nano";
      };
    };
    "los-16.0-oneplus3" = defaultNixDroid // {
      description = "LineageOS 16.0 for OnePlus 3";
      inputs = defaultInputs {
        device = "oneplus3";
        enableWireguard = true;
        opengappsVariant = "nano";
      };
    };
    # "los-16.0-bacon" = defaultNixDroid // {
    #   description = "LineageOS 16.0 for Bacon";
    #   inputs = defaultInputs {
    #     device = "bacon";
    #     enableWireguard = true;
    #     opengappsVariant = "pico";
    #   };
    # };
  };
}
