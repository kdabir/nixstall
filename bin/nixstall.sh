#!/bin/bash

## a single filer, intend to be simple
## the dir where everything will be installed
__nixstall_dir="${HOME}/.nixstall"

if [[ "$#" == "0" ]]; then
    # when called with no arguments, we are in init/source mode!
    # if this is executed in new shell, it should not have any effect

    export _NIXSTALL_PATHS=""
    ## add some functions to current shell may be
    function nixstall_reload() {
        for dir in $(find -L ${__nixstall_dir} -maxdepth 2 -type d -name bin); do
            _NIXSTALL_PATHS="${_NIXSTALL_PATHS:+"$_NIXSTALL_PATHS:"}$dir"

            # http://superuser.com/a/39995/66921
             if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
                PATH="${PATH:+"$PATH:"}$dir"
            fi
        done
    }

    function nixstall_link() {
        if [[ "$#" == "0" ]]; then
            ln -s . $__nixstall_dir
        else
            ln -s $1 $__nixstall_dir
        fi
    }

    function nixstall_list() {
        ls $__nixstall_dir
    }

     [ -d "$__nixstall_dir" ] && nixstall_reload

else
    __nixstall_url="https://raw.github.com/kdabir/nixstall/master/bin/nixstall.sh"

    # where nixstall itself will be installed
    __nixstall_home="${__nixstall_dir}/nixstall"
    __nixstall_bin="${__nixstall_home}/bin"
    __nixstall_script="${__nixstall_bin}/nixstall"
    __nixstall_version="0.1"

    if [ "$1" == "self" ] || [ ! -s $__nixstall_script ];then
        if [ ! -d "$__nixstall_dir" ]; then
            echo "*** creating nixstall directory at: $__nixstall_dir ***"
            mkdir -p $__nixstall_bin
        fi
        # because curl might fail and write grabage/blank to the script
        [ -s $__nixstall_script ] && cp $__nixstall_script "/tmp/nixstall_bak.sh"

        curl -sL "$__nixstall_url" > $__nixstall_script
        chmod +x "$__nixstall_script"

        bash_profile_file="${HOME}/.bash_profile"
        zshrc_file="${HOME}/.zshrc"

        if [ -z "$_NIXSTALL_PATHS" ]; then
            ## currently only updating two files
            for file in $bash_profile_file $zshrc_file
            do
                echo "updating $file"
                echo -e "\n# Added by nixstall, don't remove unless you know what you are doing" >> $file
                echo -e "[[ -s \"${__nixstall_script}\" ]] && source \"${__nixstall_script}\"\n" >> $file
            done

            echo "PLEASE CLOSE THIS TERMINAL SESSION AND OPEN A NEW ONE"
        fi

        [ "$1" == "self" ] && exit 0
    fi

    ## TODO validate if the archive has right directory strucutre

    ## we have to download the archive
    if [ "$1" == "get" ] && [ -n "$2" ];then
        # FILE=${2##*://*/}
        ## currently supporting only zip
        FILE="/tmp/nixstall-archive.zip"
        curl -L -o "$FILE" "$2"
        echo "archive file downloaded as : $FILE, copy it if you want to save it"

        # let unzip be interactive when replacing the existing file
        unzip -d $__nixstall_dir $FILE

        echo "Downloaded archive saved as: $FILE, copy it if you want to save it"
        echo "PLEASE CLOSE THIS TERMINAL SESSION AND OPEN A NEW ONE"

    elif [ -s "$1" ];then

        unzip -d $__nixstall_dir $1
        echo "PLEASE CLOSE THIS TERMINAL SESSION AND OPEN A NEW ONE"

    else
        echo "not a valid usage"
    fi

fi
