if [ -d ~/.ssh ]; then

    function run_agent {
	pkill ssh-agent -e $EUID
	ssh-agent > ~/.ssh/agent
	chmod 600 ~/.ssh/agent
	echo "ssh-add your keys"
    }
    

    # do I already have an ssh-agent running?
    # if so, does its PID match ~/.ssh/agent?
    # if so, source ~/.ssh/agent
    # otherwise, kill any existing agent and write to ~/.ssh/agent

    AGENT_PID=`pgrep ssh-agent -u $EUID`

    if [ -z "$AGENT_PID" ]; then
	run_agent
    elif [ ! -e ~/.ssh/agent ]; then
	run_agent
    elif ! grep "$AGENT_PID" ~/.ssh/agent > /dev/null; then
	run_agent
    fi

    source ~/.ssh/agent
fi
