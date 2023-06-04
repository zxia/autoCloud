function forceDeleteDomain(){
  # declare the namespace that is stuck
  local STUCKED_NS=$1
  kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $STUCKED_NS

  kubectl get namespace $STUCKED_NS -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/$STUCKED_NS/finalize -f -
}

function findImageTag(){
  local IMAGE_ID=$1
  docker image inspect --format '{{json .}}' "$IMAGE_ID" | jq -r '. | {Id: .Id, Digest: .Digest, RepoDigests: .RepoDigests, Labels: .Config.Labels}'
}

function clearVolcano(){
  kubectl get ValidatingWebhookConfiguration -n kube-system  | grep volcano | awk '{print $1}' | xargs -I{} kubectl delete ValidatingWebhookConfiguration {} -n kube-system
  kubectl get MutatingWebhookConfiguration -n kube-system  | grep volcano | awk '{print $1}' | xargs -I{} kubectl delete MutatingWebhookConfiguration {} -n kube-system
}

