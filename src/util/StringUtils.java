package util;

import platform.Native;

public class StringUtils {
    public static int length(String s) {
        byte[] b = Native.getBytes(s);

        return b.length;
    }

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
        int b1len = b1.length;

        // Empty string
        if (0 == b1len) {
            return s;
        }

        int start = 0;
        int end = b1len - 1;

        for (int i = 0; i < b1len; i++) {
            if (32 != b1[i]) {
                start = i;
                break;
            }
        }

        for (int i = b1len - 1; i >= start; i--) {
            if (32 != b1[i]) {
                end = i;
                break;
            }
        }

        int len = end - start + 1;

        // Empty string
        if (len <= 0) {
            return s;
        }

        // No trim necessary
        if (b1len == len) {
            return s;
        }

        byte[] b2 = new byte[len];
        int j = 0;
        for (int i = start; i <= end; i++) {
            b2[j++] = b1[i];
        }

        return Native.toString(b2);
    }

    public static String substring(String s, int start, int len) {
        byte[] b1 = Native.getBytes(s);
        byte[] b2 = new byte[len];

        if (start >= b1.length) {
            return "";
        }

        if (start + len > b1.length) {
            len = b1.length - start;
        }

        for (int i = 0; i < len; i++) {
            b2[i] = b1[start + i];
        }

        return Native.toString(b2);
    }

    public static boolean startsWith(String s1, String s2) {
        int l1 = length(s1);
        int l2 = length(s2);

        if (0 == l2) {
            return true;
        }

        if (l2 > l1) {
            return false;
        }

        String s = substring(s1, 0, l2);

        return equals(s, s2);
    }
}
