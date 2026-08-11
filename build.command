#!/bin/sh

cd "`dirname "$0"`"
cp="./sdk/janino-3.1.9.jar:./sdk/commons-compiler-3.1.9.jar"
javac="java -classpath $cp org.codehaus.commons.compiler.samples.CompilerDemo"
$javac src/Native.java
$javac -classpath src src/Hello.java
$javac -classpath src src/StringUtils.java
$javac -classpath src src/Shell.java
rm NATIVE.JAR
rm HELLO.JAR
rm UTILS.JAR
rm SHELL.JAR
cd src
zip -0 ../NATIVE.JAR Native.class
zip -0 ../HELLO.JAR Hello.class
zip -0 ../UTILS.JAR StringUtils.class
zip -0 ../SHELL.JAR Shell.class
cd ..
