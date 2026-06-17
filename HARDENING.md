<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.14

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.14** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In entrypoint.sh, user-controlled input values are written to $GITHUB_OUTPUT without sanitization. Specifically:

1. `IMAGE_TAG` is set directly from `$INPUT_IMAGE_TAG` (a user-supplied action input) and written via `echo deployed_image_tag="${IMAGE_TAG}" >> $GITHUB_OUTPUT` with no `printf '%s' ... | tr -d '\n\r'` sanitization step.

2. `SERVICE_NAME` is derived from `$INPUT_SERVICE_NAME` (user-supplied) and written via `echo cloud_run_revision="${SERVICE_NAME}-${REVISION_SUFFIX}" >> $GITHUB_OUTPUT` without sanitization.

3. `REVISION_SUFFIX` is derived from `IMAGE_TAG` (itself from user input) and also written to `$GITHUB_OUTPUT` in the same line without sanitization.

An attacker who controls these inputs could inject newlines into the output, poisoning subsequent steps that read these outputs or other `$GITHUB_OUTPUT` entries written after them.

Locations:

- `entrypoint.sh:196`
- `entrypoint.sh:197`
- `entrypoint.sh:199`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in entrypoint.sh at the end of the file where user-controlled values were written to $GITHUB_OUTPUT without sanitization. Added three sanitization steps using `printf '%s' ... | tr -d '\n\r'` for IMAGE_TAG (→ safe_image_tag), SERVICE_NAME (→ safe_service_name), and REVISION_SUFFIX (→ safe_revision_suffix) before writing them to $GITHUB_OUTPUT. The sanitized variables are then used in the echo statements for deployed_image_tag, cloud_run_revision, and cloud_run_endpoint outputs.

