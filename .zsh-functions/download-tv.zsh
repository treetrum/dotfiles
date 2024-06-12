download-tv() {

    local TENPLAY_USERNAME=$(op read "op://Private/10Play/username")
    local TENPLAY_PASSWORD=$(op read "op://Private/10Play/password")

    local show=""
    local season=""
    local episode=""
    local url=""

    local red="\e[31m"
    local green="\e[32m"
    local normal="\e[0m"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --show=*| -s=*) show="${1#*=}"; shift ;;
            --season=*| -S=*) season="${1#*=}"; shift ;;
            --episode=*| -e=*) episode="${1#*=}"; shift ;;
            --url=*| -u=*) url="${1#*=}"; shift ;;
            --show | -s) show="$2"; shift 2 ;;
            --season | -S) season="$2"; shift 2 ;;
            --episode | -e) episode="$2"; shift 2 ;;
            --url | -u) url="$2"; shift 2 ;;
            *) echo "Unknown parameter passed: $1"; return 1 ;;
        esac
    done

    if [[ -z "$show" ]]; then
        echo -e "${red}Please specify a show name with --show or -s${normal}"
        return 1
    fi
    if [[ -z "$season" ]]; then
        echo -e "${red}Please specify a season number with --season or -S${normal}"
        return 1
    fi
    if [[ -z "$episode" ]]; then
        echo -e "${red}Please specify an episode number with --episode or -e${normal}"
        return 1
    fi
    if [[ -z "$url" ]]; then
        echo -e "${red}Please specify a URL with --url or -u${normal}"
        return 1
    fi

    local zero_season_number=$(printf "%02d" $season)
    local zero_ep_number=$(printf "%02d" $episode)
    local ep_name="$show - S${zero_season_number}E${zero_ep_number} - Episode ${episode}.mp4"
    local output="/Volumes/TV/$show/Season ${season}/$ep_name"

    echo -e "${green}Downloading episode from $url${normal}"
    yt-dlp "$url" -o "$ep_name" --no-simulate --username="$TENPLAY_USERNAME" --password="$TENPLAY_PASSWORD"

    if [[ $? -ne 0 ]]; then
        echo -e "${red}Download failed${normal}"
        return 1
    fi

    echo -e "${green}Downloading complete. Moving to $output${normal}"
    pv "$ep_name" > "$output"
    echo -e "${green}Moving complete${normal}"
}
