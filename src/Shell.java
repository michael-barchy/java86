public class Shell {
    public static void main(String[] args) {
        Native.print("Welcome !\r\n");
        String invite = "# ";
        String suffix = "\r\n";
        String input = "";
        while ("exit" != input) {
            Native.print(invite);
            input = Native.input();
            Native.print(suffix);
            parseCmd(input);
        }
    }

    public static void parseCmd(String cmd) {
        cmd = StringUtils.trim(cmd);

        if (cmd == "") {
            return;
        }

        if (cmd == "help") {
            help();
            return;
        }

        if (cmd == "exit") {
            return;
        }

        unknownCmd(cmd);
    }

    public static void help() {
        Native.print("Command shell usage\r\n");
        Native.print("-------------------\r\n");
        Native.print("    help     Display this help message\r\n");
        Native.print("    exit     Exit the command shell\r\n");
        Native.print("\r\n");
    }

    public static void unknownCmd(String cmd) {
        Native.print("Unsupported command ");
        Native.print(cmd);
        Native.print(". Type help to list available commands.\r\n");
    }
}
