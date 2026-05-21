{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  pkgs,
}:

buildPythonPackage rec {

  pname = "djitellopy";
  version = "2.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+ubJo1NASmHONixnZu/g0jz1Wf3q9gy8csdeSJbXgM0=";
  };

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;

  build-system = [
    setuptools
    wheel
  ];
  propagatedBuildInputs = with pkgs.python314Packages; [
    numpy
    pillow
    av
    opencv-python
  ];
}
