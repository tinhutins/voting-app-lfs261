#This code creates two instances named vm-1 and vm-2 using the specified machine_type, image, and zone. 
#The instances use the Ubuntu 20.04 LTS image and are connected to the default network. 
#Additionally, the instances are assigned public external IP addresses using the google_compute_address resource.
#The for_each block is used to create two instances with unique names, metadata startup scripts, and public external IP addresses.

# # Define resources
# resource "google_compute_address" "vm_ips" {
#   count = 2
#   name  = "vm-${count.index + 1}-ip"
# }

# resource "google_compute_instance" "vms" {
#   for_each = {
#   }

#   name         = each.key
#   machine_type = var.machine_type
#   zone         = var.zone

#   boot_disk {
#     initialize_params {
#       image = var.image
#     }
#   }

#   network_interface {
#     network = "default"
#     access_config {
#       nat_ip = google_compute_address.vm_ips[each.key].address
#     }
#   }

#   metadata_startup_script = each.value
# }