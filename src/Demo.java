import platform.Native;
import util.StringUtils;

public class Demo {
    public static void main(String[] args) {
        Native.print("Printing using DOS interrupt: ");
        int[] reg = { 0x0200, 0, 0, 'A', 0, 0, 0, 0 };
        Native.int86(0x21, reg);
        Native.print("\r\n");

        Native.print(StringUtils.substring("Hello world!", 0, 5));
        Native.print("\r\n");

        Native.newProcess("Proc1");
        Native.newProcess("Proc2");
    }
}