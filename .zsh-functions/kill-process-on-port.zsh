show-process-on-port() {
    port=$1
    lsof -i tcp:$1
}

kill-process-on-port() {
    port=$1
    processId=$(lsof -ti tcp:$port)
    kill -9 "$processId"
}