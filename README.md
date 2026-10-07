# index

The signed package index for rootbeer, as a TUF repository served by GitHub
Pages from `metadata/` and `targets/`. Each target `<name>.json` lists a
package's versions with the key and manifest digest of each output, so `rb`
believes nothing about a package that the index's keys didn't sign. Outputs
themselves live in `ghcr.io/rootbeer-org/store`, which stays untrusted storage.

- `ceremony.sh` makes the offline root keys and the online key, and signs
  `metadata/1.root.json`. Root keys never come near CI.
- `.github/workflows/sign.yml` merges the entries a pdr run wrote with `rb drv
  index` and signs them with the online key (`RB_INDEX_KEY`). A daily run only
  renews the signatures.
