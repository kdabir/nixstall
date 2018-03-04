#!/bin/bash

## IMPORTANT
## This is a `bash` script, don't use it with `sh`.
## it is a single filer and intend to be simple

## This variable is available in the shell in which nixstall is sourced
export _NIXSTALL_PATHS=""

## when sourcing the file, `nixstall` will be available in shell as function
function nixstall(){

    ## the dir where everything will be installed, not configurable as of now
    local __nixstall_dir="${HOME}/.nixstall"

    ## url from where to get latest nixstall, if required
    local __nixstall_url="https://raw.githubusercontent.com/kdabir/nixstall/master/bin/nixstall.sh"

    # where nixstall itself will be installed
    local __nixstall_home="${__nixstall_dir}/nixstall"
    local __nixstall_bin="${__nixstall_home}/bin"
    local __nixstall_script="${__nixstall_bin}/nixstall"
    local __nixstall_version="0.1"

    ################# INSTALLING SELF ###################
    ## if user explicitly aksed OR if the nixstall script is not present locally
    if [[ "$1" == "self" ]] || [ ! -s $__nixstall_script ];then

        ## if nixstall's bin is not present
        if [ ! -d "$__nixstall_bin" ]; then
            echo "*** creating nixstall directory at: $__nixstall_dir ***"
            # create it
            mkdir -p $__nixstall_bin
        fi

        # take a backup only if the script already exists
        # because curl might fail and write grabage/blank to the script
        # this way user will be able to recover nixstall
        [ -s $__nixstall_script ] && cp $__nixstall_script "/tmp/nixstall_bak.sh"

        # Download the nixstall script
        curl -sL "$__nixstall_url" > $__nixstall_script

        # make nixstall executable
        chmod +x "$__nixstall_script"

        bash_profile_file="${HOME}/.bash_profile"
        zshrc_file="${HOME}/.zshrc"
        profile_file="${HOME}/.profile"
        bashrc_file="${HOME}/.bashrc"

        if [ -z "$_NIXSTALL_PATHS" ]; then

            ## currently only updating two files
            for file in $bash_profile_file $zshrc_file; do

                ## check for existance of this line already
                ## this will match even in comments, which is okay because if its commented, probably user has deliberately done so
                if ! grep -q $__nixstall_script $file; then
                    echo "updating $file"
                    echo -e "\n# Added by nixstall, don't remove unless you know what you are doing" >> $file
                    echo -e "[[ -s \"${__nixstall_script}\" ]] && source \"${__nixstall_script}\"\n" >> $file
                fi
            done
        fi

        ## if only self was to be installed, we are done and exit now
        if [[ "$1" == "self" ]]; then
            echo "You may need to open a new terminal for changes to reflect!"
            exit 0
        fi
    fi

    ## TODO validate if the archive has right directory strucutre, i.e. it contains `bin`

    ################# OTHER OPTIONS ###################

    ################# GET REMOTE ARCHIVE ###################
    ## we have to download the archive
    if [[ "$1" == "get" ]] && [ -n "$2" ];then
        # FILE=${2##*://*/}
        ## currently supporting only zip
        ## since file name is constant, this command is not suitable for running from multiple processes simultaneously
        FILE="/tmp/nixstall-archive.zip"
        curl -L -o "$FILE" "$2"
        echo "archive file downloaded as : $FILE, copy it if you want to save it"

        # let unzip be interactive when replacing the existing file
        unzip -d $__nixstall_dir $FILE

        echo "Downloaded archive saved as: $FILE, copy it if you want to save it"

    ################# GET LOCAL ARCHIVE ###################
    ## $1 is a file (zip) TODO more formats
    elif [[ -s "$1" ]];then

        unzip -d $__nixstall_dir $1

    ################# LINK DIRECT PATH ###################
    elif [[ "$1" == "link" ]]; then ## link to existing dir
        if [ -d "$2" ]; then
            echo "$2 must be a valid directory path"
            exit 2
        fi

        ln -s $2 $__nixstall_dir

    ################# RELOAD (UPDATE PATH) ###################
    elif [[ "$1" == "reload" ]] || [[ "$1" == "load" ]] || [[ "$#" == "0" ]];then

        if [ -d "$__nixstall_dir" ] ; then
            ## Find all dirs having bin/ dir
            for dir in $(find -L ${__nixstall_dir} -maxdepth 2 -type d -name bin); do
                _NIXSTALL_PATHS="${_NIXSTALL_PATHS:+"$_NIXSTALL_PATHS:"}$dir"

                # Add to path only if not already present in PATH
                # http://superuser.com/a/39995/66921
                 if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
                    PATH="${PATH:+"$PATH:"}$dir"
                fi
            done
        fi

    ################# LIST INSTALLED PACKAGES ###################
    elif [[ "$1" == "list" ]]; then ## list

        ls $__nixstall_dir

    else
        # TODO -- print help
        echo "not a valid usage"
        exit 1
    fi

}

## Call nixstall, in case of sourcing, it will just set PATH variable.
nixstall "$@"
