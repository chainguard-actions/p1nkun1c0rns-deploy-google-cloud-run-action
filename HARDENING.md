<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.11

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.11** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

entrypoint.sh writes values derived from user-controlled inputs to $GITHUB_OUTPUT without sanitization. Four unsanitized writes occur at the end of the script:

1. `echo gcloud_log="...$(sed ... gcloud.log)..." >> $GITHUB_OUTPUT` — gcloud.log contains output from commands that process user-controlled inputs (image name, tag, service name, region).
2. `echo cloud_run_revision="${SERVICE_NAME}-${REVISION_SUFFIX}" >> $GITHUB_OUTPUT` — SERVICE_NAME is derived from $INPUT_SERVICE_NAME (user-controlled); REVISION_SUFFIX is derived from IMAGE_TAG which comes from $INPUT_IMAGE_TAG or $INPUT_IMAGE_TAG_PATTERN.
3. `echo cloud_run_endpoint="${ENDPOINT}" >> $GITHUB_OUTPUT` — ENDPOINT is parsed from gcloud traffic.log output which processes user-controlled inputs.
4. `echo deployed_image_tag="${IMAGE_TAG}" >> $GITHUB_OUTPUT` — IMAGE_TAG is set directly from $INPUT_IMAGE_TAG or resolved via $INPUT_IMAGE_TAG_PATTERN.

None of these writes are preceded by the required sanitization step (`safe=$(printf '%s' "$VAR" | tr -d '\n\r')`). An attacker who controls the image tag or service name input could inject newlines to poison subsequent GITHUB_OUTPUT key=value pairs, potentially overwriting other outputs or injecting arbitrary environment variables into downstream steps.

Locations:

- `entrypoint.sh:196`
- `entrypoint.sh:197`
- `entrypoint.sh:198`
- `entrypoint.sh:199`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all four unsanitized writes to $GITHUB_OUTPUT in entrypoint.sh (lines 196-199). Each value (gcloud_log, cloud_run_revision, cloud_run_endpoint, deployed_image_tag) is now sanitized using `printf '%s' "$VAR" | tr -d '\n\r'` before being written to $GITHUB_OUTPUT. This prevents newline injection attacks where an attacker controlling user inputs (image tag, service name, etc.) could inject newlines to poison subsequent GITHUB_OUTPUT key=value pairs. The $GITHUB_OUTPUT variable reference is also now properly quoted.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed all 5 unpinned action references by resolving them to full 40-character commit SHAs (keeping original tags/branches as comments). Added top-level `permissions: {}` to both workflow files to deny all permissions by default, then added minimal job-level permissions: `contents: write` for the publish-image build job (needed for git push via github-push-action) and `contents: read` for both jobs in test.yml (needed for checkout).

