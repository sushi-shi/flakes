{
  description =
    "A flake giving access to packages required to build perfbook, which are outside of nixpkgs.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = pkgs.symlinkJoin {
          name = "perf-book-env";
          paths = builtins.attrValues
            self.packages.${system};
        };

        packages.steel-city-comic = pkgs.stdenvNoCC.mkDerivation {
          name = "steel-city-comic";
          src = builtins.fetchurl {
            url = "https://github.com/paulmckrcu/perfbook/blob/master/fonts/steel-city-comic.regular.ttf?raw=true";
            sha256 = "sha256:1663rdbqrciinvd3z2xrqxazlq79qjfnxyb61ginazjc11a90kcv";
          };

          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/share/fonts
            cp -R $src $out/share/fonts/
          '';
          meta = { description = "A font used for building perfbook"; };
        };

        packages.fig2ps = pkgs.stdenv.mkDerivation rec {
          pname = "fig2ps";
          version = "1.5";

          buildInputs = with pkgs; [ perl fig2dev ];
          nativeBuildInputs = [ pkgs.perl ];

          src = pkgs.fetchurl {
            url = "mirror://sourceforge/fig2ps/fig2ps-${version}.tar.bz2";
            sha256 = "sha256:1fa91jyrxq8rc1kl8d3d4z85x2mdw0kmhk3cdqihisvb23jfr7g5";
          };

          makeFlags = [
            "DESTDIR=$(out)"
            "BINDIR=/bin"
          ];

          postPatch = ''
            substituteInPlace bin/fig2ps \
              --replace \
                'my $pre_beg_commands = "\\usepackage[a0paper, margin=5cm]{geometry}\n"' \
                'my $pre_beg_commands = "\\usepackage[a0paper, margin=5cm]{geometry}\n\\usepackage{graphicx}\n"'
          '';
        };
      });
}
