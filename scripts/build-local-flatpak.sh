#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
manifest="${repo_root}/im.nheko.Nheko.yaml"
build_dir="${NHEKO_FLATPAK_BUILD_DIR:-${repo_root}/build-flatpak}"
flatpak_repo="${NHEKO_FLATPAK_REPO:-${repo_root}/flatpak-repo}"
bundle="${NHEKO_FLATPAK_BUNDLE:-${repo_root}/nheko-local.flatpak}"
branch="${NHEKO_FLATPAK_BRANCH:-local}"
runtime_repo=https://flathub.org/repo/flathub.flatpakrepo

for command in flatpak flatpak-builder; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        echo "Error: ${command} is required but was not found in PATH." >&2
        exit 1
    fi
done

echo "Adding the Flathub remote if necessary..."
flatpak remote-add --user --if-not-exists flathub "${runtime_repo}"

builder_args=(
    --force-clean
    --user
    --install-deps-from=flathub
    --ccache
    --disable-updates
    --repo="${flatpak_repo}"
    --default-branch="${branch}"
)

if [[ -n "${NHEKO_FLATPAK_JOBS:-}" ]]; then
    builder_args+=(--jobs="${NHEKO_FLATPAK_JOBS}")
fi

echo "Building Nheko..."
flatpak-builder "${builder_args[@]}" "${build_dir}" "${manifest}"

echo "Creating ${bundle}..."
flatpak build-bundle \
    --runtime-repo="${runtime_repo}" \
    "${flatpak_repo}" \
    "${bundle}" \
    im.nheko.Nheko \
    "${branch}"

echo
echo "Flatpak bundle created successfully:"
echo "  ${bundle}"
echo
echo "Install it with:"
printf '  %q %q\n' "${repo_root}/scripts/install-local-flatpak.sh" "${bundle}"
