#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly COMPOSE_FILE="${SCRIPT_DIR}/compose.yml"
readonly PROJECT_NAME="personal-assistant-n8n"
readonly N8N_URL="http://localhost:5678"
DOCKER=()

usage() {
  cat <<'EOF'
Usage: ./local-run.sh <command>

Commands:
  start    Start n8n and wait until its local health endpoint responds.
  stop     Stop n8n while preserving workflows, credentials, and executions.
  restart  Restart n8n and wait for it to become healthy.
  status   Show the n8n container status.
  logs     Show recent n8n logs.
EOF
}

select_docker() {
  if command -v docker >/dev/null 2>&1 && docker_is_ready docker; then
    DOCKER=(docker)
    return
  fi

  if command -v docker.exe >/dev/null 2>&1 && docker_is_ready docker.exe; then
    DOCKER=(docker.exe)
    return
  fi

  cat >&2 <<'EOF'
Docker Engine is unavailable.

Start Docker Desktop. For the recommended WSL workflow, enable this distribution
in Docker Desktop > Settings > Resources > WSL Integration, then reopen this
terminal and rerun the command.
EOF
  exit 1
}

docker_is_ready() {
  local server_version

  server_version="$("$@" version --format '{{.Server.Version}}' 2>&1)" || return 1
  [[ "${server_version}" =~ ^[0-9]+(\.[0-9]+)+$ ]]
}

compose() {
  "${DOCKER[@]}" compose --project-name "${PROJECT_NAME}" --file "${COMPOSE_FILE}" "$@"
}

wait_for_n8n() {
  local attempt

  for attempt in {1..120}; do
    if curl --fail --silent --show-error --max-time 2 "${N8N_URL}/healthz" >/dev/null; then
      return
    fi
    sleep 1
  done

  return 1
}

start() {
  compose up --detach --remove-orphans
  printf 'Waiting for n8n at %s ...\n' "${N8N_URL}"

  if wait_for_n8n; then
    printf 'n8n is ready. Open %s\n' "${N8N_URL}"
    return
  fi

  printf 'n8n did not become healthy within 120 seconds. Recent logs follow:\n' >&2
  compose logs --tail 50 n8n >&2
  return 1
}

main() {
  local command="${1:-start}"

  case "${command}" in
    start)
      select_docker
      start
      ;;
    stop)
      select_docker
      compose stop
      ;;
    restart)
      select_docker
      compose restart
      printf 'Waiting for n8n at %s ...\n' "${N8N_URL}"
      wait_for_n8n
      printf 'n8n is ready. Open %s\n' "${N8N_URL}"
      ;;
    status)
      select_docker
      compose ps
      ;;
    logs)
      select_docker
      compose logs --tail 100 n8n
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
