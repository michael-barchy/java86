import platform.Native;

public class Proc1 {
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            Native.print("Hello from Proc1\r\n");
        }
    }
}