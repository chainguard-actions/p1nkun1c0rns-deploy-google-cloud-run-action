<!-- markdownlint-disable -->

# Hardening Report: p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.13

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **p1nkun1c0rns--deploy-google-cloud-run-action/v1.21.13** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

entrypoint.sh writes values derived from user-controlled inputs and external command output to $GITHUB_OUTPUT without the required sanitization step (printf '%s' ... | tr -d '\n\r'). Four unsanitized writes occur at the end of the script: (1) gcloud_log= writes content of gcloud.log and traffic.log (external command output) directly to $GITHUB_OUTPUT; (2) cloud_run_revision= writes ${SERVICE_NAME}-${REVISION_SUFFIX} where SERVICE_NAME comes from $INPUT_SERVICE_NAME and REVISION_SUFFIX is derived from $INPUT_IMAGE_TAG, both user-controlled inputs; (3) cloud_run_endpoint= writes ${ENDPOINT} parsed from gcloud command output; (4) deployed_image_tag= writes ${IMAGE_TAG} set directly from $INPUT_IMAGE_TAG. A newline character embedded in any of these values would allow injection of arbitrary key=value pairs into $GITHUB_OUTPUT, enabling an attacker to set arbitrary action outputs. Fix: apply safe=$(printf '%s' "$VAR" | tr -d '\n\r') before each write.

Locations:

- `entrypoint.sh:243`
- `entrypoint.sh:244`
- `entrypoint.sh:245`
- `entrypoint.sh:246`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed all four unsanitized $GITHUB_OUTPUT writes in entrypoint.sh (lines 243-246). Each value (gcloud_log, cloud_run_revision, cloud_run_endpoint, deployed_image_tag) is now sanitized using `printf '%s' "$VAR" | tr -d '\n\r'` before being written to $GITHUB_OUTPUT, preventing newline injection attacks that could allow arbitrary key=value pairs to be injected into the action's outputs.

