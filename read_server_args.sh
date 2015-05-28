set +x

script=$1
shift

FLOCKER_CONTROL_NODE=0
FLOCKER_AGENT_NODE=1
FLOCKER_CONTROL_ADDR=
FLOCKER_BACKEND=zfs
FLOCKER_REPO=
FLOCKER_OS=fedora-20

while [[ $# > 0 ]]
do
	key="$1"

	case $key in
	--os)
		if [[ $# < 2 ]]; then
			echo "$script: --os option requires an argument" >&2
			exit 1
		fi
	    FLOCKER_OS="$2"
	    case "${FLOCKER_OS}" in
	    centos-7 | fedora-20 | ubuntu-14.04)
			;;
		ubuntu-15.04)
			echo "Ubuntu 15.04 support is experimental!" >&2
			;;
		*)
			echo "$script: --os option '${FLOCKER_OS}' unsupported" >&2
			exit 1
			;;
		esac
	    shift
		;;
	--backend)
		if [[ $# < 2 ]]; then
			echo "$script: --backend option requires an argument" >&2
			exit 1
		fi
	    FLOCKER_BACKEND="$2"
	    shift
		;;
	--control)
	    FLOCKER_CONTROL_NODE=1
	    ;;
	--no-agent)
	    FLOCKER_AGENT_NODE=0
	    ;;
	--master)
		if [[ $# < 2 ]]; then
			echo "$script: --master option requires an argument" >&2
			exit 1
		fi
	    FLOCKER_CONTROL_ADDR="$2"
	    shift
	    ;;
	--repo)
		if [[ $# < 2 ]]; then
			echo "$script: --repo option requires an argument" >&2
			exit 1
		fi
	    FLOCKER_REPO="$2"
	    shift
		;;
	*)
	    echo "Usage: $script [ --control ] [ --no-agent ] [ --master <control-node-ip> ]" >&2
	    exit 1
	    ;;
	esac
	shift
done

export FLOCKER_CONTROL_NODE
export FLOCKER_AGENT_NODE
export FLOCKER_CONTROL_ADDR
export FLOCKER_BACKEND
export FLOCKER_REPO
