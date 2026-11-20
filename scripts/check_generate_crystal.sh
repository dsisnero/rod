#!/usr/bin/env bash
# Regenerates the CDP bindings from the pinned protocol into a scratch tree and
# compares them with the committed src/cdp.
#
# src/cdp is generated, not hand-written (docs/generation.md). This gate proves
# the committed tree still matches generator output for the pinned protocol, so
# a hand edit, a template regression, or a half-applied regeneration cannot go
# unnoticed. It needs network access the first time (the PDL files are fetched
# from googlesource.com and cached under temp/cdproto-gen).
set -euo pipefail

ROOT_DIR="${1:-$(pwd)}"
CHROMIUM="${CDP_CHROMIUM:-160.0.8168.1}"
V8="${CDP_V8:-16.0.61}"
OUT="${ROOT_DIR}/temp/cdp_generated"

cd "${ROOT_DIR}"

rm -rf "${OUT}"
mkdir -p "${OUT}"

crystal build src/pdlgen.cr -o bin/pdlgen-crystal
./bin/pdlgen-crystal --chromium="${CHROMIUM}" --v8="${V8}" --out "${OUT}" >/dev/null

# `make generate-crystal` formats the tree after writing it, so mirror that here.
crystal tool format "${OUT}" >/dev/null

# An exFAT checkout emits AppleDouble sidecars next to every file; they are
# filesystem noise, not generated sources.
if ! diff -r -q -x '._*' -x '.DS_Store' "${OUT}" "${ROOT_DIR}/src/cdp"; then
  echo "" >&2
  echo "src/cdp does not match the generated tree (Chromium ${CHROMIUM} / V8 ${V8})." >&2
  echo "Re-run: make generate-crystal CDP_CHROMIUM=${CHROMIUM} CDP_V8=${V8}" >&2
  echo "then review the diff (and re-apply any curation it drops)." >&2
  exit 1
fi

echo "CDP bindings match the generated tree (Chromium ${CHROMIUM} / V8 ${V8})."
