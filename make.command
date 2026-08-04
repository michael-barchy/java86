#!/bin/sh

cd "`dirname "$0"`"
./build.command
./dosbox-x.app/Contents/MacOS/dosbox-x -nopromptfolder MAKE.BAT
