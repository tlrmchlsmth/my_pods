##################################################################
publish VERSION:
  docker push quay.io/tms/poker:{{VERSION}}

build VERSION:
  docker build -t quay.io/tms/poker:{{VERSION}} poker
