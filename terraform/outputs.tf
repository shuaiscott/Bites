output "fruit-db-username" {
  value = module.fruit-db.db_instance_name
}

output "fruit-db-password" {
  value     = module.fruit-db.db_instance_password
  sensitive = true # Generally not advised, but doing so for this demonstration to export the db values
}

# Output ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
        # EC2 Instances for Fruit Microservice
      fruit_service_hostnames = concat(
        [for instance in module.fruit_instances_a : instance.public_dns],
        [for instance in module.fruit_instances_b : instance.public_dns]
      )

      # Fruit DB config
      fruit_db_hostname = module.fruit-db.db_instance_address
      fruit_db_name = module.fruit-db.db_instance_name
      fruit_db_port = module.fruit-db.db_instance_port
      fruit_db_username = module.fruit-db.db_instance_username
    }
  )
  filename = "../ansible/inventory"
}