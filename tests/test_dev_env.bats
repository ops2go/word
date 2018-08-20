#!/usr/bin/env bats
# INTERNAL TESTS TO VERIFY YOUR IMPLEMENTATION #

# INSTALL BATS:
# To install https://github.com/bats-core/bats-core#installing-bats-from-source

# USAGE:
# Run this from the same folder as your Dockerfile
container_name="app-homework"
image_name="app-homework-image"

function build_container() {
  docker build -t ${image_name} .
}

function run_container() {
  docker run -d -p 8080:8080 --name "${container_name}" ${image_name}
}

function clean_up() {
  docker stop ${container_name}
  docker rm -v ${container_name}
  docker rmi ${image_name}
}

function setup() {
  if [[ "${BATS_TEST_NUMBER}" -eq 1 ]]; then
    clean_up || echo cleanup
  fi
}

function teardown() {
  if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
    echo "OIMG"
    if docker exec ${container_name} whoami; then
      docker stop ${container_name}
      docker rm -v ${container_name} 
      docker rmi ${image_name}
    fi
  fi
}

@test "Container Build" {
  run build_container
  [ "$status" -eq 0 ]
}

@test "Run Container" {
  run_container
  sleep 3 # wait three seconds for container to be running
  run docker exec ${container_name} whoami
  [ "$status" -eq 0 ]
}

@test "Test accessing localhost:8080/word" {
  run curl --fail localhost:8080/word
  [ "$status" -eq 0 ]
}

@test "Test 404 on localhost:8080/wording" {
  run curl --fail localhost:8080/wording
  [ "$status" -eq 22 ]
}

@test "Test accessing mysql-via-container" {
  skip
  # This test would require the user to make design assumptions -- we'll test this manually for now
}

@test "Test entrypoint --help command" {
  run docker run --rm $image_name --help
  [ "$status" -eq 1 ]
}

@test "Test entrypoint for command passthrough" {
  run docker run --rm ${image_name} whoami
  [ "$status" -eq 0 ]
}
