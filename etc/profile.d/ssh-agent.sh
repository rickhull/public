if [ -d ~/.ssh ] && [ "$EUID" -gt 999 ]; then

    # we only care about our own agents which were started by init (PID 1)
    PGREP_FLAGS="-u $EUID --parent 1"

    run_agent () {
	pkill ssh-agent $PGREP_FLAGS
	ssh-agent > ~/.ssh/agent
	chmod 600 ~/.ssh/agent
    }


    # do I already have a single ssh-agent running?
    # if so, does its PID match ~/.ssh/agent?
    # if so, source ~/.ssh/agent
    # otherwise, kill any existing agent and write to ~/.ssh/agent

    AGENT_PID=`pgrep ssh-agent $PGREP_FLAGS`

    if [ -z "$AGENT_PID" ] || \
	   [ `echo "$AGENT_PID" | wc -l` -ne 1 ] || \
	   [ ! -e ~/.ssh/agent ] || \
	   ! grep "$AGENT_PID" ~/.ssh/agent > /dev/null
    then
	run_agent
    fi

    source ~/.ssh/agent
    ssh-add -l # list keys
fi
