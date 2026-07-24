function rsv -d "Manage runit services and it isn't miserable"
    argparse u/user -- $argv
    or return 1

    set -l cmd $argv[1]
    set -l name $argv[2]

    if not set -q RSV_SYSTEM_SV_DIR
        set -g RSV_SYSTEM_SV_DIR /etc/runit/sv
    end
    if not set -q RSV_SYSTEM_RUN_DIR
        set -g RSV_SYSTEM_RUN_DIR /run/runit/service
    end
    if not set -q RSV_USER_SV_DIR
        set -g RSV_USER_SV_DIR ~/.runit/sv
    end
    if not set -q RSV_USER_RUN_DIR
        set -g RSV_USER_RUN_DIR ~/.runit/runsvdir
    end

    set -l sv_dir $RSV_SYSTEM_SV_DIR
    set -l run_dir $RSV_SYSTEM_RUN_DIR
    set -l use_sudo 1

    if set -q _flag_user
        set sv_dir $RSV_USER_SV_DIR
        set run_dir $RSV_USER_RUN_DIR
        set use_sudo 0
    end

    # wrapper so we never end up with an empty command word
    function _rsv_run
        if test "$argv[1]" = 1
            command sudo $argv[2..-1]
        else
            command $argv[2..-1]
        end
    end

    if test -z "$cmd"
        echo "usage: rsv [--user] enable|disable|status|list [service] [-f]"
        return 1
    end

    switch $cmd
        case enable en
            if test -z "$name"
                echo "rsv enable: need a service name"
                return 1
            end
            if not test -d $sv_dir/$name
                echo (set_color red)"rsv: no such service definition: $sv_dir/$name"(set_color normal)
                return 1
            end
            if test -e $run_dir/$name
                echo (set_color yellow)"rsv: $name already enabled"(set_color normal)
                return 0
            end
            _rsv_run $use_sudo ln -s $sv_dir/$name $run_dir/$name
            and echo (set_color green)"enabled $name"(set_color normal)

        case disable dis d
            if test -z "$name"
                echo "rsv disable: need a service name"
                return 1
            end
            if not test -e $run_dir/$name
                echo (set_color yellow)"rsv: $name not enabled"(set_color normal)
                return 1
            end
            _rsv_run $use_sudo sv down $run_dir/$name
            _rsv_run $use_sudo rm $run_dir/$name
            and echo (set_color green)"disabled $name"(set_color normal)

        case status st
            if test -n "$name"
                _rsv_run $use_sudo sv status $run_dir/$name
            else
                for d in $run_dir/*
                    _rsv_run $use_sudo sv status $d
                end
            end

        case list ls l
            for d in $sv_dir/*
                set -l base (basename $d)
                if test -e $run_dir/$base
                    echo (set_color green)"  ●  $base"(set_color normal)
                else
                    echo (set_color brblack)"  ○  $base"(set_color normal)
                end
            end

        case '*'
            echo "unknown command: $cmd"
            echo "usage: rsv [--user] enable|disable|status|list [service] [-f]"
            return 1
    end

    functions -e _rsv_run
end
