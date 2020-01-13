self: super:

let
  print-pdf-text = super.writeShellScriptBin "print-pdf-text" ''
    exec ${super.xpdf}/bin/pdftotext "$1" -
  '';
in {
  pdfrg = super.writeShellScriptBin "pdfrg" ''
    exec rg --pre-glob '*.pdf' --pre "${print-pdf-text}/bin/print-pdf-text" "$@"
  '';
}
