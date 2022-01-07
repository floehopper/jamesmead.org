with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/26038de2256eae025045e4646d91a73285700ed3.tar.gz") {});
let
  ruby = ruby_2_7;
  env = bundlerEnv {
    name = "jamesmead.org-bundler-env";
    inherit ruby;
    gemdir = ./.;
    gemConfig = pkgs.defaultGemConfig // {
      execjs = attrs: {
        propagatedBuildInputs = [];
      };
    };
  };
in stdenv.mkDerivation {
  name = "jamesmead.org";
  buildInputs = [ env ruby nodejs ];
}
