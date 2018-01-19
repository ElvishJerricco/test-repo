#!/usr/bin/env bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

curl https://hackage.haskell.org/01-index.tar.gz | gunzip > $DIR/../01-index.tar

$(nix-build --no-out-link $DIR/../stackage2nix.nix -A stackage2nix)/bin/stackage2nix \
								   --lts-haskell $DIR/../lts-haskell/ \
								   --all-cabal-hashes $(nix-build --no-out-link $DIR/../all-cabal-hashes.nix) \
								   --hackage-db $DIR/../01-index.tar \
								   --out-packages $DIR/packages.nix \
								   --out-config $DIR/configuration-packages.nix \
								   --out-derivation $DIR/default-old.nix \
								   "$@"
