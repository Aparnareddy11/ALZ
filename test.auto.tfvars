# Required ARC GitHub App inputs
github_config_url = "https://github.com/Aparnareddy11/ALZ"

# Set GitHub App ID values through repository variables.
# The workflows export them as TF_VAR_github_app_id,
# TF_VAR_github_app_installation_id, and TF_VAR_github_app_private_key.
# Required repository variables:
# - GIT_APP_ID
# - GIT_APP_INSTALLATION_ID
# Required repository secret:
# - GIT_APP_PRIVATE_KEY

# Optional ARC settings
arc_runner_scale_set_name    = "aks-arc-runners"
arc_min_runners              = 1
arc_max_runners              = 10
arc_controller_chart_version = "0.11.0"
arc_runner_chart_version     = "0.11.0"
