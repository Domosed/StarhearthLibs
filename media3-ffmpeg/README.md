# Media3 FFmpeg decoder (task 21)

`app/libs/media3-decoder-ffmpeg-1.11.1.aar` is Media3's own `decoder_ffmpeg`
module, built here because Google publishes no binaries of it. It decodes the
sound a TV may have no decoder for: AC-3, E-AC-3, DTS, TrueHD and MLP. The
others (AAC, MP3, Opus, Vorbis, FLAC) are left to the TV.

## What it is built from

| Part | Version |
|---|---|
| androidx/media | tag `1.11.1`, commit `8c6678b657ede1e7883fc164ef73ed483c7796c3` |
| FFmpeg | branch `release/6.0`, commit `b37bf81a7a9782438e4fe06a249329e279694494` |
| NDK | r26b (26.1.10909125), as the module's README asks |
| Decoders | `ac3 eac3 dca truehd mlp` |
| ABIs | armeabi-v7a, arm64-v8a, x86, x86_64; minimum API 21 |

## Licence

The module is Apache 2.0. FFmpeg is built by the module's `build_ffmpeg.sh`
without `--enable-gpl` or `--enable-nonfree`; its `configure` reports
`license='LGPL version 2.1 or later'` (text: `FFMPEG-COPYING.LGPLv2.1`). FFmpeg
is linked statically into `libffmpegJNI.so`; its source is the commit above.

## Rebuilding

In WSL 2 with Ubuntu 24.04, with
`build-essential yasm nasm cmake ninja-build openjdk-17-jdk-headless`:

```sh
mkdir -p ~/build && cd ~/build
git clone --depth 1 --branch 1.11.1 https://github.com/androidx/media.git
wget https://dl.google.com/android/repository/android-ndk-r26b-linux.zip && unzip android-ndk-r26b-linux.zip
cd media/libraries/decoder_ffmpeg/src/main/jni
git clone https://git.ffmpeg.org/ffmpeg.git --branch=release/6.0 --depth=1
bash build_ffmpeg.sh   # this folder's script: FFmpeg for the four ABIs, about 4 min
bash build_aar.sh      # this folder's script: Android SDK in ~/build/android-sdk, then the AAR
```

The AAR comes out as
`~/build/media/libraries/decoder_ffmpeg/buildout/outputs/aar/lib-decoder-ffmpeg-release.aar`;
copy it to `app/libs/media3-decoder-ffmpeg-<media3 version>.aar`. A new Media3
version needs a new build of the same version.
