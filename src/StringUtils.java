public class StringUtils {
    public static boolean equals(String s1, String s2) {
        byte[] b1 = Native.getBytes(s1);
        byte[] b2 = Native.getBytes(s2);

        if (b1.length == 0 && b2.length == 0) {
            return true;
        }

        if (b1.length != b2.length) {
            return false;
        }

        if (b1.length == 0) {
            return false;
        }

        for (int i = 0; i < b1.length; i++) {
            if (b1[i] != b2[i]) {
                return false;
            }
        }

        return true;
    }

    public static String trim(String s) {
        byte[] b1 = Native.getBytes(s);

        // Empty string
        if (0 == b1.length) {
            return "";
        }

        int start = 0;
        int end = 0;

        for (int i = 0; i < b1.length; i++) {
            if (32 != b1[i]) {
                start = i;
                break;
            }
        }

        for (int i = b1.length - 1; i >= 0; i--) {
            if (32 != b1[i]) {
                end = i;
                break;
            }
        }

        int len = end - start;

        // Empty string
        if (0 == len) {
            return "";
        }

        // No trim necessary
        if (b1.length == len) {
            return s;
        }

        byte[] b2 = new byte[len];
        int j = 0;
        for (int i = start; i < end; i++) {
            b2[j] = b1[i];
        }

        return Native.toString(b2);
    }
}
