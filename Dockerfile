ARG KUBECTL_VERSION=1.24.3
ARG ALPINE_VERSION=3.16.1
ARG ARGO_ROLLOUTS_VERSION=1.2.1
ARG APK_PACKAGES="curl jq"

FROM alpine:${ALPINE_VERSION} AS workspace
COPY util.sh .

FROM workspace AS kubectl
ARG KUBECTL_VERSION
RUN source util.sh && echo wget -q "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/$(getos)/$(getarch)/kubectl" 1>&2 && return 1
RUN source util.sh && wget -q "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/$(getos)/$(getarch)/kubectl"
RUN chmod +x kubectl

FROM workspace AS argo-rollouts
ARG ARGO_ROLLOUTS_VERSION
RUN source util.sh && wget -q -O kubectl-argo-rollouts "https://github.com/argoproj/argo-rollouts/releases/download/v${ARGO_ROLLOUTS_VERSION}/kubectl-argo-rollouts-$(getos)-$(getarch)"
RUN chmod +x kubectl-argo-rollouts

# output
FROM alpine:${ALPINE_VERSION}

ARG APK_PACKAGES
RUN apk add ${APK_PACKAGES}

COPY --from=argo-rollouts /kubectl-argo-rollouts /usr/local/bin/
COPY --from=kubectl /kubectl /usr/local/bin/

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sh"]
