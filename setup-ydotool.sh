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

USER_HOME="$HOME";

[[ ! -z "$SUDO_USER" ]] &&	\
[[ "$HOME" == "/root" ]] &&	\
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6);

[[ -z "$PLATFORM_ROOT_DIRECTORY_PATH" ]] &&				\
[[ "$PLATFORM_ROOT_DIRECTORY_PATH" == "$PRDP" ]] &&		\
[[ "${PLATFORM_PARENT_DIRECTORY@a}" == *x* ]] &&		\
[[ ! -z "$PLATFORM_PARENT_DIRECTORY" ]] &&				\
PLATFORM_ROOT_DIRECTORY_PATH="$USER_HOME/$PLATFORM_PARENT_DIRECTORY";

[[ -z "$PLATFORM_ROOT_DIRECTORY_PATH" ]] &&				\
[[ "$PLATFORM_ROOT_DIRECTORY_PATH" == "$PRDP" ]] &&		\
[[ -z "$PLATFORM_PARENT_DIRECTORY" ]] &&				\
PLATFORM_ROOT_DIRECTORY_PATH="$USER_HOME";

PRDP="$PLATFORM_ROOT_DIRECTORY_PATH";

TARGET_WORKING_DIRECTORY="$(pwd)";

[[ -z "$TRASH_DIRECTORY" ]] &&	\
TRASH_DIRECTORY=$(mktemp -d);

load-setting( ){
	set -o allexport;

	[[ -f "$TARGET_WORKING_DIRECTORY/.env" ]] &&	\
	source "$TARGET_WORKING_DIRECTORY/.env";

	[[ -f "$PLATFORM_ROOT_DIRECTORY_PATH/.env" ]] &&	\
	source "$PLATFORM_ROOT_DIRECTORY_PATH/.env";

	set +o allexport;
};

[[ -f "$TARGET_WORKING_DIRECTORY/.env" ]] &&	\
load-setting;

[[ -n "$MACHINE_GRASS" ]] &&	\
echo -e "$MACHINE_GRASS\n" | sudo -S --validate;

[[ -x $(which ydotool) ]] &&						\
[[ -d "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool" ]] &&	\
[[ -d "$TRASH_DIRECTORY" ]] &&						\
mv --force "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool" "$TRASH_DIRECTORY";

[[ "$CONTAINER_CONTEXT_STATUS" = true ]] &&	\
tmux has-session -t ydotoold 2>/dev/null;
[[ ! $? ]] &&	\
tmux kill-session -t ydotoold;

[[ -x $(which ydotool) ]] &&	\
sudo apt-get purge --auto-remove ydotool --yes;

[[ ! -x $(which ydotool) ]] &&	\
sudo apt-get install			\
git								\
cmake							\
scdoc							\
pkg-config						\
checkinstall					\
supervisor						\
--yes;

[[ ! -x $(which ydotool) ]] &&	\
git -C "$PLATFORM_ROOT_DIRECTORY_PATH" clone https://github.com/ReimuNotMoe/ydotool.git;

[[ ! -x $(which ydotool) ]] &&	\
mkdir -p "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool/build";

[[ ! -x $(which ydotool) ]] &&	\
cd "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool/build";

[[ ! -x $(which ydotool) ]] &&				\
cmake										\
-S "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool"	\
-B "$PLATFORM_ROOT_DIRECTORY_PATH/ydotool/build";

[[ ! -x $(which ydotool) ]] &&								\
sudo checkinstall											\
--pkgname="ydotool"											\
--pkgsource="$PLATFORM_ROOT_DIRECTORY_PATH/ydotool/build"	\
--pakdir="$PLATFORM_ROOT_DIRECTORY_PATH/ydotool"			\
--deldoc=yes												\
--deldesc=yes												\
--delspec=yes												\
--default													\
make install;

[[ -d $TARGET_WORKING_DIRECTORY ]] &&	\
cd "$TARGET_WORKING_DIRECTORY";

[[ -x $(which ydotool) ]] &&	\
sudo bash -c "cat > /etc/supervisor/conf.d/ydotoold.conf" <<'EOF'
[program:ydotoold]
command=/usr/local/bin/ydotoold
autostart=true
autorestart=true
stderr_logfile=/var/log/ydotoold.error.log
stdout_logfile=/var/log/ydotoold.output.log
EOF

[[ "$CONTAINER_CONTEXT_STATUS" = true ]] &&	\
[[ -x $(which ydotool) ]] &&				\
tmux new -d -s ydotoold &&					\
tmux send-keys -t ydotoold "sudo $(which supervisord) -n" Enter;

[[ "$CONTAINER_CONTEXT_STATUS" != true ]] &&	\
[[ -x $(which ydotool) ]] &&					\
[[ -x $(which systemctl) ]] &&					\
sudo systemctl restart supervisor;

[[ "$CONTAINER_CONTEXT_STATUS" != true ]] &&	\
[[ -x $(which ydotool) ]] &&					\
[[ -x $(which service) ]] &&					\
sudo service supervisor restart;

set -o history;
