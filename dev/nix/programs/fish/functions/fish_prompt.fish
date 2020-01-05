function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    set -l prompt_status
    if test $last_status -ne 0
        set prompt_status (set_color $fish_color_status) "[$last_status]" \n
    end

    set -l prompt_path
    if test "$PWD" = ~
        set prompt_path (set_color -o (prompt_color)) "~"
    else
        set prompt_path (set_color -o (prompt_color)) (basename "$PWD")
    end

    echo -n -s \n $prompt_status $prompt_path (set_color normal) " "
end

function fish_right_prompt --description 'Write out the right prompt'
    echo -n -s " " (set_color (prompt_color)) (__fish_git_prompt) (set_color normal)
end

function prompt_color --description 'Color of the prompt'
    switch $fish_bind_mode
        case default
            echo red
        case insert
            echo green
        case visual
            echo yellow
    end
end
