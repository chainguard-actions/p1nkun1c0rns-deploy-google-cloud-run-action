<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.15

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.15** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

entrypoint.sh writes values derived from workflow-controlled (untrusted) inputs to $GITHUB_OUTPUT without sanitization. In a Docker action, inputs are passed as INPUT_* environment variables inherited from the calling workflow — these are untrusted per the check's scope. Four unsanitized writes occur at the end of the script:

1. `echo gcloud_log="..." >> $GITHUB_OUTPUT` — embeds gcloud.log/traffic.log content (which can contain attacker-influenced data from image names, service names, etc.) without stripping newlines.
2. `echo cloud_run_revision="${SERVICE_NAME}-${REVISION_SUFFIX}" >> $GITHUB_OUTPUT` — SERVICE_NAME comes directly from INPUT_SERVICE_NAME (user input); REVISION_SUFFIX is derived from INPUT_IMAGE_TAG or INPUT_IMAGE_TAG_PATTERN.
3. `echo cloud_run_endpoint="${ENDPOINT}" >> $GITHUB_OUTPUT` — ENDPOINT is extracted from gcloud output which reflects user-supplied region/service name.
4. `echo deployed_image_tag="${IMAGE_TAG}" >> $GITHUB_OUTPUT` — IMAGE_TAG comes directly from INPUT_IMAGE_TAG (user input).

None of these writes are preceded by the required sanitization step: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')`. An attacker supplying a newline-containing value in inputs.image_tag or inputs.service_name could inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially overwriting subsequent outputs or injecting environment variables into downstream steps.

Locations:

- `entrypoint.sh:196`
- `entrypoint.sh:197`
- `entrypoint.sh:198`
- `entrypoint.sh:199`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all four unsanitized writes to $GITHUB_OUTPUT in entrypoint.sh (lines 196-199). Each write now sanitizes the value using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT. The four outputs fixed are: gcloud_log (which already converts newlines to <br> tags via sed, but still needed carriage return stripping), cloud_run_revision (derived from INPUT_SERVICE_NAME and IMAGE_TAG), cloud_run_endpoint (extracted from gcloud output), and deployed_image_tag (directly from INPUT_IMAGE_TAG). Also improved quoting of $GITHUB_OUTPUT to use double quotes throughout.

