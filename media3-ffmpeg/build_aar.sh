#!/bin/bash
# Builds the AAR of Media3's decoder_ffmpeg module after build_ffmpeg_wt.sh (task 21.2).
set -e
SDK="$HOME/build/android-sdk"
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  mkdir -p "$SDK/cmdline-tools" && cd "$SDK/cmdline-tools"
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
  unzip -q commandlinetools-linux-13114758_latest.zip && rm commandlinetools-linux-13114758_latest.zip
  mv cmdline-tools latest
fi
export ANDROID_HOME="$SDK" ANDROID_SDK_ROOT="$SDK"
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" "platforms;android-36" "platform-tools" "ndk;26.1.10909125" > /dev/null
cd ~/build/media
cat > local.properties <<EOF
sdk.dir=$SDK
cmake.dir=/usr
EOF
grep -n "decoder-ffmpeg\|decoder_ffmpeg" settings.gradle.kts build-logic-settings/*.kts 2>/dev/null | head -3 || true
./gradlew --no-daemon -q :lib-decoder-ffmpeg:assembleRelease -Pandroid.ndkVersion=26.1.10909125 > ~/build/aar-build.log 2>&1 || { tail -40 ~/build/aar-build.log; exit 1; }
find libraries/decoder_ffmpeg/buildout libraries/decoder_ffmpeg/build -name "*.aar" -printf "%s %p\n" 2>/dev/null
