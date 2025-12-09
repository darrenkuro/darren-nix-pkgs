{
  pkgs,
  naerskLib,
  src,
  ...
}:
naerskLib.buildPackage {
  pname = "git-init";
  version = "0.1.0";
  inherit src; # points to ./pkgs/git-init

  # If you need extra nativeBuildInputs:
  # nativeBuildInputs = [ pkgs.pkg-config ];

  # If you want to ensure reproducible Cargo input:
  cargoLock = {
    lockFile = src + "/Cargo.lock";
  };

  meta = with pkgs.lib; {
    description = "CLI for initializing repos to GitHub";
    homepage = "https://github.com/darrenkuro/darren-nix-pkgs";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
