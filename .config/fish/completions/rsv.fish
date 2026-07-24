function __rsv_using_user
    contains -- -u (commandline -opc)
    or contains -- --user (commandline -opc)
end

function __rsv_sv_dir
    if __rsv_using_user
        if set -q RSV_USER_SV_DIR
            echo $RSV_USER_SV_DIR
        else
            echo ~/.runit/sv
        end
    else
        if set -q RSV_SYSTEM_SV_DIR
            echo $RSV_SYSTEM_SV_DIR
        else
            echo /etc/runit/sv
        end
    end
end

function __rsv_services
    set -l dir (__rsv_sv_dir)
    for d in $dir/*
        basename $d
    end
end

function __rsv_needs_command
    set -l tokens (commandline -opc)
    set -l count 0
    for t in $tokens[2..-1]
        switch $t
            case '-*'
                continue
            case '*'
                set count (math $count + 1)
        end
    end
    test $count -eq 0
end

complete -c rsv -f

complete -c rsv -n __rsv_needs_command -a enable -d "enable a service"
complete -c rsv -n __rsv_needs_command -a disable -d "disable a service"
complete -c rsv -n __rsv_needs_command -a status -d "show service status"
complete -c rsv -n __rsv_needs_command -a list -d "list services"

complete -c rsv -s u -l user -d "operate on user services"

complete -c rsv -n "__fish_seen_subcommand_from enable disable status" -a "(__rsv_services)"
