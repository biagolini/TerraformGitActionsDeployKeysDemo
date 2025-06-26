variable "lambdas" {
  type = map(object({
    repository            = string
    runtime               = string
    handler               = string
    architectures         = string
    ssh_key_name          = string
    environment_variables = optional(map(string), null)
    memory_size           = optional(number)
    ephemeral_storage     = optional(number)
    timeout               = optional(number)
    layers                = optional(list(string))
  }))
}
