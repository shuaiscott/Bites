output "fruit-db-username" {
  value = module.fruit-db.db_instance_name
}

output "fruit-db-password" {
  value     = module.fruit-db.db_instance_password
  sensitive = true # Generally not advised, but doing so for this demonstration to export the db values
}