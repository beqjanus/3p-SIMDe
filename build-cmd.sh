#!/usr/bin/env bash

cd "$(dirname "$0")" 

echo "Building SIMe header-only library"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e
# complain about unset env variables
set -u

# Check autobuild is around or fail
if [ -z "$AUTOBUILD" ] ; then 
    exit 1
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    autobuild="$(cygpath -u $AUTOBUILD)"
else
    autobuild="$AUTOBUILD"
fi

top="$(pwd)"
stage_dir="$(pwd)/stage"
mkdir -p "$stage_dir"
tmp_dir="$(pwd)/tmp"
mkdir -p "$tmp_dir"

package_name="SIMDe"
package_repo="https://github.com/simd-everywhere/simde-no-tests.git"
# set package_folder to be the last directory in the package_repo url
package_folder=$(basename "$package_repo" .git)

# Load autobuild provided shell functions and variables
srcenv_file="$tmp_dir/ab_srcenv.sh"
"$autobuild" source_environment > "$srcenv_file"
. "$srcenv_file"

build_id=${AUTOBUILD_BUILD_ID:=0}
git submodule add https://github.com/simd-everywhere/simde-no-tests
cd ${package_folder}
package_version="$(git describe --tags --match 'v[0-9]\.[0-9]\.[0-9]' --abbrev=0)"
cd ..

echo "${package_version}.${build_id}" > "${stage_dir}/VERSION.txt"

mkdir -p "${stage_dir}/include/${package_name}"

cp -r ./${package_folder} "${stage_dir}/include/${package_name}/"

mkdir -p "${stage_dir}/LICENSES"
cp ${package_folder}/COPYING "${stage_dir}/LICENSES/${package_name}.txt"