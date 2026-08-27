public class UI {
    public static void create() {
        int[] regs = { 0x0013, 0, 0, 0, 0, 0, 0, 0 };
        Native.int86(0x10, regs);
    }
}
