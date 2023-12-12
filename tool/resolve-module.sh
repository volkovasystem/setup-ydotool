#!/usr/bin/env bash

BUILT_MODULE_FILE_PATH="$MODULE_BUILD_DIRECTORY_PATH/$MODULE_NAMESPACE_VALUE.js";
MODULE_FILE_PATH="$MODULE_ROOT_DIRECTORY_PATH/$MODULE_NAMESPACE_VALUE.js";

[[ -f "$BUILT_MODULE_FILE_PATH" ]] &&	\
mv --force "$BUILT_MODULE_FILE_PATH" "$MODULE_FILE_PATH";

return 0;
