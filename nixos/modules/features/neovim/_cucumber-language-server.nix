{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:

buildNpmPackage rec {
  pname = "cucumber-language-server";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "cucumber";
    repo = "language-server";
    rev = "v${version}";
    hash = "sha256-GGPajuy1pOidi7Ux+i7CfLjsRT7vsLQRj1IzTXBWPQY=";
  };

  npmDepsHash = "sha256-sjoj7OLZcvFf0g/6kjhWgt/bUNKbbvYqBszNDYHxf4A=";

  npmFlags = [ "--ignore-scripts" ];

  # tree-sitter compiles a native addon via node-gyp, which needs python.
  nativeBuildInputs = [ python3 ];

  meta = {
    description = "Cucumber Language Server (LSP)";
    homepage = "https://github.com/cucumber/language-server";
    license = lib.licenses.mit;
    mainProgram = "cucumber-language-server";
  };
}
