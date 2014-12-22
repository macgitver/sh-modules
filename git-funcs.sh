#! /bin/sh

# Configures a repository for minimal checkout (sparse-checkout)
# and performs a checkout on the given $ref afterwards
Git_SparseCheckout () {
    wd=$1           # working directory
    git_dir=$1/$2   # ".git" or ".git/modules/<submodule_path>"
    ref=$3          # reference to checkout

    echo " * performing sparse checkout in $wd ..."
    echo '.git*' > $git_dir/info/sparse-checkout

    cd $wd
    git config core.sparsecheckout true
    git checkout -f $ref
}

# Performs a forced full checkout on a single repository.
Git_ForcedCheckout () {
    wd=$1
    ref=$2

    echo " * performing full forced checkout in $wd ..."

    cd $wd
    git checkout -f --ignore-skip-worktree-bits $ref
}

# Clones the repository directly into the given directory
# without performing a checkout.
Git_Get () {
    wd=$1
    repo_url=$2
    ref=$3

    echo " * getting sources from $repo_url ..."

    if ! [ -d $wd ] ; then
        mkdir -p $wd && cd $wd
        git clone --branch $ref --depth=2 --no-checkout ${repo_url} .

    else
        cd $wd
        git fetch origin
        git update-ref refs/heads/$ref origin/$ref
    fi
}


Git_ForcedModuleUpdate () {
    wd=$1

    echo " * Updating submodules ..."
    cd $wd
    git submodule update --force --init --recursive --depth=2
    git submodule foreach --recursive 'git reset --hard && git clean -dfx'
}

Git_SparseCheckoutModules () {
    echo '* Note: function not implemented Git_SparseCheckoutModules(): Doing nothing!'

#    wd=$1
#    GIT_MODULES=$( git submodule --quiet foreach --recursive 'echo $path && git config core.sparsecheckout true' )
#    for m in $GIT_MODULES
#    do
#        configureSparseCheckout .git/modules/$m
#    done
#    git submodule foreach 'git checkout HEAD'
}


# internally used to extract files from a single git repository
# $1 => path to main repository's work-tree
# $2 => relative path to submodule (. for main repository)
# $3 => destination folder
# $4 => prefix-directory in the destination folder
_Git_ExportRepo () {
    wd=$1
    repo=$2
    dest_dir=$3
    prefix=$4/$repo

    cd $wd/$repo
    echo " * adding prefix $prefix to archive"
    git archive --prefix $prefix/ --format tar HEAD | ( cd $dest_dir && tar xf - )
}

# extract files from git repository and submodules
# $1 => path to main repository's work-tree
# $2 => destination folder
# $2 => subdirectory prefix (i.e. the repo name) in the destination folder
Git_ExportRepo () {
    wd=$1
    dest_dir=$2
    prefix=$3

    echo " * extracting from $wd to $dest_dir/$prefix"

    cd $wd
    _Git_ExportRepo $wd . $dest_dir $prefix

    cd $wd
    for sm in $(git submodule status --recursive | awk '{ print $2 }') ; do
        _Git_ExportRepo $wd $sm $dest_dir $prefix
    done
}
