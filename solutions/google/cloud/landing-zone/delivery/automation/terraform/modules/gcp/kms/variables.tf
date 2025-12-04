#------------------------------------------------------------------------------
# GCP Cloud KMS Module Variables
#------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID for KMS resources"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "kms" {
  description = "KMS configuration object"
  type = object({
    keyring_name      = string
    keyring_location  = string
    key_count         = number
    key_rotation_days = number
    key_algorithm     = string
    protection_level  = string
  })
}

variable "key_purposes" {
  description = "List of key purposes to create (e.g., primary, storage, compute)"
  type        = list(string)
  default     = []  # Empty means use defaults based on key_count
}

variable "encrypter_decrypter_members" {
  description = "Map of key name to list of members for encrypter/decrypter role"
  type        = map(list(string))
  default     = {}
}

variable "common_labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}
