#!/usr/bin/env nu

def main [...subtitle: string] {
    let date = (date now | format date "%y-%m-%d")
    mkdir ~/docs/diary
    let entry = ($"~/docs/diary/($date).md" | path expand)
    let title = $"# ($date)"

    # Create the diary file if it doesn't exist.
    if not ($entry | path exists) {
        $title | save $entry
    }

    # Add a subtitle section if extra arguments are passed.
    let subtitle_text = ($subtitle | str join " ")
    if $subtitle_text != "" {
        $"\n## ($subtitle_text)" | save --append $entry
    }

    # Allow the user to edit the entry.
    ^$env.EDITOR $entry

    # Remove the entry if no text was added to it.
    let content = (open $entry | str trim)
    if $title =~ $content {
        echo "Deleting empty diary entry."
        rm $entry
    }
}
