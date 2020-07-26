with (import <nixpkgs> {});
let
  ruby = ruby_2_6;
  env = bundlerEnv {
    name = "jamesmead.org-bundler-env";
    inherit ruby;
    gemdir = ./.;
  };
in stdenv.mkDerivation {
  name = "jamesmead.org";
  buildInputs = [ env ruby nodejs ];
}
