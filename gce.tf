resource "google_compute_instance" "airbyte_instance" {
  name                    = "${var.project}-airbyte"
  tags                    = ["airbyte", "http-server"]
  machine_type            = var.airbyte_machine_type
  project                 = var.project
  metadata_startup_script = file("./sh_scripts/airbyte.sh")

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20230206"
    }
  }
  network_interface {
    network    = "default"
    subnetwork = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }
}