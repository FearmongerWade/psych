@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib set lime 8.1.2
haxelib set openfl 9.3.3
haxelib set flixel 5.6.1
haxelib set flixel-addons 3.2.2
haxelib set flixel-tools 1.5.1
haxelib set tjson 1.4.0
haxelib set hxdiscord_rpc 1.2.4
haxelib set hxvlc 2.0.1 --skip-dependencies
haxelib set lime 8.1.2
haxelib set openfl 9.3.3
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
echo Finished!
pause
