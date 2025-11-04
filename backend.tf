terraform {
  backend "s3" {
    region = "ap-south-1"
    bucket = "gavhane-21"
    key = "dev/dev.tfstate"
  }
}

