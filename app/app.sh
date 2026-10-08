#!/usr/bin/env bash

set -u

show_help() {
    cat <<'HELP'
DevOps Tool

Usage:
  ./app.sh system-info
  ./app.sh check-host <host>
  ./app.sh check-port <host> <port>
  ./app.sh help

Commands:
  system-info          Display system information
  check-host <host>    Resolve a host and check connectivity
  check-port <host> <port>
                       Validate a port and check TCP connectivity
  help                 Display this help message
HELP
}

system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Operating System: $(. /etc/os-release; echo "$PRETTY_NAME")"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU count: $(nproc)"

    echo
    echo "=== Memory ==="
    free -h
}

check_host() {
    local host="$1"

    if [[ -z "$host" ]]; then
        echo "ERROR: Host is required." >&2
        return 2
    fi







    echo "=== Host Resolution ==="

    if ! getent hosts "$host"; then
        echo "ERROR: Cannot resolve host: $host" >&2
        return 1
    fi

    echo
    echo "=== Connectivity ==="

    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Connectivity: SUCCESS"
        return 0
    fi

    echo "Connectivity: FAILED"
    return 1
}

check_port() {
    local host="$1"
    local port="$2"

    if [[ -z "$host" ]]; then
        echo "ERROR: Host is required." >&2
        return 2
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Port must be numeric." >&2
        return 2
    fi

    if (( port < 1 || port > 65535 )); then
        echo "ERROR: Port must be between 1 and 65535." >&2
        return 2
    fi

    if ! getent hosts "$host" >/dev/null 2>&1; then
        echo "ERROR: Cannot resolve host: $host" >&2
        return 1
    fi

    echo "Host: $host"
    echo "Port: $port"

    if timeout 5 bash -c ":</dev/tcp/$host/$port" >/dev/null 2>&1; then
        echo "TCP connectivity: SUCCESS"
        return 0
    fi

    echo "TCP connectivity: FAILED"
    return 1
}

case "${1:-}" in
    help)
        [[ $# -eq 1 ]] || {
            echo "ERROR: help takes no extra arguments." >&2
            exit 2
        }
        show_help
        ;;

    system-info)
        [[ $# -eq 1 ]] || {
            echo "ERROR: system-info takes no extra arguments." >&2
            exit 2
        }
        system_info
        ;;

    check-host)
        [[ $# -eq 2 ]] || {
            echo "ERROR: check-host requires exactly one host." >&2
            show_help
            exit 2
        }
        check_host "$2"
        exit $?
        ;;

    check-port)
        [[ $# -eq 3 ]] || {
            echo "ERROR: check-port requires a host and port." >&2
            show_help
            exit 2
        }
        check_port "$2" "$3"
        exit $?
        ;;

    *)
        echo "ERROR: Invalid command." >&2
        show_help
        exit 2
        ;;
esac
