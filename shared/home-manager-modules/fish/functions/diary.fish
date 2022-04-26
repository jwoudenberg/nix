function diary
    set date (date "+%y-%m-%d")
    mkdir -p ~/docs/diary
    set entry ~/docs/diary/$date.md
    set title "# $date"

    # Create the diary file if it doesn't exist.
    if not test -e $entry
        echo "$title" > $entry
    end

    # Add a subtitle section if extra arguments are passed.
    set subtitle_text (string join " " $argv)
    if test -n "$subtitle_text"
        echo -e "\n## $subtitle_text" >> $entry
    end

    # Allow the user to edit the entry.
    eval $EDITOR $entry

    # Remove the entry if no text was added to it.
    set content (cat $entry)
    set content (string trim "$content")
    if test "$content" = "$title"
        echo "Deleting empty diary entry."
        rm $entry
    end
end
