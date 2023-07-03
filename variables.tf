variable "availability_zone1" {
    type = string
    default = "ap-northeast-2a"
}

variable "availability_zone2" {
    type = string
    default = "ap-northeast-2c"
}

variable "git_repo_url" {
    description = "CodePipeline GitHub repository url"
}

variable "github_owner" {
    description = "CodePipeline source GitHub owner"
    type = string
}

variable "github_repo" {
    description =  "Codepipeline GitHub repository name"
    type = string
}

variable "github_branch" {
    type = string
}

variable "github_token" {
    type = string
}


