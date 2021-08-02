# allows for multiple apis by using the locals block and for-each
locals {
  enabled_apis_list = [for api in var.api-list : api]
}

//  Random strings to create a project.
resource "random_string" "random" {
  length  = 4
  special = false
  number  = true
  upper   = false
}

//  Create a project in the specified folder.
resource "google_project" "my_project-in-a-folder" {
  name            = "charles-project-lien-${random_string.random.id}"
  project_id      = "charles-project-lien-${random_string.random.id}"
  folder_id       = google_folder.department1.name
  billing_account = "00E11A-0AB9A2-077BE7" # Sourced Group
  //   billing_account = "01411F-42C719-AFB386" # Hopper Acct 
}

//  Create a folder
resource "google_folder" "department1" {
  display_name = "charles-sandbox"
  parent       = "organizations/670891908486" # Sourced Group
  // parent       = "organizations/980422189402"
}

//  Enable APIs
resource "google_project_service" "project" {
  depends_on                 = [google_project.my_project-in-a-folder]
  for_each                   = { for selected-api in local.enabled_apis_list : selected-api => selected-api }
  project                    = google_project.my_project-in-a-folder.id
  disable_dependent_services = true
  service                    = each.value
  disable_on_destroy         = true
}


// //  Create a lien on a project
// resource "google_resource_manager_lien" "lien" {
//   parent       = "projects/${google_project.my_project-in-a-folder.number}"
//   restrictions = ["resourcemanager.projects.delete"]
//   origin       = "machine-readable-explanation"
//   reason       = "This project is an important environment"
// }
