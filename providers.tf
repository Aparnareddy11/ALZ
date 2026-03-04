provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/alz",
      ref  = "2025.09.0"
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
}

terraform {
  required_version = ">= 1.9, < 2.0"
}
