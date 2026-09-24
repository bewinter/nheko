# Preserved upstream sources

This directory contains small third-party components that Nheko needs at build
time or includes directly.  Keeping them here makes the source tree resilient
to upstream hosting disappearing.

## coeurl

`coeurl/` is the complete source tree from:

- Upstream: `https://nheko.im/nheko-reborn/coeurl.git`
- Tag: `v0.3.2`
- Commit: `1c3a9029581a08749874226b68bb40c196ed21bb`
- License: MIT (`coeurl/LICENSE`)

It was recovered from flatpak-builder's verified local Git cache.  Both the
Flatpak manifest and CMake's `USE_BUNDLED_COEURL` path prefer this copy, so a
build no longer depends on `nheko.im` being reachable.

The application artwork, translations, desktop metadata, and other Nheko-owned
runtime resources are already versioned in the top-level `resources/` tree.
