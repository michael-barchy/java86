#!/bin/sh

cd "`dirname "$0"`"
cp="./sdk/janino-3.1.9.jar:./sdk/commons-compiler-3.1.9.jar"
javac="java -classpath $cp org.codehaus.commons.compiler.samples.CompilerDemo"
$javac src/Hello.java
rm HELLO.JAR
cd src
zip -0 ../HELLO.JAR Hello.class
cd ..
./dosbox-x.app/Contents/MacOS/dosbox-x -nopromptfolder MAKE.BAT
