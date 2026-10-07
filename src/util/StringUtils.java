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

        if (0 == b1.length && b2.length == 0) {
            return true;
        }

        if (b1.length != b2.length) {
            return false;
        }

        if (0 == b1.length) {
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

    public static String concat(String s1, String s2) {
        byte[] b1 = Native.getBytes(s1);
        byte[] b2 = Native.getBytes(s2);

        int len1 = b1.length;
        int len2 = b2.length;

        byte[] b = new byte[len1 + len2];

        for (int i = 0; i < len1; i++) {
            b[i] = b1[i];
        }

        for (int i = 0; i < len2; i++) {
            b[len1 + i] = b2[i];
        }

        return Native.toString(b);
    }

    public static String valueOf(byte b) {
        int a = (int) b < 0 ? (int) -b : (int) b;
        int len = a >= 100 ? 3 : (a >= 10 ? 2 : 1);
        if ((int) b < 0) {
            len++;
        }
        byte[] b1 = new byte[len];

        for (int i = len - 1; i >= 0; i--) {
            b1[i] = (byte) ((b % 10) + 48);
            b /= 10;
        }

        return Native.toString(b1);
    }

    public static String valueOf(int i) {
        int len = 1;
        int a = i < 0 ? -i : i;
        if (a >= 10000) {
            len = 5;
        } else if (a >= 1000) {
            len = 4;
        } else if (a >= 100) {
            len = 3;
        } else if (a >= 10) {
            len = 2;
        }
        if (i < 0) {
            len++;
        }
        byte[] b1 = new byte[len];

        for (int j = len - 1; j >= 0; j--) {
            b1[j] = (byte) ((i % 10) + 48);
            i /= 10;
        }

        return Native.toString(b1);
    }
}
