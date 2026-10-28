# Starhearth: our builds of FFmpeg and libVLC

Starhearth is a media player for Android TV, phones and tablets. The app itself is closed, but it uses
two libraries under the GNU Lesser General Public License, built by us. This repository is their
complete corresponding source: what we built them from, how, and every change we made.

| Folder | Library in the app | Licence |
|---|---|---|
| [`media3-ffmpeg`](media3-ffmpeg) | `libffmpegJNI.so`: AndroidX Media3's `decoder_ffmpeg` module 1.11.1 with FFmpeg 6.0, sound decoders only (AC-3, E-AC-3, DTS, TrueHD, MLP) | Media3: Apache 2.0; FFmpeg: LGPL 2.1 or later |
| [`libvlc-lite`](libvlc-lite) | `libvlc.so`, `libvlcjni.so`: libVLC 3.7.7 without the parts an IPTV player does not need | LGPL 2.1 or later; GnuTLS, Nettle, GMP and LIVE555 under their own LGPL versions |

Each folder has a README with the exact upstream commits, the toolchains (NDK versions and the
VideoLAN build images) and the commands to rebuild. Our changes to upstream code are the files there:
the build scripts, `compile-libvlc-lite.sh` (libvlcjni's `compile-libvlc.sh` with the changes marked
`lite:`), `ffmpeg-lite.conf`, `ffmpeg-lite.patch` and `audiotrack-pcm6.patch`.

Nothing here is built with `--enable-gpl` or `--enable-nonfree`; the libVLC build uses
`--license l`, so its contribs are configured without GPL parts.

## Replacing the libraries

Both are shared libraries the app loads at run time. You may build them from this source, with your
own changes, and put them in place of ours in the app; reverse engineering of the app to the extent
needed to debug such a replacement is allowed. The Java part of libVLC (`org.videolan.**`) is kept
in the app as published, so a build of the same version fits it.

## Licences

- FFmpeg: <https://ffmpeg.org/legal.html>, `media3-ffmpeg/FFMPEG-COPYING.LGPLv2.1`
- libVLC and its contribs: the licence files of each project, as listed in `libvlc-lite/README.md`
- the full list of what the app uses, with the texts, is in the app: Settings → About → Licenses

FFmpeg is a trademark of Fabrice Bellard. VLC is a trademark of VideoLAN; Starhearth is not VLC media
player and is not made or endorsed by VideoLAN.

Portions of this software are copyright © The FreeType Project (www.freetype.org). All rights reserved.
