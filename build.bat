@echo off
echo Building Horizon Lite...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.json -f "STEC.json" ./dependencies/dubuild/template.json ./output
echo Building Horizon Lite - Minified...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.min.json -f "STEC.min.json" ./dependencies/dubuild/template.json ./output
echo Building Horizon Lite - DRM...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.crypt.json -f "%%s.STEC.crypt.json" ./dependencies/dubuild/template.json ./output
echo.
echo Build finished.
pause