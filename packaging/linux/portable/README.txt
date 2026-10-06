Human OS - Linux x86_64 portable folder (staging preview)

Run:   ./human_health_os
Needs: glibc 2.34 or newer and GTK 3 (Ubuntu 22.04+, Debian 12+, Fedora 35+).

portable_mode.json makes this a portable install. Portable health data must be
encrypted, and the encrypted vault is not built yet (FORGE 004). Until then this
build writes nothing beside the app and nothing to your home folder: entries
last until the app closes. Not for clinical decisions. No network access.

Third-party notices: data/flutter_assets/NOTICES.Z
