locals {
  k8s_common_annotations = {
    "thoughtlyify.io/directory"  = "infrastructure/orchestrator/"
    "thoughtlyify.io/repository" = "github.com/cjhouser/thoughtlyify.io"
  }
  k8s_common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
