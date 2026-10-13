open-simulator-documents-folder() {
  # Usage: open-simulator-documents-folder [device-udid|name]
  # Defaults to the booted simulator, prompting if several are booted. Works without the Files app (e.g. iPhone Duo).
  local -a devices names
  if [[ -n "$1" ]]; then
    devices=("$1")
  else
    local booted=$(xcrun simctl list devices booted -j \
      | jq -r '.devices | to_entries[] | (.key | sub(".*SimRuntime\\."; "") | sub("-"; " ") | gsub("-"; ".")) as $os
          | .value[] | select(.state == "Booted") | "\(.udid)\t\(.name) (\($os))"')
    devices=(${(f)"$(cut -f1 <<< "$booted")"})
    names=(${(f)"$(cut -f2 <<< "$booted")"})
  fi

  if [[ -z "${devices[1]}" ]]; then
    echo "No booted simulators." >&2
    return 1
  fi

  if (( ${#devices} > 1 )); then
    local PS3="Simulator: " name
    select name in $names; do
      [[ -n "$name" ]] && { devices=("${devices[$REPLY]}"); break; }
    done
    [[ -n "$name" ]] || return 1
  fi

  local device udid meta folder opened=0
  for device in $devices; do
    # Resolve names to UDIDs; the group container is found via its metadata, not the Files app
    udid=$(xcrun simctl list devices -j \
      | jq -r --arg d "$device" '.devices[][] | select(.udid == $d or .name == $d) | .udid' | head -1)
    [[ -n "$udid" ]] || continue
    meta=$(grep -l "group.com.apple.FileProvider.LocalStorage" \
      ~/Library/Developer/CoreSimulator/Devices/$udid/data/Containers/Shared/AppGroup/*/.com.apple.mobile_container_manager.metadata.plist(N) \
      /dev/null | head -1)
    folder=${meta:h}
    if [[ -n "$meta" && -d "$folder" ]]; then
      open "$folder"
      opened=1
    fi
  done

  if (( ! opened )); then
    echo "No On My iPhone folder found on: ${devices[*]}" >&2
    return 1
  fi
}
