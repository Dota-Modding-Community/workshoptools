#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/resourcecompiler"
FILELIST="${SCRIPT_DIR}/filelist.txt"
PANORAMA_CONFIG="${SCRIPT_DIR}/panorama_config.txt"

# Locate DepotDownloader executable
DD_BIN=""
if command -v DepotDownloader >/dev/null 2>&1; then
    DD_BIN="DepotDownloader"
elif command -v depotdownloader >/dev/null 2>&1; then
    DD_BIN="depotdownloader"
elif [ -f "${SCRIPT_DIR}/DepotDownloader" ]; then
    DD_BIN="${SCRIPT_DIR}/DepotDownloader"
elif [ -f "${SCRIPT_DIR}/depotdownloader.exe" ]; then
    DD_BIN="${SCRIPT_DIR}/depotdownloader.exe"
elif command -v depotdownloader.exe >/dev/null 2>&1; then
    DD_BIN="depotdownloader.exe"
else
    echo "Error: DepotDownloader executable not found in PATH or script directory."
    echo "Please download it from https://github.com/SteamRE/DepotDownloader/releases and add it to your PATH."
    exit 1
fi

USERNAME="${1:-${STEAM_USERNAME:-}}"
if [ -z "$USERNAME" ]; then
    read -rp "Enter Steam Username: " USERNAME
fi

if [ -z "$USERNAME" ]; then
    echo "Error: Steam username is required."
    exit 1
fi

PASSWORD="${2:-${STEAM_PASSWORD:-}}"

DEPOTS=(373301 373303 381450)

echo "==> Downloading Depots ${DEPOTS[*]}..."
if [ -n "$PASSWORD" ]; then
    "$DD_BIN" -app 570 -depot "${DEPOTS[@]}" -username "$USERNAME" -password "$PASSWORD" -remember-password -filelist "$FILELIST" -dir "$OUT_DIR" -max-downloads 8
else
    "$DD_BIN" -app 570 -depot "${DEPOTS[@]}" -username "$USERNAME" -remember-password -filelist "$FILELIST" -dir "$OUT_DIR" -max-downloads 8
fi

echo "==> Setting up panorama_config.txt..."
mkdir -p "${OUT_DIR}/game/core/panorama"
cp "${PANORAMA_CONFIG}" "${OUT_DIR}/game/core/panorama/panorama_config.txt"

# Clean up DepotDownloader temporary metadata
rm -rf "${OUT_DIR}/.DepotDownloader"

echo "==> Successfully downloaded resourcecompiler to: ${OUT_DIR}"
