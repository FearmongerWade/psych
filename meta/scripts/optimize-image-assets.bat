@echo off
rem https://github.com/shssoichiro/oxipng
cd ../..
cd assets/images
for /R %%f in (*.png) do oxipng -o 6 --strip all --alpha "%%f"
pause