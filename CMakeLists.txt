# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

enable_testing()
project(otss_validation)


set(GCC_PATH /usr/bin)

set(MAIN_SOURCES
        ${CMAKE_SOURCE_DIR}/src/main.cc
        )


include_directories(
        ${CMAKE_SOURCE_DIR}
        )


set(CMAKE_C_COMPILER ${GCC_PATH}/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${GCC_PATH}/arm-linux-gnueabihf-g++)

# Dialect flags
set(GCC_DIALECT_FLAGS "-fmessage-length=0 -fsigned-char")
#  -fmessage-length=0                   Each error message is not line wrapped
#  -fsigned-char                        'char' type is signed by default

# C Standard and Warnings
set(GCC_C_FLAGS "-std=gnu11 -march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9")
#  -std=gnu11                           Allow the gnu extensions with C11
#  -march=armv7-a                       Specifies ARM architecture
#  -mthumb-interwork                    Generate code which supports calling between ARM and Thumb instruction sets
#  -mfloat-abi=hard                     Specifies hard floating-point ABI
#  -mfpu=neon                           Specifies hard floating-point hardware available on target
#  -mtune=cortex-a9                     Tells TCC to tune performance of code as if target were of this type

# C++ Option flags
set(GCC_CPP_FLAGS "-fabi-version=0 -fno-exceptions -fno-use-cxa-atexit -fno-threadsafe-statics -std=gnu++11 -static -pthread -Wl,--whole-archive -lpthread -Wl,--no-whole-archive -march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9")
#  -fabi-version=0                      Use ABI version 0
#  -fno-exceptions                      Don't use C++ exception handlers
#  -fno-use-cxa-atexit                  Register destructors with atexit function
#  -fno-threadsafe-statics              Don't use extra code to make static initialization threadsafe
#  -std=gnu++11                         Allow the gnu extensions with C++11
#  -pthread                             Use statically linked pthread library with bug fix below:
#      -Wl,--whole-archive                  Need to link the entire libpthread.a, which whole-archive forces
#          -lpthread                        See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=52590#c4
#      -Wl,--no-whole-archive
#  -march=armv7-a                       Specifies ARM architecture
#  -mthumb-interwork                    Generate code which supports calling between ARM and Thumb instruction sets
#  -mfloat-abi=hard                     Specifies hard floating-point ABI
#  -mfpu=neon                           Specifies hard floating-point hardware available on target
#  -mtune=cortex-a9                     Tells TCC to tune performance of code as if target were of this type

# Optimization flags
set(GCC_OPTIMIZATION_FLAGS "-ffunction-sections -fdata-sections")
#  -ffunction-sections                  Put each function into own section (for linker optimization)
#  -fdata-sections                      Put each data item into own section (for linker optimization)

set(GCC_OPTIMIZATION_FLAGS_RELEASE "-O2 -Wno-unused-result")
#  -Wno-unused-result                   Ignore unused result warnings (e.g., 'system' call result)

# Warnings flags
set(GCC_WARNING_FLAGS "-Wall -Wextra -Werror -Wno-unused-parameter -Wconversion -Wsign-conversion")
#  -Wall                                Enable warnings about questionable constructions
#  -Wextra                              Enable more warnings not covered by Wall
#  -Werror                              Make all warnings into errors
#  -Wno-unused-parameter                Ignore unused parameter warnings
#  -Wconversion                         Warn for implicit conversions that may alter a value.
#  -Wsign-conversion                    Sign conversion warnings ignored in C++ unless explicitly enabled.

# Debug flags
set(GCC_DEBUG_FLAGS "-g3")
#  -g3                                  Produces debugging information

# Linker flags
set(GCC_LINK_FLAGS "-u _printf_float -pthread --static")
#  -u _printf_float                     Linker flag for floating point printf and sprintf
#  -pthread                             Use statically linked pthread library
#  --static                             Use static linking for all libraries

set(CMAKE_C_FLAGS "${GCC_DIALECT_FLAGS} ${GCC_OPTIMIZATION_FLAGS} ${GCC_C_FLAGS} ${GCC_WARNING_FLAGS} ${GCC_DEBUG_FLAGS}")
set(CMAKE_CXX_FLAGS "${GCC_DIALECT_FLAGS} ${GCC_OPTIMIZATION_FLAGS} ${GCC_WARNING_FLAGS} ${GCC_DEBUG_FLAGS} ${GCC_CPP_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${GCC_DIALECT_FLAGS} ${GCC_OPTIMIZATION_FLAGS} ${GCC_WARNING_FLAGS} ${GCC_DEBUG_FLAGS} ${GCC_LINK_FLAGS}")



# Main executable build
set(MAIN_BUILD ${CMAKE_PROJECT_NAME})

add_executable(${MAIN_BUILD} ${MAIN_SOURCES})


# Lint target
add_custom_command(OUTPUT lint-command
        COMMAND python ${CMAKE_SOURCE_DIR}/tools/cpplint.py --verbose=0 --linelength=132
                --filter=-readability/braces,-whitespace/braces,-whitespace/end_of_line,-whitespace/newline,-readability/casting,-runtime/references,-whitespace/parens
                --root=${CMAKE_SOURCE_DIR}
                ${CMAKE_SOURCE_DIR}/include/*.h
                ${CMAKE_SOURCE_DIR}/src/*.cc
        )
set_source_files_properties(lint-command SYMBOLIC 1)
add_custom_target(lint ALL DEPENDS lint-command)
