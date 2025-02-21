@echo off
cd ..
call  flutter build windows --release
cd installer

echo "Running inno compiler"
"C:\Program Files (x86)\Inno Setup 6\iscc.exe" "inno installer script.iss"

echo
echo Open the ide if there are any setup issues:
echo "C:\Program Files (x86)\Inno Setup 6\Compil32.exe"

rem pause