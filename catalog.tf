resource "google_service_account" "central_catalog_admin_sa" {
  account_id = "catalog-admin-sa"
  project    = var.project
}


resource "google_project_iam_member" "admin_sa_catalog_admin" {
  project = var.project
  role    = "roles/datacatalog.admin"
  member  = "serviceAccount:${google_service_account.central_catalog_admin_sa.email}"
}


resource "google_data_catalog_tag_template" "data_product" {
  tag_template_id = "data_product"
  region          = var.region

  display_name = "Data Product"

  fields {
    field_id     = "data_domain"
    display_name = "Data domain"
    description  = "The broad category for the data"
    order        = 11
    is_required  = true
    type {
      enum_type {
        allowed_values {
          display_name = "User Journey"
        }
        allowed_values {
          display_name = "Operationnal Excellence"
        }
        allowed_values {
          display_name = "Markets"
        }
        allowed_values {
          display_name = "Finance"
        }
        allowed_values {
          display_name = "HR"
        }
        allowed_values {
          display_name = "Legal"
        }
        allowed_values {
          display_name = "Other"
        }
      }
    }
  }

  fields {
    field_id     = "data_product_name"
    display_name = "Data product name"
    description  = "The name of the data product"
    is_required  = true
    order        = 9
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "data_product_description"
    display_name = "Data product description"
    description  = "Short description of the data product"
    is_required  = false
    order        = 8
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "business_owner"
    display_name = "Business owner"
    description  = "Name of the business person who owns the data product"
    is_required  = true
    order        = 7
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "technical_owner"
    display_name = "Technical owner"
    description  = "Name of the technical person who owns the data product"
    is_required  = true
    order        = 6
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "documentation_link"
    display_name = "Documentation Link"
    description  = "Link to helpful documentation about the data product"
    is_required  = false
    order        = 3
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "access_request_link"
    display_name = "Access request link"
    description  = "How to request access the data product"
    is_required  = false
    order        = 2
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "data_product_status"
    display_name = "Data product status"
    description  = "Status of the data product"
    is_required  = true
    order        = 1
    type {
      enum_type {
        allowed_values {
          display_name = "DRAFT"
        }
        allowed_values {
          display_name = "PENDING"
        }
        allowed_values {
          display_name = "REVIEW"
        }
        allowed_values {
          display_name = "DEPLOY"
        }
        allowed_values {
          display_name = "RELEASED"
        }
        allowed_values {
          display_name = "DEPRECATED"
        }
      }
    }
  }
}


resource "google_data_catalog_tag_template" "freshness" {
  tag_template_id = "freshness"
  region          = var.region

  display_name = "Data Freshness"

  fields {
    field_id     = "expected_freshness"
    display_name = "Expected freshness of the data"
    type {
      primitive_type = "STRING"
    }
    is_required = true
  }

  fields {
    field_id     = "sla_period"
    display_name = "SLA - measurement period"
    type {
      enum_type {
        allowed_values {
          display_name = "WEEK"
        }
        allowed_values {
          display_name = "MONTH"
        }
      }
    }
  }

  force_delete = true
}





# Tag Template Visibility

resource "google_data_catalog_tag_template_iam_member" "template_viewer_to_all_project_users" {
  count        = length(tolist([google_data_catalog_tag_template.data_product.tag_template_id, google_data_catalog_tag_template.freshness.tag_template_id]))
  project      = var.project
  tag_template = tolist([google_data_catalog_tag_template.data_product.tag_template_id, google_data_catalog_tag_template.freshness.tag_template_id])[count.index]
  role         = "roles/datacatalog.tagTemplateViewer"
  member       = "user:j.payan@cityscoot.eu"
  region       = var.region
}