


usage="$0 source_repo [target_repo]"
if [[ $# < 1 ]]; then
    echo $usage
    exit 1
fi

rootdir=`dirname $0`
cachedir=$rootdir/gitmigratecache
githubusername=categorical
githubpassword=$githubpassword
source=$1
dest=$2
rename=$rename

_createrepogithub(){
    local -r n=$1
    [ -z "$githubpassword" ]||githubusername+=":$githubpassword"
    resp=$(set -x;curl -u "$githubusername" \
        'https://api.github.com/user/repos' \
        -d '{"name":"'"$n"'"}')
    ec=$?
    local d=$(echo "$resp"|grep 'ssh_url')
    d=${d#*\"ssh_url\": }
    d=${d#\"};d=${d%\",}
    if [ "$ec" -ne 0 ]||[ -z "$d" ];then
        printf "\e[31merror: \e[0m%s\n" "$resp" >&2
        exit 1;
    fi
    eval "$2"'=$d'
    printf "\e[32minfo: \e[0mCreated GitHub Repository: %s\n" "$dest" >&2 
}
_ensuredest(){
    if [ -z "$dest" ];then
        local name=${source##*/}
        [ -z "$rename" ]||name="$rename"
        _createrepogithub "$name" 'dest'
    fi
}

_migrate(){
    _ensuredest

    hg clone $source $cachedir
    pushd $cachedir
    printf "\e[32minfo: \e[0mCloned: %s-->%s\n" "${source##*/}" "$cachedir" >&2
    git init
    cat <<-EOF >.gitignore
	.hg
	EOF
    git add --all
    git commit -m 'hg migrate'
    git remote add origin $dest
    git push -u origin master
    popd

    (set -x;rm -rf $cachedir)
}

_migrate


