#!/bin/bash
# libVLC lite (task 22): native libraries for the four ABIs, in VideoLAN's Docker images.
# Run in WSL: bash build.sh <work dir with libvlcjni/>  [abi ...]
# The work dir holds libvlcjni at 0b8dc65e with vlc/ fetched by its get-vlc.sh
# (see README.md). Logs go to <work dir>/logs/lite-<abi>.log.
set -e
HERE="$(cd "$(dirname "$0")"; pwd -P)"
WORK="$(cd "$1"; pwd -P)"; shift
ABIS="${*:-armeabi-v7a arm64-v8a x86 x86_64}"
# Images and NDKs as in libvlcjni's CI: NDK 21 for 32-bit, NDK 29 for 64-bit.
IMAGE_32=registry.videolan.org/vlc-debian-android-3.0:20260701183656
IMAGE_64=registry.videolan.org/vlc-debian-android:20260611225331

cp "$HERE/compile-libvlc-lite.sh" "$HERE/ffmpeg-lite.patch" "$HERE/ffmpeg-lite.conf" "$HERE/audiotrack-pcm6.patch" "$WORK/libvlcjni/buildsystem/"
chmod +x "$WORK/libvlcjni/buildsystem/compile-libvlc-lite.sh"
# Patch VLC once here, not in parallel containers; a patch applied before is left as it is.
for p in ffmpeg-lite.patch audiotrack-pcm6.patch; do
    if (cd "$WORK/libvlcjni/vlc" && patch -p1 -R --dry-run -s < "$HERE/$p") >/dev/null 2>&1; then
        echo "$p: applied already"
    else
        (cd "$WORK/libvlcjni/vlc" && patch -p1 < "$HERE/$p")
    fi
done
mkdir -p "$WORK/logs" "$WORK/home" "$WORK/libvlcjni/vlc/contrib/tarballs"

for abi in $ABIS; do
    case $abi in
        armeabi-v7a|x86) image=$IMAGE_32 ;;
        *) image=$IMAGE_64 ;;
    esac
    docker rm -f "vlc-lite-$abi" >/dev/null 2>&1 || true
    docker run -d --name "vlc-lite-$abi" -u "$(id -u):$(id -g)" \
        -e HOME=/work/home \
        -v "$WORK:/work" -w /work/libvlcjni "$image" \
        bash -c "git config --global --add safe.directory '*'; ./buildsystem/compile-libvlc-lite.sh -a $abi --release --license l > /work/logs/lite-$abi.log 2>&1; echo \"exit \$?\" >> /work/logs/lite-$abi.log"
    echo "started $abi"
done
