#!/usr/bin/env bash
# The offline root ceremony for the package index. It makes two root keys, a
# primary and a backup that can each sign alone, and the online key that signs
# targets, snapshot, and timestamp, then signs 1.root.json with both root keys.
#
#   ./ceremony.sh <directory>
#
# Afterwards keep keys/root-*.der offline and delete them here. keys/online.der
# becomes the index repository's RB_INDEX_KEY secret, base64 encoded, and
# metadata/1.root.json goes into the index repository and into rb.
set -euo pipefail

out=$1
if [[ -e $out ]]; then
    echo "$out already exists" >&2
    exit 1
fi

umask 077
mkdir -p "$out/keys" "$out/metadata"
for key in root-primary root-backup online; do
    openssl genpkey -algorithm ed25519 -outform DER -out "$out/keys/$key.der"
done

root="$out/metadata/1.root.json"
tuftool root init "$root"
tuftool root expire "$root" "in 365 days"
for role in root snapshot targets timestamp; do
    tuftool root set-threshold "$root" "$role" 1
done

tuftool root add-key "$root" -k "$out/keys/root-primary.der" -r root
tuftool root add-key "$root" -k "$out/keys/root-backup.der" -r root
tuftool root add-key "$root" -k "$out/keys/online.der" -r snapshot -r targets -r timestamp
tuftool root sign "$root" -k "$out/keys/root-primary.der" -k "$out/keys/root-backup.der"
echo "signed $root"
