# Define the function in your ~/.zshrc or ~/.zsh_functions

time_command() {
    # Check if at least the command is provided
    if [[ -z "$1" ]]; then
        echo "Usage: time_command <iterations> <command>"
        return 1
    fi

    # Number of iterations
    local x=$1
    shift

    # Check if the command is provided after iterations
    if [[ -z "$1" ]]; then
        echo "Usage: time_command <iterations> <command>"
        return 1
    fi

    # Command to run
    local command="$*"

    # Output file
    local output_file="timing_results.txt"

    # Run the command x times and record the duration
    for i in {1..$x}; do
        start=$(perl -e 'use Time::HiRes qw(gettimeofday); print int(gettimeofday() * 1000)')
        eval "$command"
        end=$(perl -e 'use Time::HiRes qw(gettimeofday); print int(gettimeofday() * 1000)')
        duration=$((end - start))
        echo "Iteration $i: $duration milliseconds" >> $output_file
    done
}
