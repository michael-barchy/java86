package ui;

import io.File;
import platform.Native;

public class BMP {

    /**
     * Load font file and intialize charWidth cache
     *
     * @return [fileHandle, charWidth, charHeight, charWidth x 222]
     */
    public static int[] open(String path) {
        int fileHandle = File.open(path, 0);
        int w = getWidth(fileHandle);
        int h = getHeight(fileHandle);

        int[] bmp = new int[] {
            fileHandle,
            w,
            h
        };

        return bmp;
    }

    public static int getWidth(int fileHandle) {
        byte[] widthBytes = new byte[4];
        File.seek(fileHandle, 0, 18);
        File.readBytes(fileHandle, widthBytes);

        return widthBytes[0] + (widthBytes[1] * 256);
    }

    public static int getHeight(int fileHandle) {
        byte[] heightBytes = new byte[4];
        File.seek(fileHandle, 0, 22);
        File.readBytes(fileHandle, heightBytes);

        int h = heightBytes[0] + (heightBytes[1] * 256);
        if (h < 0) {
            Native.print("Unsupported bitmap format\r\n");
            return 0;
        }

        return h;
    }

    /**
     * Copy from BMP file (row by row in reversed order) to dest byte array in normal order
     * Can copy part of BMP (aka sprite)
     */
    public static void copy(int[] bmp, byte[] dest, int destWidth, int destX, int destY, int sourceWidth, int sourceX, int sourceY, int count) {
        int fileHandle = bmp[0];
        int bmpWidth = bmp[1];
        int bmpHeight = bmp[2];

        if (-1 == fileHandle) {
            return;
        }

        // BMP rows are reversed
        File.seek(fileHandle, 0, 1078); // Header
        int jumpSize = 3200; // Should be 32000 but seek(origin: 1) is not working
        int rowsPerJump = jumpSize / bmpWidth;
        int sourceY2 = bmpHeight - sourceY - count;
        sourceY = sourceY2;
        if (sourceY > rowsPerJump) {
            int jumps = sourceY / rowsPerJump;
            int jumpBytes = rowsPerJump * bmpWidth;
            for (int j = 0; j < jumps; j++) {
                if (sourceY - rowsPerJump > 0) {
                    File.seek(fileHandle, /** RELATIVE */ 1, jumpBytes);
                    sourceY -= rowsPerJump;
                }
            }
        }
        int sourceOffset = sourceY * bmpWidth;
        if (sourceOffset > 0) {
            File.seek(fileHandle, /* RELATIVE */ 1, sourceOffset);
        }

        // @todo - sourceX

        for (int y1 = 0; y1 < count; y1++) {
            int y2 = count - destY - y1 - 1;
            int byteOffset = destX + (y2 * destWidth);
            File.read(fileHandle, dest, byteOffset, sourceWidth);
        }
    }

    public static void close(int[] bmp) {
        int fileHandle = bmp[0];

        if (-1 == fileHandle) {
            return;
        }

        File.close(fileHandle);
    }
}
