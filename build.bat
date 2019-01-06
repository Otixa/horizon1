@echo off
echo Building Horizon Lite...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.json ./dependencies/dubuild/template.json ./output/STEC.json
echo Building Horizon Lite - Minified...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.min.json ./dependencies/dubuild/template.json ./output/STEC.min.json
echo Building Horizon Lite - DRM...
lua ./dependencies/dubuild/compiler.lua ./config/Compiler_Config.crypt.json ./dependencies/dubuild/template.json ./output/STEC.crypt.json
echo.
echo Build finished.
pause