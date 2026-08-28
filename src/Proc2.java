import platform.Native;

public class Proc2 {
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            Native.print("Hello from Proc2\r\n");
        }
    }
}