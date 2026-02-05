open-simulator-documents-folder() {
  local folder
  folder=$(xcrun simctl listapps booted \
    | plutil -convert json -o - - \
    | jq -r '.["com.apple.DocumentsApp"].GroupContainers["group.com.apple.FileProvider.LocalStorage"]')
  open "$folder"
}