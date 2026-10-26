# Lines sent to the container's stdin through `docker attach`
sleep 1
printf 'echo "stdout: hello from $(hostname) as $(whoami)"\n'
printf 'echo "stderr: this line is written to stderr" >&2\n'
printf 'python -c "print(\\"Sum of 1..10 =\\", sum(range(1, 11)))"\n'
sleep 2
printf 'exit 7\n'
sleep 1
