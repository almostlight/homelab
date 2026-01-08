#! /bin/bash
# Script to bind mount directories in Proxmox LXC containers

set -e  # exit on error

# check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

usage() {
    echo "Usage: $0 -n <container_id> -s <host_path> -t <container_path>"
    echo "Example: $0 -n 100 -s /mnt/storage/data -t /mnt/data"
    exit 1
}

MP_NUM=-1

if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--container-id)
            CONTAINER_ID="$2"
            shift 2
            ;;
        -s|--source)
            HOST_PATH="$2"
            shift 2
            ;;
        -t|--target)
            CONTAINER_PATH="$2"
            shift 2
            ;;
        -m|--mp-num)
            MP_NUM="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            LIST_MOUNTS=true
            ;;
			# !TODO: add listing and removal options
    esac
done

if [[ ! -e "$HOST_PATH" ]]; then
    echo "$HOST_PATH not found on Host" >&2
    exit 1
fi

if ! pct status "$CONTAINER_ID" &>/dev/null; then
    echo "Container $CONTAINER_ID not found" >&2
    exit 1
fi


CONTAINER_RUNNING=false
if pct status "$CONTAINER_ID" | grep -q "running"; then
    CONTAINER_RUNNING=true
else
	echo "Starting $CONTAINER_ID for target directory check"
	pct start "$CONTAINER_ID"
fi

# check if target dir in container
if ! pct exec $CONTAINER_ID -- test -d $CONTAINER_PATH; then
	echo "$CONTAINER_PATH not found on $CONTAINER_ID" >&2
	exit 1
else
	# remove optional trailing / for check
	CONTAINER_PATH=$(pct exec $CONTAINER_ID -- realpath $CONTAINER_PATH)

	if pct config 204 | grep -o "mp=$CONTAINER_PATH"; then
		echo "$CONTAINER_PATH already bound on $CONTAINER_ID" >&2
		exit 1
	fi
fi

echo "Stopping $CONTAINER_ID"
pct shutdown "$CONTAINER_ID" --timeout 60

# get next available mountpoint number
get_next_mp_number() {
    local container_id=$1
    local max_num=-1

    # Read from process substitution instead of pipe
    while read -r mp; do
        num=${mp#mp}
        if [[ $num -gt $max_num ]]; then
            max_num=$num
        fi
    done < <(pct config "$container_id" | grep -oP '^mp\d+')

    echo $((max_num + 1))
}

echo "Binding"
echo "  Host path:      $HOST_PATH"
echo "  LXC path: $CONTAINER_PATH"

if [[ MP_NUM -eq -1 ]]; then
	MP_NUM=$(get_next_mp_number "$CONTAINER_ID")
fi

echo "  Using mount point: mp$MP_NUM"

pct set "$CONTAINER_ID" -mp$MP_NUM "$HOST_PATH,mp=$CONTAINER_PATH"

if [[ $? -eq 0 ]]; then
    echo "Mount configured successfully as mp$MP_NUM"
else
    echo "Failed to configure mount" >&2
    exit 1
fi

# start container if it was running
if [[ "$CONTAINER_RUNNING" == "true" ]]; then
    echo "Starting $CONTAINER_ID"
    pct start "$CONTAINER_ID"
fi

echo "Success!"
