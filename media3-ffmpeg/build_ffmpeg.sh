#!/bin/bash
# Builds FFmpeg's audio decoders for Media3's decoder_ffmpeg module (task 21.2), LGPL only.
set -e
cd ~/build/media
FFMPEG_MODULE_PATH="$(pwd)/libraries/decoder_ffmpeg/src/main"
NDK_PATH="$HOME/build/android-ndk-r26b"
cd "$FFMPEG_MODULE_PATH/jni"
time ./build_ffmpeg.sh "$FFMPEG_MODULE_PATH" "$NDK_PATH" linux-x86_64 21 ac3 eac3 dca truehd mlp > ~/build/ffmpeg-build.log 2>&1
tail -3 ~/build/ffmpeg-build.log
grep -E "^License:|GPL" ffmpeg/ffbuild/config.log 2>/dev/null | head -3 || true
grep -h "^License" ffmpeg/ffbuild/config.mak 2>/dev/null | head -2 || true
find "$FFMPEG_MODULE_PATH/jni/ffmpeg/android-libs" -name "*.a" -printf "%s %P\n"
