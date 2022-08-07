alias ti='tmux new-session -d'
alias ta='tmux a -t'
alias tk='tmux kill-session -t'
alias tl='tmux list-sessions'
alias tpk='tmux kill-server'

function sn {
	TARGET=$(find ~/code ~/.config -mindepth 1 -maxdepth 1 -type d | fzf)

	if [[ -z $TARGET ]]
	then
		exit 0
	fi

	tn $TARGET
}

function tn {
	if [[ $# -eq 1 ]]
	then
		TARGET=$1
	else
		TARGET=$PWD
	fi

	BASEPATH=${TARGET##*/}
	SESSION=$(print -r -- ${BASEPATH:gs/\./\_})
	SESSION_EXISTS=$(tmux list-sessions 2>/dev/null | grep $SESSION)

	if [[ -z $SESSION_EXISTS ]]
	then
		tmux new-session -d -s $SESSION -c $TARGET
		tmux rename-window -t $SESSION:0 'EDITOR'
		tmux send-keys -t $SESSION:'EDITOR' $EDITOR C-m
		tmux new-window -t $SESSION:1 -n 'TERM' -c $TARGET
	fi

	if [[ -z $TMUX ]]
	then
		tmux attach-session -t $SESSION:0
	else
		tmux switch -t $SESSION:0
	fi
}
