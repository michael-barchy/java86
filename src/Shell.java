public class Shell {
    public static void main(String[] args) {
        Native.print("Welcome !\r\n");
        String input = " ";
        while (!StringUtils.equals("exit", input)) {
            Native.print("# ");
            input = Native.input();
            Native.print("\r\n");
            if ("help" == input) {
                Native.print("Command shell usage\r\n");
                Native.print("-------------------\r\n");
                Native.print("    help     Display this help message\r\n");
                Native.print("    exit     Exit the command shell\r\n");
                Native.print("\r\n");
            } else {
                if ("exit" != input) {
                    Native.print("Unknow command ");
                    Native.print(input);
                    Native.print(". Type help to list available commands.\r\n");
                }
            }
        }
    }
}
