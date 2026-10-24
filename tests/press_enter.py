#!/usr/bin/env python3
"""Run a command with a terminal attached and press Enter at every prompt.

    python3 tests/press_enter.py CMD [ARG...]

The command gets a pseudo-terminal as its controlling terminal, so scripts
that read answers from /dev/tty see a person who always takes the default.
Only Enter is ever sent, so no default-No offer can install anything.
Prints the command's output and exits with its status.
"""
import os
import pty
import select
import sys
import time

PROMPTS = (b"[y/N]", b"(y/N)", b"(Y/n)", b"[Y/n]")


def main():
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(sys.argv[1], sys.argv[1:])
    output = b""
    answered = 0
    deadline = time.time() + 60
    while time.time() < deadline:
        ready, _, _ = select.select([fd], [], [], 0.2)
        if not ready:
            continue
        try:
            data = os.read(fd, 4096)
        except OSError:
            break
        if not data:
            break
        output += data
        while sum(output.count(p) for p in PROMPTS) > answered:
            answered += 1
            os.write(fd, b"\n")
    _, status = os.waitpid(pid, 0)
    sys.stdout.write(output.decode("utf-8", "replace"))
    sys.stdout.write("\n[prompts answered: %d]\n" % answered)
    sys.exit(os.waitstatus_to_exitcode(status))


if __name__ == "__main__":
    main()
