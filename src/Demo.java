public class Demo {
    public static void main(String[] args) {
        Native.newProcess("Proc1");
        Native.newProcess("Proc2");
        Native.print("Proc1 & Proc2 added\r\n");
    }
}