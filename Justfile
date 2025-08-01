##################################################################
publish VERSION:
  docker push quay.io/tms/poker:{{VERSION}}
build VERSION:
  docker build -t quay.io/tms/poker:{{VERSION}} poker
build-and-publish VERSION:
  just build {{VERSION}} && just publish {{VERSION}}
