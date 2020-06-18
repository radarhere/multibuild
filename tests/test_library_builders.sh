# Test some library builders

# The environment
uname -a

if [ -n "$IS_OSX" ]; then
    # Building on macOS
    export BUILD_PREFIX="${PWD}/builds"
    rm_mkdir $BUILD_PREFIX
    # configure_build.sh sourced in test_multibuild.sh
    source library_builders.sh
else
    # Building on Linux
    # Glibc version
    ldd --version
    # configure_build.sh, library_builders.sh sourced in
    # docker_build_wrap.sh
fi

source tests/utils.sh

start_spinner

# We need to find a failable test for build_github
# It needs a standalone C library with ./configure script.
# E.g. arb (below) requires a couple of other libraries.
# Run here just for the output, even though they fail.
echo "TORCH -1"
(set +e ;
    build_github fredrik-johansson/arb 2.17.0 ;
    build_github glennrp/libpng v1.6.37 ;
    build_github wbhart/mpir mpir-3.0.0
    )
echo "TORCH 7"
suppress build_freetype
echo "TORCH 8"
suppress build_libyaml
if [ -z "$IS_OSX" ]; then
    # Gives compiler conformance error on macOS Sierra:
    # https://gist.github.com/5e20e137ea51fa8ca9fc443191f9d463
    # https://gist.github.com/ad86c474f3c0b7ec74290bb13f9414af
    suppress build_lzo
fi
suppress build_ragel
if [ -z "$IS_OSX" ]; then
    # already installed in the macOS image, so `brew install cfitsio` fails
    suppress build_cfitsio
fi
suppress build_new_zlib
suppress build_hdf5

[ ${MB_PYTHON_VERSION+x} ] || ingest "\$MB_PYTHON_VERSION is not set"
[ "$MB_PYTHON_VERSION" == "$PYTHON_VERSION" ] || ingest "\$MB_PYTHON_VERSION must be equal to \$PYTHON_VERSION"

stop_spinner

# Exit 1 if any test errors
barf
