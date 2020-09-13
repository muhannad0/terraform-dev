variable "user_names" {
    description = "Create IAM users with these names"
    type = list(string)
    default = ["neo", "trinity", "morpheus"]
}

variable "hero_thousand_faces" {
    description = "Just a map"
    type = map(string)
    default = {
        neo = "hero"
        trinity = "love interest"
        morpheus = "mentor"
    }
}