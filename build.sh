#!/bin/bash

#*********************************************************************
#  Copyright © 2016 Continuum

# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#   a. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#   b. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#   c. Neither the name of Continuum nor the names of its contributors
#      may be used to endorse or promote products derived from this software
#      without specific prior written permission.


# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.

# Created by Adam Casey 2016
#*********************************************************************/

CLEAN=false
NUMBER_MAKE_THREADS=4
BUILD_TYPE="DEBUG"
BUILD_TARGET="all"

usage() {
    cat <<EOF
$0 [ options ]

Automates the build process using cmake and make.

By default, the build process will clear the "build" folder,
then "make all" in DEBUG mode with 4 threads.

Options:
    (--clean | -c)
        Forces the cleaning of the "build" folder.

    (--num-threads | -j) [ value ]
        Overrides the number of threads used by make (default: 4).

    (--release | -r)
        Runs a RELEASE version of the build process.

    (--target | -t) [ target ]
        Determines the make target (default: all).

Examples:
    > $0 -c -r -t hotsprings

        Perform a release build of the hotsprings target and cleaning the
        "build" folder first.

    > $0 -c -j 1

        Perform a full build while cleaning the "build" folder first,
        and uses make with only 1 thread.
EOF
}

while [ ! $# -eq 0 ]
do
    case "$1" in
        --help | -h) shift
            usage
            exit 0
            ;;

        --clean | -c) shift
            CLEAN=true
            ;;

        --num-threads | -j) shift
            NUMBER_MAKE_THREADS=$1
            shift
            ;;

        --release | -r) shift
            BUILD_TYPE="RELEASE"
            ;;

        --target | -t) shift
            BUILD_TARGET=$1
            shift
            ;;

        # Matches on any unrecognized options (start with "-")
        -*) shift
            usage
            exit 1
            ;;

        # Matches on anything else (e.g., extraneous arguments)
        *) break
            ;;
    esac
done

# This is necessary for CMAKE to put its built files in "build"

export PROJECT_ROOT=`pwd`

if [ "$CLEAN" == true ]; then
    # Remove any existing build artifacts
    rm -rf build
fi

# Create a new directory (if needed) for build artifacts
mkdir -p build

# Execute the 'make' to build the test binary and run the tests
(cd build; cmake -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" ..; make -j "${NUMBER_MAKE_THREADS}" "${BUILD_TARGET}")
