<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.16** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

entrypoint.sh writes values derived from workflow-controlled inputs to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Three unsanitized writes are present:

1. `echo deployed_image_tag="${IMAGE_TAG}" >> $GITHUB_OUTPUT` — IMAGE_TAG is set directly from `$INPUT_IMAGE_TAG` (a caller-supplied input) or computed via `$INPUT_IMAGE_TAG_PATTERN`.
2. `echo cloud_run_revision="${SERVICE_NAME}-${REVISION_SUFFIX}" >> $GITHUB_OUTPUT` — SERVICE_NAME is derived from `$INPUT_SERVICE_NAME` and REVISION_SUFFIX is derived from IMAGE_TAG (which comes from inputs).
3. `echo gcloud_log=... >> $GITHUB_OUTPUT` — embeds log content that may include attacker-influenced values.

All INPUT_* variables are inherited process env vars set by the calling workflow and must be treated as untrusted. A newline injected into any of these values could allow an attacker to write arbitrary key=value pairs into GITHUB_OUTPUT, potentially overwriting outputs consumed by downstream steps. The fix is to sanitize each value before writing: `safe=$(printf '%s' "$IMAGE_TAG" | tr -d '\n\r')` then `echo "deployed_image_tag=${safe}" >> $GITHUB_OUTPUT`.

Locations:

- `entrypoint.sh:196`
- `entrypoint.sh:197`
- `entrypoint.sh:198`
- `entrypoint.sh:199`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all four unsanitized writes to $GITHUB_OUTPUT in entrypoint.sh (lines 196-199). Each value is now sanitized with `printf '%s' "$VAR" | tr -d '\n\r'` before being written: (1) gcloud_log content, (2) cloud_run_revision (SERVICE_NAME + REVISION_SUFFIX), (3) cloud_run_endpoint (ENDPOINT), and (4) deployed_image_tag (IMAGE_TAG). This prevents newline injection attacks where attacker-controlled input values could inject arbitrary key=value pairs into GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings across two workflow files:

publish-image.yml:
- Pinned actions/checkout@v7 → @3d3c42e5aac5ba805825da76410c181273ba90b1 # v7
- Pinned ad-m/github-push-action@master → @881a6320fdb16eb5318c5054f31c218aec2b324c # master
- Added top-level `permissions: contents: write` (required for the git push step via github-push-action)

test.yml:
- Pinned actions/checkout@v7 → @3d3c42e5aac5ba805825da76410c181273ba90b1 # v7 (both occurrences)
- Pinned actionshub/markdownlint@v3.1.4 → @6c82ff529253530dfbf75c37570876c52692835f # v3.1.4
- Pinned karancode/yamllint-github-action@master → @4052d365f09b8d34eb552c363d1141fd60e2aeb2 # master
- Added top-level `permissions: contents: read` (minimum needed for checkout)

