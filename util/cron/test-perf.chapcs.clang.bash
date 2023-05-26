#!/usr/bin/env bash
#

CWD=$(cd $(dirname $0) ; pwd)

export CHPL_TEST_PERF_CONFIG_NAME='chapcs'

source $CWD/common-perf.bash

# Load LLVM Spack install to get clang in PATH
eval `$CHPL_DEPS_SPACK_ROOT/bin/spack load --sh   llvm`
unset CC
unset CXX

export CHPL_HOST_COMPILER=clang
export CHPL_TARGET_COMPILER=clang

export CHPL_NIGHTLY_TEST_CONFIG_NAME="perf.chapcs.clang"

SHORT_NAME=clang
START_DATE=09/10/16

perf_args="-performance-description $SHORT_NAME -performance-configs default:v,$SHORT_NAME:v -sync-dir-suffix $SHORT_NAME"
perf_args="${perf_args} -performance -numtrials 1 -startdate $START_DATE"

$CWD/nightly -cron ${nightly_args} ${perf_args}
