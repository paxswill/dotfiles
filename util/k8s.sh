# This file contains functionality for showing the Kubernetes context and
# namespace in the prompt. It's being kept out of prompt.sh as it's a bit messy.

# Flag controlling whether or not to show the k8s environment
declare -gi SHOW_KUBERNETES_ENV=0

show_k8s_env() {
	if ! _prog_exists kubectl; then
		echo "Missing kubectl"
		return 1
	else
		SHOW_KUBERNETES_ENV=1
	fi
}

hide_k8s_env() {
	SHOW_KUBERNETES_ENV=0
}

toggle_k8s_env() {
	if [ ${SHOW_KUBERNETES_ENV} = 0 ]; then
		show_k8s_env
	else
		hide_k8s_env
	fi
}

# Detect if there's the shell or Go versions of kubectx/kubens. If they're the
# bash versions, just use kubectl. The _USE_KUBENS and _USE_KUBECTX global env
# vars will be set by _detect_k8s_util_versions to either 0 or 1 for if those
# commands should be used.
_detect_k8s_util_versions() {
	for UTIL in kubectx kubens; do
		if ! _prog_exists $UTIL || [ "$(head -c2 $(type -p ${UTIL}))" = "#!" ]; then
			declare -gi _USE_${UTIL^^}=0
		else
			declare -gi _USE_${UTIL^^}=1
		fi
	done
}
_detect_k8s_util_versions

declare PROMPT_K8S_CONTEXT
declare PROMPT_K8S_NAMESPACE
update_k8s_env() {
	# Only use the Go versions if they're both available, as using kubectl gets
	# both in one swoop.
	if [ ${_USE_KUBENS} = 1 ] && [ ${_USE_KUBECTX} = 1]; then
		PROMPT_K8S_CONTEXT="$(kubectx --current)"
		PROMPT_K8S_NAMESPACE="$(kubens --current)"
	else
		# Reset the values in case there isn't a current valid context
		PROMPT_K8S_CONTEXT=""
		PROMPT_K8S_NAMESPACE=""
		# Loop through the contexts, finding the current one (marked by an extra
		# field)
		KUBECTL_OUTPUT="$(kubectl config get-contexts --no-headers)"
		mapfile -t OUTPUT_LINES <<<${KUBECTL_OUTPUT}
		for LINE in "${OUTPUT_LINES[@]}"; do
			read -a FIELDS <<<${LINE}
			# The columns are current, name, cluster, user, namespace
			# The current context has a '*' in the "current" column, otherwise
			# that column is empty.
			# The namespace column *might* be empty
			[ "${FIELDS[0]}" != '*' ] && continue
			# From here forward we know that CONTEXT_LINE is the current context
			PROMPT_K8S_CONTEXT="${FIELDS[1]}"
			PROMPT_K8S_NAMESPACE="${FIELDS[4]}"
			# We don't care about ofther lines, so stop the loop
			break
		done
	fi
}
