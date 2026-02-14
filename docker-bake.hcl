variable "NAMESPACE" {
  default = "local"
}

variable "TAG" {
  default = "latest"
}

variable "PROJECT" {
  default = "distroless-builder"
}

group "default" {
  targets = ["all"]
}

group "all" {
  targets = [
    "httpd",
    "nginx",
    "nginx-stable",
    "php83",
    "php84",
    "php85",
    "perl",
    "wp-cli",
  ]
}

target "_base-common" {
  context = "."
}

target "httpd" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/httpd/2.4/Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-httpd:${TAG}"]
}

target "nginx" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/nginx/latest/Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-nginx:${TAG}"]
}

target "nginx-stable" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/nginx/stable/Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-nginx:stable"]
}

target "php83" {
  inherits = ["_base-common"]
  context = "dockerfiles/php/8.3"
  dockerfile = "Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-php8.3:${TAG}"]
}

target "php84" {
  inherits = ["_base-common"]
  context = "dockerfiles/php/8.4"
  dockerfile = "Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-php8.4:${TAG}"]
}

target "php85" {
  inherits = ["_base-common"]
  context = "dockerfiles/php/8.5"
  dockerfile = "Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-php8.5:${TAG}"]
}

target "perl" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/perl/5.40/Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-perl:${TAG}"]
}

target "wp-cli" {
  inherits = ["_base-common"]
  context = "dockerfiles/wordpress/cli"
  dockerfile = "Dockerfile"
  tags = ["${NAMESPACE}/${PROJECT}-wp-cli:${TAG}"]
}
