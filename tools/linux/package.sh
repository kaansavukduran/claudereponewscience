#!/usr/bin/env bash
# Package a real Flutter Linux release bundle into the v0.28 channels.
# Only formats whose tools exist are produced; each missing tool is reported
# as NOT_RUN, never faked. Usage:
#   tools/linux/package.sh <bundle-dir> <out-dir> <version> <source-revision>
# Optional env: APPIMAGETOOL=<path> APPIMAGE_RUNTIME=<path>
set -euo pipefail

BUNDLE=$(readlink -f "$1"); OUT=$(readlink -f -m "$2"); VERSION=$3; REV=$4
REPO=$(cd "$(dirname "$0")/../.." && pwd)
P="$REPO/packaging/linux"
ID=org.humanhealthos.HumanHealthOS
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUT"
EPOCH=$(git -C "$REPO" log -1 --format=%ct "$REV" 2>/dev/null || date +%s)
export SOURCE_DATE_EPOCH=$EPOCH
STATUS="$OUT/package-status.txt"; : > "$STATUS"
note() { echo "$1" | tee -a "$STATUS"; }

[ -x "$BUNDLE/human_health_os" ] || { echo "no release bundle at $BUNDLE" >&2; exit 1; }

# Shared desktop integration files, installed under a given prefix.
install_desktop_files() { # <root> <prefix>
  install -Dm644 "$P/$ID.desktop" "$1$2/share/applications/$ID.desktop"
  install -Dm644 "$P/$ID.metainfo.xml" "$1$2/share/metainfo/$ID.metainfo.xml"
  install -Dm644 "$P/icons/$ID.svg" "$1$2/share/icons/hicolor/scalable/apps/$ID.svg"
  mkdir -p "$1$2/share/icons/hicolor/256x256/apps"
  rsvg-convert -w 256 -h 256 "$P/icons/$ID.svg" -o "$1$2/share/icons/hicolor/256x256/apps/$ID.png"
}

# C. Portable tar.zst (portable_mode.json => encrypted-only storage; F004).
if command -v zstd >/dev/null; then
  D="$WORK/HumanHealthOS-Linux-x86_64-Portable"
  mkdir -p "$D"; cp -a "$BUNDLE/." "$D/"
  install -m644 "$P/portable/portable_mode.json" "$P/portable/README.txt" "$D/"
  install -m644 "$P/icons/$ID.svg" "$D/"
  tar --sort=name --mtime="@$EPOCH" --owner=0 --group=0 --numeric-owner \
    -C "$WORK" -cf - HumanHealthOS-Linux-x86_64-Portable \
    | zstd -q -19 -T0 -o "$OUT/HumanHealthOS-Linux-x86_64-Portable.tar.zst" -f
  note "tar.zst PRODUCED"
else note "tar.zst NOT_RUN (zstd missing)"; fi

# D. .deb (Debian/Ubuntu family).
if command -v dpkg-deb >/dev/null; then
  R="$WORK/deb"
  mkdir -p "$R/usr/lib/human-health-os" "$R/usr/bin" "$R/DEBIAN" "$R/usr/share/doc/human-health-os"
  cp -a "$BUNDLE/." "$R/usr/lib/human-health-os/"
  ln -s ../lib/human-health-os/human_health_os "$R/usr/bin/human-health-os"
  install_desktop_files "$R" /usr
  install -m644 "$P/deb/copyright" "$R/usr/share/doc/human-health-os/copyright"
  printf 'human-health-os (%s) unstable; urgency=low\n\n  * Staging preview from %s (FORGE F030L-1).\n\n -- Human OS project <noreply@humanhealthos.invalid>  %s\n' \
    "$VERSION" "$REV" "$(date -u -R -d "@$EPOCH")" | gzip -9n > "$R/usr/share/doc/human-health-os/changelog.Debian.gz"
  SIZE=$(du -sk --exclude=DEBIAN "$R" | cut -f1)
  sed -e "s/@VERSION@/$VERSION/" -e "s/@INSTALLED_SIZE@/$SIZE/" "$P/deb/control.in" > "$R/DEBIAN/control"
  find "$R" -type d -exec chmod 755 {} +
  find "$R" -exec touch -h -d "@$EPOCH" {} +
  fakeroot dpkg-deb --root-owner-group -Zxz --build "$R" "$OUT/human-health-os_${VERSION}_amd64.deb" >/dev/null
  note "deb PRODUCED"
else note "deb NOT_RUN (dpkg-deb missing)"; fi

# E. .rpm (Fedora/Nobara family). Built from a staged tree, nothing compiled.
if command -v rpmbuild >/dev/null; then
  S="$WORK/rpmstage"
  mkdir -p "$S/usr/lib64/human-health-os" "$S/usr/bin"
  cp -a "$BUNDLE/." "$S/usr/lib64/human-health-os/"
  ln -s ../lib64/human-health-os/human_health_os "$S/usr/bin/human-health-os"
  install_desktop_files "$S" /usr
  sed -e "s/@VERSION@/$VERSION/g" -e "s|@STAGE@|$S|" "$P/rpm/human-health-os.spec.in" > "$WORK/human-health-os.spec"
  rpmbuild -bb --quiet --define "_topdir $WORK/rpmbuild" --define "_build_id_links none" \
    --define "use_source_date_epoch_as_buildtime 1" --define "clamp_mtime_to_source_date_epoch 1" \
    --target x86_64 "$WORK/human-health-os.spec" >/dev/null
  cp "$WORK"/rpmbuild/RPMS/x86_64/*.rpm "$OUT/"
  note "rpm PRODUCED"
else note "rpm NOT_RUN (rpmbuild missing)"; fi

# B. AppImage (type 2). Needs appimagetool + runtime; FUSE only to *run* it.
if [ -n "${APPIMAGETOOL:-}" ] && [ -x "$APPIMAGETOOL" ]; then
  A="$WORK/AppDir"
  mkdir -p "$A/usr/lib/human-health-os"
  cp -a "$BUNDLE/." "$A/usr/lib/human-health-os/"
  install -m755 "$P/appimage/AppRun" "$A/AppRun"
  install_desktop_files "$A" /usr
  install -m644 "$P/$ID.desktop" "$A/$ID.desktop"
  install -m644 "$P/icons/$ID.svg" "$A/$ID.svg"
  ln -s "$ID.svg" "$A/.DirIcon"
  RT=(); [ -n "${APPIMAGE_RUNTIME:-}" ] && RT=(--runtime-file "$APPIMAGE_RUNTIME")
  ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$APPIMAGETOOL" --no-appstream "${RT[@]}" "$A" \
    "$OUT/HumanHealthOS-${VERSION//\~/-}-x86_64.AppImage" > "$WORK/appimagetool.log" 2>&1 \
    || { cat "$WORK/appimagetool.log" >&2; exit 1; }
  note "AppImage PRODUCED"
else note "AppImage NOT_RUN (APPIMAGETOOL not provided)"; fi

# A. Flatpak: only with flatpak-builder and the Freedesktop runtime installed.
if command -v flatpak-builder >/dev/null && flatpak info org.freedesktop.Platform//24.08 >/dev/null 2>&1; then
  note "Flatpak: builder present, build it with the manifest in packaging/linux/flatpak"
else note "Flatpak NOT_RUN (flatpak-builder or org.freedesktop.Platform//24.08 unavailable)"; fi

( cd "$OUT" && sha256sum -- *.tar.zst *.deb *.rpm *.AppImage 2>/dev/null > SHA256SUMS || true )
cat "$OUT/SHA256SUMS"
