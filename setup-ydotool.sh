#!/usr/bin/env bash

#	 @license:module:
#	 	MIT License
#
#	 	Copyright (c) 2023-present Richeve S. Bebedor <richeve.bebedor@gmail.com>
#
#	 	@license:copyright:
#	 		Richeve S. Bebedor
#
#	 		<@license:year-range:2023-present;>
#
#	 		<@license:contact-detail:richeve.bebedor@gmail.com;>
#	 	@license:copyright;
#
#	 	Permission is hereby granted, free of charge, to any person obtaining a copy
#	 	of this software and associated documentation files (the "Software"), to deal
#	 	in the Software without restriction, including without limitation the rights
#	 	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	 	copies of the Software, and to permit persons to whom the Software is
#	 	furnished to do so, subject to the following conditions:
#
#	 	The above copyright notice and this permission notice shall be included in all
#	 	copies or substantial portions of the Software.
#
#	 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	 	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	 	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	 	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	 	SOFTWARE.
#	 @license:module;

set +o history;

SHELL_STATE="$(set +o)";

#; @todo-note: Modify parameter to include flow for optional and required.;
#; @todo-note: Modify to add fallback and handler for optional and required parameter.;

SHORT_PARAMETER_LIST=(	\
	h:					\
);

LONG_PARAMETER_LIST=(	\
	help:				\
);

SHORT_PARAMETER_LIST=$(echo $(IFS='';echo "${SHORT_PARAMETER_LIST[*]// /}";IFS=$' \t\n'));
LONG_PARAMETER_LIST=$(echo $(IFS='';echo "${LONG_PARAMETER_LIST[*]// /}";IFS=$' \t\n'));

PARAMETER="$(						\
getopt								\
--quiet								\
--alternative						\
--options $SHORT_PARAMETER_LIST		\
--longoptions $LONG_PARAMETER_LIST	\
-- "$@"								\
)";

[[ $? > 0 ]] && \
exit 1;

HELP_PROMPT_STATUS=false;

eval set -- "$PARAMETER";

while true;
do
	case "$1" in
		-h | --help )
			HELP_PROMPT_STATUS=true;
			shift 2
			;;

		-- )
			shift;
			break
			;;
		* )
			break
			;;
	esac
done

set +vx; eval "$SHELL_STATE";

TARGET_WORKING_DIRECTORY="$(pwd)";

load-setting( ){
	set -o allexport;
	[[ -f "$TARGET_WORKING_DIRECTORY/.env" ]] &&	\
	source "$TARGET_WORKING_DIRECTORY/.env";
	set +o allexport;
};

[[ -f "$TARGET_WORKING_DIRECTORY/.env" ]] &&	\
load-setting;

[[ -n "$MACHINE_GRASS" ]] &&	\
echo -e "$MACHINE_GRASS\n" | sudo -S apt-get update;


set -o history;
