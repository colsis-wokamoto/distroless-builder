variable "NAMESPACE" {
  default = "local"
}

variable "TAG" {
  default = "latest"
}

variable "TIME_ZONE" {
  default = "Asia/Tokyo"
}

variable "WP_VERSION" {
  default = "latest"
}

group "default" {
  targets = ["all"]
}

group "all" {
  targets = [
    "distroless-base-apache24",
    "distroless-base-movabletype",
    "distroless-base-nginx",
    "distroless-base-wordpress-cli",
    "distroless-base-wordpress-php83",
    "distroless-base-wordpress-php84",
    "distroless-base-wordpress-php85",
  ]
}

target "_base-common" {
  context = "."
  args = {
    TIME_ZONE = "${TIME_ZONE}"
  }
}

target "distroless-base-apache24" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/apache24/Dockerfile"
  tags = ["${NAMESPACE}/distroless-base:apache24-${TAG}"]
}

target "distroless-base-movabletype" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/movabletype/Dockerfile"
  tags = ["${NAMESPACE}/distroless-base:movabletype-${TAG}"]
}

target "distroless-base-nginx" {
  inherits = ["_base-common"]
  dockerfile = "dockerfiles/nginx/Dockerfile"
  tags = ["${NAMESPACE}/distroless-base:nginx-${TAG}"]
}

target "distroless-base-wordpress-cli" {
  inherits = ["_base-common"]
  context = "dockerfiles/wordpress/cli"
  dockerfile = "Dockerfile"
  tags = ["${NAMESPACE}/distroless-base:wordpress-cli-${TAG}"]
}

target "distroless-base-wordpress-php83" {
  inherits = ["_base-common"]
  context = "dockerfiles/wordpress/php83"
  dockerfile = "Dockerfile"
  args = {
    TIME_ZONE = "${TIME_ZONE}"
    WP_VERSION = "${WP_VERSION}"
  }
  tags = ["${NAMESPACE}/distroless-base:wordpress-php83-${TAG}"]
}

target "distroless-base-wordpress-php84" {
  inherits = ["_base-common"]
  context = "dockerfiles/wordpress/php84"
  dockerfile = "Dockerfile"
  args = {
    TIME_ZONE = "${TIME_ZONE}"
    WP_VERSION = "${WP_VERSION}"
  }
  tags = ["${NAMESPACE}/distroless-base:wordpress-php84-${TAG}"]
}

target "distroless-base-wordpress-php85" {
  inherits = ["_base-common"]
  context = "dockerfiles/wordpress/php85"
  dockerfile = "Dockerfile"
  args = {
    TIME_ZONE = "${TIME_ZONE}"
    WP_VERSION = "${WP_VERSION}"
  }
  tags = ["${NAMESPACE}/distroless-base:wordpress-php85-${TAG}"]
}
