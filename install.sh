#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_MANIFEST="com.superrealchlorine.chloride_host.json"
HOST_SCRIPT="chloride-host.py"

chmod +x "${SCRIPT_DIR}/${HOST_SCRIPT}"

# Common native messaging host directories for Firefox-based browsers
declare -A BROWSERS=(
	["Firefox (~/.mozilla)"]="$HOME/.mozilla/native-messaging-hosts"
	["LibreWolf (~/.librewolf)"]="$HOME/.librewolf/native-messaging-hosts"
	["Waterfox (~/.waterfox)"]="$HOME/.waterfox/native-messaging-hosts"
	["Thunderbird (~/.thunderbird)"]="$HOME/.thunderbird/native-messaging-hosts"
)

echo "=========================================="
echo " Chloride Protocol Native Host Installer "
echo "=========================================="
echo ""

DETECTED_PATHS=()
DETECTED_NAMES=()

for name in "${!BROWSERS[@]}"; do
	target_dir="${BROWSERS[$name]}"
	parent_dir="$(dirname "$target_dir")"
	if [ -d "$parent_dir" ]; then
		DETECTED_NAMES+=("$name")
		DETECTED_PATHS+=("$target_dir")
	fi
done

if [ ${#DETECTED_PATHS[@]} -eq 0 ]; then
	echo "No supported Firefox-based browsers detected in home directory."
	exit 1
fi

echo "Detected installed browsers/environments:"
for i in "${!DETECTED_NAMES[@]}"; do
	echo "  [$((i+1))] ${DETECTED_NAMES[$i]}"
done
echo "  [A] Install to ALL detected browsers"
echo ""

read -rp "Select an option (1-${#DETECTED_NAMES[@]} or A): " choice

install_to_dir() {
	local dest_dir="$1"
	mkdir -p "$dest_dir"
	sed "s|\"path\": \"${HOST_SCRIPT}\"|\"path\": \"${SCRIPT_DIR}/${HOST_SCRIPT}\"|" \
		"${SCRIPT_DIR}/${HOST_MANIFEST}" > "${dest_dir}/${HOST_MANIFEST}"
	echo "  -> Installed to: ${dest_dir}/${HOST_MANIFEST}"
}

if [[ "$choice" =~ ^[Aa]$ ]]; then
	echo ""
	echo "Installing native host to all detected browsers..."
	for path in "${DETECTED_PATHS[@]}"; do
		install_to_dir "$path"
	done
elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#DETECTED_PATHS[@]}" ]; then
	idx=$((choice-1))
	echo ""
	echo "Installing native host to ${DETECTED_NAMES[$idx]}..."
	install_to_dir "${DETECTED_PATHS[$idx]}"
else
	echo "Invalid selection. Aborting."
	exit 1
fi

echo ""
echo "Done! Native host successfully deployed."
