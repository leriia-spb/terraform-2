data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket                      = "tf-states-va.aleshina"
    key                         = "shared/terraform.tfstate"
    region                      = "ru-msk"
    endpoints                   = { s3 = "https://hb.ru-msk.vkcs.cloud" }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

locals {
  shared            = data.terraform_remote_state.shared.outputs
  dev_backend_ips   = ["10.25.0.10", "10.25.0.11"]
}
