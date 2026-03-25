# Required ARC GitHub App inputs
github_config_url          = "https://github.com/Aparnareddy11/ALZ"
github_app_id              = "3065029"
github_app_installation_id = "115599835"

# Set GitHub App private key through repository secret GIT_APP_PRIVATE_KEY.
# The workflow exports it as TF_VAR_github_app_private_key.

# Optional ARC settings
arc_runner_scale_set_name    = "aks-arc-runners"
arc_min_runners              = 1
arc_max_runners              = 10
arc_controller_chart_version = "0.11.0"
arc_runner_chart_version     = "0.11.0"
