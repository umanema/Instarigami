@ECHO OFF
timeout 30
taskkill /f /im explorer.exe
start _vvvv\vvvv_50beta35.8_x64\vvvv.exe /o "..\..\Subpatches\_root_APP.v4p" /shutup