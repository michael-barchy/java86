# Java86

Java86 is a class file interpreter implementing a subset of the Java VM.

It fits in 64K of memory and runs on any 8086-compatible processor running the DOS operating system.

## Building

Java86 uses the MoonRock compiler that compiles Basic-like code to assembly, then compiles using MASM Assembler.

## Using

Java86 works like the standard Java VM with many limitations:

- Class files must be loaded from Jar files
- Jar files are limited to 8.3 file names (e.g. CLASSES.JAR)
- The Jar files must be uncompressed (they are simple uncompressed Zip files, use `zip -0`)
- Java86 does not support interfaces, fields or objects (everything is static)
- All native calls are made on the "Native" class (e.g. Native.print)

Example:

```shell
java -classpath native.jar;hello.jar Hello
```

Pure real dos command:

```shell
JAVA.COM -classpath NATIVE.JAR;HELLO.JAR Hello
```

Classes must be compiled using a Java 1.4 compatible compiler (janino recommended; requires Java).

## Example

Here is a really simple "Hello world" examples

```java
public class Hello {
    public static void main(String[] args) {
        Native.print("Hello, World!\r\n");
    }
}
```

## Memory usage

- Jar files cache (10) = 2630 bytes
- Class files constant pool cache = 60 bytes + (contant pool size * 9 bytes)
- Methods cache (100) = 800 bytes

Java86 can be compiled to use FAR memory (compile using MRC JAVA !FAR) @todo
