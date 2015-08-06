# WARNING: this file is sourced using `sh` and not just `bash`
#          DO NOT USE bashisms unless you want to have a mystery on your hands

SSH_DIR="$HOME/.ssh"
USERID=$(id -u)  # UID and EUID are empty when loaded by graphical shell

if [ -d "$SSH_DIR" ] && [ "$USERID" -gt 999 ]; then
    AGENT_FILE="$SSH_DIR/agent"       # stores the output of ssh-agent
    PGREP_FLAGS="-u $USERID --parent 1" # only our agent(s), started by init
    ERROR=""

    agent_pid() {
	pgrep ssh-agent $PGREP_FLAGS
    }
    run_agent () {
	pkill ssh-agent $PGREP_FLAGS
	ssh-agent > $AGENT_FILE
	chmod 600 $AGENT_FILE
	ERROR=""
    }

    if [ ! -e $AGENT_FILE ]; then ERROR="no agent file"; fi
    if [ $(agent_pid | wc -l) -ne 1 ]; then ERROR="num_agents != 1"; fi
    if [ -n "$ERROR" ]; then run_agent; fi

    # at this point, we have an agent file, and one agent running
    # source the agent file
    . $AGENT_FILE

    # validate PID and SOCK
    if [ "$SSH_AGENT_PID" != $(agent_pid) ]; then ERROR="PID mismatch"; fi
    if [ ! -e "$SSH_AUTH_SOCK" ]; then ERROR="SSH_AUTH_SOCK file missing"; fi
    if [ -n "$ERROR" ]; then
	run_agent
	. $AGENT_FILE
    fi

    unset AGENT_FILE PGREP_FLAGS ERROR agent_pid run_agent
    ssh-add -l # list keys
fi

unset SSH_DIR USERID
