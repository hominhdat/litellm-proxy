// datasource get all vpc information
data "aws_vpc" "litellm-proxy-vpc" {
  filter {
    name   = "tag:Name"
    values = ["litellm-proxy-vpc"]
  }
}
