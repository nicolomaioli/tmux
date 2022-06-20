alias ti='tmux new-session -d'
alias ta='tmux a -t'
alias tk='tmux kill-session -t'
alias tl='tmux list-sessions'

function tn {
	TMUX=$(pgrep tmux)

	if [ -z $TMUX ]
	then
		tmux new-session -d
	fi

	FOLDER=${PWD##*/}
	SESSION=$(print -r -- ${FOLDER:gs/\./\_})
	SESSION_EXISTS=$(tmux list-sessions | grep $SESSION)

	if [ -z "$SESSION_EXISTS" ]
	then
		tmux new-session -d -s $SESSION
		tmux rename-window -t 0 'EDITOR'
		tmux send-keys -t 'EDITOR' $EDITOR C-m
		tmux new-window -t $SESSION:1 -n 'TERM'
	fi

	tmux attach-session -t $SESSION:0
}
