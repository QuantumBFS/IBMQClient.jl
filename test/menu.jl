using REPL.TerminalMenus
const CR = "\r"
const LF = "\n"
const UP = "\eOA"
const DOWN = "\eOB"
const ALL = "a"
const NONE = "n"
const DONE = "d"
const SIGINT = "\x03"
const QUIT = "q"

menu = IBMQClient.DeviceMenu(devices)
print(
    stdin.buffer,
    DOWN,
    LF,
    CR,
)

choice = request("choose a device:", menu)
@test choice == 2
readavailable(stdin.buffer)

print(
    stdin.buffer,
    DOWN,
    DOWN,
    DOWN,
    LF,
    CR,
)
choice = request("choose a device:", menu)
@test choice == 4
readavailable(stdin.buffer)

print(
    stdin.buffer,
    DOWN,
    DOWN,
    DOWN,
    QUIT,
)
choice = request("choose a device:", menu)
@test choice == -1
readavailable(stdin.buffer)

@test_throws InterruptException begin
    print(
        stdin.buffer,
        DOWN,
        DOWN,
        DOWN,
        SIGINT,
    )
    request("choose a device:", menu)
    readavailable(stdin.buffer)
end
