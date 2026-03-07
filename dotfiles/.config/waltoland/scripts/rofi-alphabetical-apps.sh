#!/usr/bin/env bash
# rofi-alphabetical-apps.sh — List desktop apps alphabetically with icons and launch selection

# Declare arrays to store app names, commands, and icons
declare -a apps
declare -A execs

declare -A icons

# Find all .desktop files and extract Name, Exec, and Icon fields
while IFS= read -r -d '' file; do
  # Skip entries with NoDisplay=true
  if grep -qi '^NoDisplay=true' "$file"; then
    continue
  fi

  # Extract Name, Exec, and Icon fields
  name=$(grep -m1 '^Name=' "$file" | sed 's/^Name=//')
  exec=$(grep -m1 '^Exec=' "$file" | sed 's/^Exec=//' | sed 's/%\{0,1\}//g')
  icon=$(grep -m1 '^Icon=' "$file" | sed 's/^Icon=//')

  # Add to arrays if name and exec are valid
  if [[ -n "$name" && -n "$exec" ]]; then
    apps+=("$name")
    execs["$name"]="$exec"
    icons["$name"]="$icon"
  fi

done < <(find /usr/share/applications ~/.local/share/applications -type f -name '*.desktop' -print0 2>/dev/null)

# Prepare input for rofi with icons
input=""
for app in "${apps[@]}"; do
  if [[ -n "${icons[$app]}" ]]; then
    input+="${app}\0icon\x1f${icons[$app]}\n"
  else
    input+="${app}\n"
  fi
done

# Show the sorted list in rofi and get the user's selection
selection=$(printf '%b' "$input" | sort -u | rofi -dmenu -i -p "Applications:" -show-icons -theme launchpad)

# Launch the selected application
if [[ -n "$selection" && -n "${execs[$selection]}" ]]; then
  setsid bash -c "${execs[$selection]}" >/dev/null 2>&1 &
fi