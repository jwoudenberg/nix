#!/usr/bin/env nu

def main [csv: string] {
  open $csv | each { import-pass $in }
}

def import-pass [row] {
  let prefix = $row.Group | str replace --regex "^passwords" ""
  let title = $"($prefix)/($row.Title)"

  mut content = $"($row.Password)\n"
  if not ($row.Username | is-empty) {
    $content += $"username: ($row.Username)\n"
  }
  $content += $row.Notes

  $content | passage insert --multiline $title
}
