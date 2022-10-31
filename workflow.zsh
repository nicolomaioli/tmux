alias ta='tmux a -t'
alias tk='tmux kill-session -t'
alias tl='tmux list-sessions'
alias tpk='tmux kill-server'

function sn {
	# Use fzf to select a project folder from a list
	# TODO: this should take from a parameter instead
	TARGET=$(find ~/Code ~/.config -mindepth 1 -maxdepth 1 -type d | fzf)

	if [[ -z $TARGET ]]
	then
		echo "No available target, abort!"
		return 1
	fi

	tn $TARGET
}

function tn {
	# Where the real magic happens!

	# Argument should be an absolute path.
	# Use PWD if no arguments are given
	if [[ $# -eq 1 ]]
	then
		TARGET=$1
	else
		TARGET=$PWD
	fi

	# Check that $TARGET is a valid path
	if ! [[ -d $TARGET ]]
	then
		echo "Invalid target: $TARGET, abort!"
		return 1
	fi

	# Create a session name using $TARGET BASEPATH
	# Replace all `.` with `_` because tmux no likey
	# Check if the session already exists
	BASEPATH=${TARGET##*/}
	SESSION=$(print -r -- ${BASEPATH:gs/\./\_})
	SESSION_EXISTS=$(tmux list-sessions 2>/dev/null | grep $SESSION)

	# Create the session if it doesn't exists, add two windows:
	# 0: $EDITOR
	# 1: cd $TARGET
	if [[ -z $SESSION_EXISTS ]]
	then
		tmux new-session -d -s $SESSION -c $TARGET
		tmux send-keys -t $SESSION:0 $EDITOR C-m
		tmux new-window -t $SESSION:1 -c $TARGET
	fi

	# Avoid nested sessions
	# If inside tmux, switch to new session
	# If outsiede tmux, attach to the newly created session
	if [[ -z $TMUX ]]
	then
		tmux attach-session -t $SESSION:0
	else
		tmux switch -t $SESSION:0
	fi
}
