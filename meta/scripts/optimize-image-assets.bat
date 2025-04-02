@echo off
rem This script is meant to optimize every png file in the assets/images folder.
rem It may take a while so just sit back, relax and wait for the script to finish.
rem https://github.com/shssoichiro/oxipng
cd ../..
cd assets/images
for /R %%f in (*.png) do oxipng -o 6 --strip all --alpha "%%f"
pause