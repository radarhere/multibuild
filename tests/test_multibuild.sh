# Test multibuild utilities
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x
source common_utils.sh
source tests/utils.sh

if [ -n "$TEST_BUILDS" ]; then
    if [ -n "$IS_OSX" ]; then
        MB_PYTHON_VERSION=${MB_PYTHON_VERSION:-$PYTHON_VERSION}
        source tests/test_library_builders.sh
    elif [ ! -x "$(command -v docker)" ]; then
        echo "Skipping build tests; no docker available"
    else
        touch config.sh
        source travis_linux_steps.sh
        build_multilinux $PLAT "source tests/test_library_builders.sh"
    fi
fi

source tests/test_supported_wheels.sh

# Exit 1 if any test errors
barf
# Don't need Travis' machinery trace
set +x
