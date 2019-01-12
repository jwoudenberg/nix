# Take a markdown file where sentences start on individual lines,
# and return the text with paragraphs collapsed onto a single line.
function collapse-lines
    set in_frontmatter false
    while read -l line
        switch $line
            case '---'
                set in_frontmatter not eval $in_frontmatter
                echo $line
            case ''
                echo -e "\n"
            case '#*'
                echo $line
            case '*'
                if eval $in_frontmatter
                    echo $line
                else
                    echo -n "$line "
                end
        end
    end
end
