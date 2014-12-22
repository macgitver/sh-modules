#! /bin/sh

# prepare the RAD-Tools (always fetch master branch)
RadTools_Install () {
    git_src=$1
    install_dir=$2

    rad_tools_build=$git_src/build

    echo " * Installing RAD-Tools ..."

    Git_Get $git_src 'git@github.com:cunz-rad/RAD-Tools.git' master &&
    Git_ForcedCheckout $git_src master &&

    rm -rf $rad_tools_build
    mkdir -p $rad_tools_build
    cd $rad_tools_build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$install_dir -- .. &&
        make -s install &&
        echo " * RAD-Tools installed to $RAD_TOOLS_EXEC"
}
