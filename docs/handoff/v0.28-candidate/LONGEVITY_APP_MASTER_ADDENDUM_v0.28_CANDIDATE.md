# HUMAN HEALTH OS — MASTER ADDENDUM v0.28 CANDIDATE

Status: CANDIDATE_DELTA_ONLY.

This cumulative candidate contains the v0.27 repository-bootstrap/supply-chain increment and v0.28 Linux cross-distribution increment. It requires the exact v0.26 full baseline before CURRENT promotion.

## v0.28 Linux intent

Human OS Linux becomes a first-class shared Flutter target. The packaging strategy is Flatpak + AppImage (when validated) + portable tar fallback + DEB + RPM, with explicit Ubuntu/Debian/Fedora/Nobara smoke evidence and broad derivative coverage through distro-neutral packaging.

## New authoritative addendum files

- `216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md`
- `217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md`
- `218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md`
- `219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md`
- `220_LINUX_DEB_RPM_NATIVE_PACKAGES.md`
- `221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md`
- `222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md`
- `223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md`
- `224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md`
- `225_LINUX_RELEASE_ARTIFACT_MATRIX.md`
- `226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md`

## Runtime honesty

No Linux binary/package was compiled in this Forge because Flutter and Linux package-builder toolchains are not installed in the active runtime. Structural contracts and packaging scaffolds were validated; runtime/package claims remain NOT_RUN.
