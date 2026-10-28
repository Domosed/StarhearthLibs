# libVLC lite (task 22)

`app/libs/libvlc-lite-3.7.7.aar` is our own build of libVLC 3.7.7 (the version of
`org.videolan.android:libvlc-all:3.7.7`) with what an IPTV player does not need
taken out. The app uses it instead of `libvlc-all`.

## What it is built from

| Part | Version |
|---|---|
| vlc-android | tag `libvlc-3.7.7`, commit `7a7c8f14be6759f9bb1b9a934fd086259473e20e` (only to pin libvlcjni) |
| libvlcjni | branch `libvlcjni-3.x`, commit `0b8dc65efb203c86a0476bc337ddd99ecf1c0ef6` |
| VLC | branch `3.0.x`, commit `84177b2273abc5c4300234e6e18b55a4d2dd5a03` and libvlcjni's patches (`buildsystem/get-vlc.sh`) |
| FFmpeg and the other contribs | the versions VLC's `contrib/src/*/rules.mak` name at that commit (FFmpeg 8.1.2) |
| Build images | `registry.videolan.org/vlc-debian-android-3.0:20260701183656` (NDK 21, armeabi-v7a, x86), `registry.videolan.org/vlc-debian-android:20260611225331` (NDK 29, arm64-v8a, x86_64), as in libvlcjni's CI |
| Java part of the AAR | `libvlc-all-3.7.7.aar` from Maven Central: same libvlcjni commit |

## What is left out

`compile-libvlc-lite.sh` is libvlcjni's `buildsystem/compile-libvlc.sh` with the
changes marked `lite:`; `ffmpeg-lite.conf` and `ffmpeg-lite.patch` cut FFmpeg down.

- Lua, Chromecast and all stream output (transcoding, streaming, recording);
- network shares and discovery (SMB, NFS, SFTP, UPnP, mDNS), discs, archives;
- separate codec libraries FFmpeg or the TV already covers (libvpx, aom, dav1d,
  mpg123, Vorbis, Opus, FLAC, Theora, Speex), tracker/game/MIDI music, images,
  TagLib;
- zvbi (GPL-2+): teletext goes to VLC's own `telx`;
- the eleven modules that declare GPL-2+ (see the blacklist in the script);
- in FFmpeg: everything except the decoders, parsers, demuxers and the RTMP
  protocol listed in `ffmpeg-lite.conf`.

Kept: HTTP(S), HLS, DASH, TS, MP4, MKV, AVI, FLV, UDP/RTP, RTSP (live555), RTMP,
MediaCodec, OpenGL ES output, HLS AES-128, subtitles (text, ASS, DVB, DVD, PGS,
teletext), resampling (SoX), spatialaudio with mysofa and its HRTF (5.1 and 7.1
for headphones, task 23; the HRTF goes into the AAR's `assets/hrtfs`).

`audiotrack-pcm6.patch` adds to VLC's AudioTrack output a device `pcm6`: PCM of
up to six channels, 7.1 brought down to 5.1, next to VideoLAN's `stereo` (two)
and `pcm` (eight). The app's "5.1" uses it (task 23).

## Licence

Built with `--license l`: the contribs are configured with `--disable-gpl
--enable-ad-clauses`, so nothing under the GPL is built. gnutls, nettle, gmp
(HTTPS) and live555 (RTSP) are under LGPLv3, the rest of VLC and FFmpeg under
LGPLv2.1 or later (spatialaudio and the HRTF, © 3D Sound Labs, too), several
contribs under BSD-like licences (mysofa among them). FFmpeg's own
`configure` reports `LGPL version 2.1 or later`. Every module linked into
`libvlc.so` carries the LGPLv2.1 string (checked from the compiled modules).

The app may stay closed: libVLC is a separate shared library (`libvlc.so`) the
user can replace. What LGPL asks of us: say in the app that it uses libVLC and
FFmpeg under the LGPL, with the licence texts; give the source of this build on
request (the commits above plus this folder); do not forbid the reverse
engineering needed to debug such a replacement; and with R8 keep
`org.videolan.**` as it is. FreeType's licence (FTL, the "ad clause") asks for a
credit in the documentation: "Portions of this software are copyright © The
FreeType Project (www.freetype.org). All rights reserved."

## Rebuilding

In WSL 2 (Ubuntu 24.04) with Docker Desktop, `git`, `rsync`,
`patch`, `zip`, `curl` and an NDK for `llvm-strip` (`~/build/android-ndk-r26b`
from task 21 will do). About 5 minutes on 32 cores once the source tarballs are downloaded.

```sh
mkdir -p ~/build/vlc/lite && cd ~/build/vlc/lite
git clone --single-branch --branch libvlcjni-3.x https://code.videolan.org/videolan/libvlcjni.git
(cd libvlcjni && git reset --hard 0b8dc65efb203c86a0476bc337ddd99ecf1c0ef6)
# get-vlc.sh applies its patches with git am, which wants a name
GIT_AUTHOR_NAME=build GIT_AUTHOR_EMAIL=build@localhost \
GIT_COMMITTER_NAME=build GIT_COMMITTER_EMAIL=build@localhost \
  sh -c 'cd libvlcjni && ./buildsystem/get-vlc.sh'
T=/path/to/StarhearthLibs/libvlc-lite
bash $T/build.sh ~/build/vlc/lite          # four containers, logs in ~/build/vlc/lite/logs
# when every log ends with "exit 0":
bash $T/make-aar.sh ~/build/vlc/lite ~/out/libvlc-lite-3.7.7.aar
```

A new libVLC version means new commits here, a fresh diff of
`compile-libvlc-lite.sh` against the new `compile-libvlc.sh`, and checking that
`ffmpeg-lite.patch` and `audiotrack-pcm6.patch` still apply.
