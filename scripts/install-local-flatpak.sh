#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
bundle="${1:-${NHEKO_FLATPAK_BUNDLE:-${repo_root}/nheko-local.flatpak}}"
branch="${NHEKO_FLATPAK_BRANCH:-local}"

if ! command -v flatpak >/dev/null 2>&1; then
    echo "Error: flatpak is required but was not found in PATH." >&2
    exit 1
fi

if [[ ! -f "${bundle}" ]]; then
    echo "Error: Flatpak bundle not found: ${bundle}" >&2
    echo "Build it first with ${repo_root}/scripts/build-local-flatpak.sh" >&2
    exit 1
fi

echo "Installing ${bundle} for the current user..."
flatpak install --user --or-update -y "${bundle}"

echo
echo "Nheko was installed successfully. Launch it with:"
echo "  flatpak run --branch=${branch} im.nheko.Nheko"
