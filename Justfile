publish VERSION:
  docker push quay.io/tms/poker:{{VERSION}}
build VERSION:
  docker build -t quay.io/tms/poker:{{VERSION}} poker
build-and-publish VERSION:
  just build {{VERSION}} && just publish {{VERSION}}

create-bender-creds:
  kubectl create secret generic tms-bender-creds \
    --from-file=.dockerconfigjson=$HOME/.k8s/tms-bender-auth.json \
    --type=kubernetes.io/dockerconfigjson

##################################################################

@print-gpus:
  kubectl get pods -A -o json | jq -r ' \
    .items \
    | map(select(.status.phase=="Running")) \
    | map({ \
        ns: .metadata.namespace, \
        pod: .metadata.name, \
        node: .spec.nodeName, \
        gpus: ([ .spec.containers[]? \
                 | ( .resources.limits."nvidia.com/gpu" \
                     // .resources.requests."nvidia.com/gpu" \
                     // "0" ) | tonumber ] | add) \
      }) \
    | map(select(.gpus>0 and .node != null)) \
    | sort_by(.node, .ns, .pod) \
    | group_by(.node) \
    | .[] as $grp \
    | "== Node: \($grp[0].node) ==", \
      "NAMESPACE\tPOD\tGPUs", \
      ( $grp[] | "\(.ns)\t\(.pod)\t\(.gpus)" ), \
      "" \
  ' | column -t -s $'\t' \
  | awk 'NR==1{print; next} /^== /{print ""; print; next} {print}'
