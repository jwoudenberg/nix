#!/usr/bin/env nu

def main [...search: string] {
    cd ~/docs/zettel

    if ($search | is-empty) {
      let date = (date now | format date "%y%m%d%H%M")
      let entry = ($"./($date)" | path expand)
      let title = $"# ($date)"

      # Create the diary file if it doesn't exist.
      if not ($entry | path exists) {
          $title | save $entry
      }

      # Allow the user to edit the entry.
      ^$env.EDITOR $entry

      # Remove the entry if no text was added to it.
      let content = (open $entry | str trim)
      if $title =~ $content {
          echo "Deleting empty diary entry."
          rm $entry
      }
    } else {
      # Kind of expecting $EDITOR to be vim, or at least support that -c flag
      exec $env.EDITOR -c $":Rg ($search | str join ' ')"
    }
}
