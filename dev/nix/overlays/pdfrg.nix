self: super:

{
  pdfrg = super.writeShellScriptBin "pdfrg" ''
    rg --pre-glob '*.pdf' --pre ${super.xpdf}/bin/pdftotext "$@"
  '';
}
