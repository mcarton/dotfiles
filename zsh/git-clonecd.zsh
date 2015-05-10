## git clonecd

function _git_cd() {
    shift # remove the 'clone'
    tmp=$(mktemp /tmp/git-clonecd-XXX)

    git clone --progress $@ 2>&1 | tee "$tmp"

    repo=$(head -n 1 "$tmp" | sed -e 's/Cloning into '\''\(.*\)'\''.*/\1/')
    cd "$repo"

    rm "$tmp"
}

function git() {
    case $* in
        # Cannot be a simple git alias because of the cd
        clonecd* ) _git_cd "$@" ;;
        * ) command git "$@" ;;
    esac
}
