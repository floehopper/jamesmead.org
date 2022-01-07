with (import <nixpkgs> {});
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
