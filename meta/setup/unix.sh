#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install flixel 5.6.1
haxelib install flixel-addons 3.2.2
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4
haxelib install hxvlc 2.0.1 --skip-dependencies
haxelib install lime 8.1.2
haxelib install openfl 9.3.3
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
echo Finished!
