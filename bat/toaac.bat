@echo off
mkdir output
for %%a in ("*.mp3") do (
  echo "Converting %%a"
  ffmpeg -n -loglevel repeat+level+info -i "%%a" -map a:0 -c:a libfdk_aac -b:a 192k "./output/%%~na.m4a" -hide_banner >> "./output/ffmpeg-log.txt" 2>&1
  echo "Conveted %%~na.m4a"
)

;REM ls *.mp3 | parallel ffmpeg -n -loglevel repeat+level+warning -i "{}" -map a:0 -c:a libfdk_aac -b:a 192k output/"{.}".m4a -hide_banner