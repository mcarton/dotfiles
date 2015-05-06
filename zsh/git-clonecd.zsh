## git clonecd

function _git_cd() {
    repo=${@: -1}
    tmp=$(mktemp git-clonecd-XXX)

    git clone --progress $repo 2>&1 | tee $tmp

    repo=$(head -n 1 $tmp | sed -e 's/Cloning into '\''\(.*\)'\''.*/\1/')
    cd ${repo}
}

function git() {
    case $* in
        # Cannot be a simple git alias because of the cd
        clonecd* ) _git_cd "$@" ;;
        * ) command git "$@" ;;
    esac
}
