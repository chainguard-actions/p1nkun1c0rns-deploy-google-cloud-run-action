# Sourced by non-interactive bash (via BASH_ENV) before the action's
# entrypoint.sh runs. Shadows the real gcloud CLI with the fake test double,
# because the harness has no Google Cloud credentials.
# Under act the workspace is mounted at the same path as in the job container
# (NOT /github/workspace), so resolve the fake relative to this file.
_FIX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAKE_GCLOUD="$_FIX_DIR/fakebin/gcloud"
export FAKE_GCLOUD
# Make sure the fake logs into the same workspace the job container sees.
if [ -z "$GITHUB_WORKSPACE" ] || [ ! -d "$GITHUB_WORKSPACE" ]; then
  GITHUB_WORKSPACE="$(cd "$_FIX_DIR/../.." && pwd)"
  export GITHUB_WORKSPACE
fi
gcloud() {
  sh "$FAKE_GCLOUD" "$@"
}
export -f gcloud
