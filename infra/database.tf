resource "google_firestore_database" "default" {
  project                 = google_project.default.project_id
  name                    = "(default)"
  location_id             = var.google_project_location
  type                    = "FIRESTORE_NATIVE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "ABANDON"

  depends_on = [
    google_project_service.default,
  ]
}

resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta
  project  = google_project.default.project_id
  source {
    files {
      name    = "firestore.rules"
      content = file("./firestore.rules")
    }
  }

  depends_on = [
    google_firestore_database.default,
  ]
}

resource "google_firebaserules_release" "firestore" {
  provider     = google-beta
  name         = "cloud.firestore"
  ruleset_name = google_firebaserules_ruleset.firestore.name
  project      = google_project.default.project_id

  depends_on = [
    google_firestore_database.default,
  ]
}

# Firestoreのインデックス定義
# 複合インデックスの例: tasks コレクションに対して userId と createdAt でのクエリを最適化
resource "google_firestore_index" "tasks_user_created" {
  project     = google_project.default.project_id
  collection  = "tasks"
  database    = google_firestore_database.default.name
  
  fields {
    field_path = "userId"
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "createdAt"
    order      = "DESCENDING"
  }

  depends_on = [
    google_firestore_database.default,
  ]
}

# 複合インデックスの例: tasks コレクションに対して status と dueDate でのクエリを最適化
resource "google_firestore_index" "tasks_status_due_date" {
  project     = google_project.default.project_id
  collection  = "tasks"
  database    = google_firestore_database.default.name
  
  fields {
    field_path = "status"
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "dueDate"
    order      = "ASCENDING"
  }

  depends_on = [
    google_firestore_database.default,
  ]
}

# 複合インデックスの例: houses コレクションに対して ownerId と lastUpdated でのクエリを最適化
resource "google_firestore_index" "houses_owner_updated" {
  project     = google_project.default.project_id
  collection  = "houses"
  database    = google_firestore_database.default.name
  
  fields {
    field_path = "ownerId"
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "lastUpdated"
    order      = "DESCENDING"
  }

  depends_on = [
    google_firestore_database.default,
  ]
}
