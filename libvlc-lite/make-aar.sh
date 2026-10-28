#!/bin/bash
# libVLC lite (task 22): the AAR. Run in WSL: bash make-aar.sh <work dir> <output.aar>
# The Java part (classes.jar, res, manifest) is VideoLAN's own libvlc-all 3.7.7
# from Maven Central, built from the same libvlcjni commit as our native code; only
# jni/ is ours, stripped; of assets/ only the HRTF is kept, the Lua scripts are left out.
set -e
WORK="$(cd "$1"; pwd -P)"
OUT="$(realpath -m "$2")"
URL=https://repo1.maven.org/maven2/org/videolan/android/libvlc-all/3.7.7/libvlc-all-3.7.7.aar
# SHA-1 of libvlc-all-3.7.7.aar as Maven Central and Gradle's cache give it
SHA1=a02b9e380eddc9349d1e75b8955c0f798867d5a6
STRIP=$(ls -d "$WORK"/../android-ndk-*/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip ~/build/android-ndk-*/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip 2>/dev/null | head -1)
[ -x "$STRIP" ] || { echo "llvm-strip from an NDK not found"; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
curl -fsSL -o "$TMP/official.aar" "$URL"
echo "$SHA1  $TMP/official.aar" | sha1sum -c -
mkdir "$TMP/aar"
(cd "$TMP/aar" && unzip -q ../official.aar && rm -rf jni assets)

LIBS="$WORK/libvlcjni/libvlc/jni/libs"
for abi in $(ls "$LIBS"); do
    mkdir -p "$TMP/aar/jni/$abi"
    for so in "$LIBS/$abi"/*.so; do
        "$STRIP" --strip-unneeded -o "$TMP/aar/jni/$abi/$(basename "$so")" "$so"
    done
done
# The HRTF of the headphones mode (task 23, LGPL-2.1, © 3D Sound Labs); the app copies it to a file.
mkdir -p "$TMP/aar/assets/hrtfs"
cp "$WORK/libvlcjni/vlc/share/hrtfs/dodeca_and_7channel_3DSL_HRTF.sofa" "$TMP/aar/assets/hrtfs/"

mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
(cd "$TMP/aar" && zip -q -r -X "$OUT" .)
unzip -l "$OUT" | grep '\.so$'
ls -l "$OUT"
