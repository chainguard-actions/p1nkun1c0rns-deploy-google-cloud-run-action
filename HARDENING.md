<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.14

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.14** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

entrypoint.sh writes values derived from action inputs to $GITHUB_OUTPUT without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). Specifically:

1. `deployed_image_tag` (line ~197): `echo deployed_image_tag="${IMAGE_TAG}" >> $GITHUB_OUTPUT` — IMAGE_TAG is set directly from $INPUT_IMAGE_TAG (action input `image_tag`) or $INPUT_IMAGE_TAG_PATTERN. An attacker-controlled newline in the input can inject additional key=value pairs into GITHUB_OUTPUT.

2. `cloud_run_revision` (line ~195): `echo cloud_run_revision="${SERVICE_NAME}-${REVISION_SUFFIX}" >> $GITHUB_OUTPUT` — SERVICE_NAME derives from $INPUT_SERVICE_NAME (action input `service_name`), and REVISION_SUFFIX derives from IMAGE_TAG. Both are workflow-controlled and unsanitized before the write.

The fix requires sanitizing each value before writing: `safe=$(printf '%s' "$IMAGE_TAG" | tr -d '\n\r')` and then `echo deployed_image_tag="$safe" >> $GITHUB_OUTPUT`.

Locations:

- `entrypoint.sh:195`
- `entrypoint.sh:197`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed entrypoint.sh lines ~195-197: Added sanitization for SERVICE_NAME, REVISION_SUFFIX, and IMAGE_TAG before writing to $GITHUB_OUTPUT. Each value is now passed through `printf '%s' "$VAR" | tr -d '\n\r'` to strip newlines and carriage returns, preventing injection of additional key=value pairs into GITHUB_OUTPUT via attacker-controlled newlines in action inputs (image_tag, service_name).

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two GITHUB_OUTPUT injection vulnerabilities in entrypoint.sh:
1. gcloud_log output (line ~246): Captured the raw log content into `safe_gcloud_log` using `printf '%s' ... | tr -d '\n\r'` before writing to $GITHUB_OUTPUT.
2. cloud_run_endpoint output (line ~251): Captured ENDPOINT into `safe_endpoint` using `printf '%s' "${ENDPOINT}" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT.
Both fixes follow the same sanitization pattern already used for cloud_run_revision and deployed_image_tag in the same script.

