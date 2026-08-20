public class Native {
    public static native void print(String s);

    public static native String input();

    public static native byte[] getBytes(String s);

    public static native String toString(byte[] b);

    public static native int newProcess(String className);

    public static native void killProcess(int pid);
}
