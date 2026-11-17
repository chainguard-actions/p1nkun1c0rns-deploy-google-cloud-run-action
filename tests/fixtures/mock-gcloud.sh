# Mock gcloud CLI, loaded into the action's bash entrypoint via BASH_ENV.
# A shell function takes precedence over the real gcloud binary on PATH, so no
# real GCP credentials or network access are needed. Every invocation is
# appended to gcloud-calls.log in the current directory (the workspace).
gcloud() {
  local IFS=' '
  echo "gcloud $*" >> "${MOCK_GCLOUD_LOG:-gcloud-calls.log}"
  case "$1 $2" in
    "version "*)
      echo "Google Cloud SDK (mock)"
      return 0
      ;;
    "auth activate-service-account")
      echo "Activated service account credentials (mock)"
      return 0
      ;;
    "container images")
      echo '[{"tags":["1.2.0","latest"]},{"tags":["1.10.0"]},{"tags":["2.0.0"]},{"tags":["0.9.1"]}]'
      return 0
      ;;
    "run services")
      case "$3" in
        describe)
          if [ "$MOCK_SERVICE_EXISTS" = "true" ]; then
            return 0
          fi
          echo "ERROR: (gcloud.run.services.describe) Cannot find service (mock)" >&2
          return 1
          ;;
        update-traffic)
          echo "Updating traffic... Done. (mock)"
          echo "URL: https://mock-service-abc123-ew.a.run.app"
          return 0
          ;;
      esac
      ;;
    "run deploy")
      echo "Deploying container to Cloud Run service [$3] (mock)"
      echo "Done."
      return 0
      ;;
  esac
  echo "mock gcloud: unexpected invocation: $*" >&2
  return 1
}
