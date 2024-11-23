variable "project" {
    description = "プロジェクト設定"
    type = object({
      name = string
    })
    default = {
        name = "Example"
    }
}