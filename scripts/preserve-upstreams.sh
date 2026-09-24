#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
destination=${1:-"${repo_root}/.upstream-mirrors"}
cache_root="${repo_root}/.flatpak-builder/git"

if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but was not found in PATH." >&2
    exit 1
fi

mkdir -p -- "${destination}"
destination=$(cd -- "${destination}" && pwd)

names=(
    nheko
    coeurl
    mtxclient
    qt-jdenticon
    olm
)

sources=(
    "${repo_root}"
    "${cache_root}/https_nheko.im_nheko-reborn_coeurl.git"
    "${cache_root}/https_github.com_Nheko-Reborn_mtxclient.git"
    "${cache_root}/https_github.com_Nheko-Reborn_qt-jdenticon.git"
    "${cache_root}/https_gitlab.matrix.org_matrix-org_olm.git"
)

created=0
for index in "${!names[@]}"; do
    name=${names[index]}
    source_repo=${sources[index]}
    if [[ ! -d "${source_repo}" ]]; then
        echo "Warning: ${name} is not available locally; skipping it." >&2
        continue
    fi

    echo "Preserving ${name}..."
    if [[ -f "${source_repo}/shallow" ]]; then
        revision=$(head -n 1 "${source_repo}/shallow")
        archive="${destination}/${name}-source.tar.gz"
        temporary="${destination}/.${name}-source.tar.gz.tmp"
        rm -f -- "${temporary}" "${destination}/${name}.bundle"
        git --git-dir="${source_repo}" archive \
            --format=tar.gz \
            --prefix="${name}/" \
            --output="${temporary}" \
            "${revision}"
        mv -f -- "${temporary}" "${archive}"
        sha256sum "${archive}" >"${archive}.sha256"
        echo "  Cached history is shallow; preserved its complete source tree."
    else
        bundle="${destination}/${name}.bundle"
        temporary="${destination}/.${name}.bundle.tmp"
        rm -f -- "${temporary}" "${destination}/${name}-source.tar.gz" \
            "${destination}/${name}-source.tar.gz.sha256"
        if [[ "${name}" == nheko ]]; then
            git -C "${source_repo}" bundle create "${temporary}" --all
        else
            git --git-dir="${source_repo}" bundle create "${temporary}" --all
        fi
        git bundle verify "${temporary}" >/dev/null
        mv -f -- "${temporary}" "${bundle}"
    fi
    created=$((created + 1))
done

if [[ -n "$(git -C "${repo_root}" status --porcelain)" ]]; then
    echo
    echo "Note: nheko.bundle contains Git commits and refs, not uncommitted working-tree changes."
fi

echo
echo "Created ${created} verified Git bundle or source archive backup(s) in:"
echo "  ${destination}"
echo
echo "To turn a bundle into a bare mirror for pushing elsewhere:"
echo "  git clone --mirror ${destination}/mtxclient.bundle mtxclient.git"
echo "  git -C mtxclient.git push --mirror git@github.com:YOUR_ACCOUNT/mtxclient.git"
