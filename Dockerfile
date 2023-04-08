ARG KUBECTL_VERSION=1.26.0 # override by github actions
ARG ARGO_ROLLOUTS_VERSION=1.3.2
ARG VEGETA_VERSION=12.8.4
ARG APK_PACKAGES="curl jq"

FROM alpine:3.17.3 AS workspace
COPY util.sh .

FROM workspace AS kubectl
ARG KUBECTL_VERSION
RUN source util.sh && wget -q "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/$(getos)/$(getarch)/kubectl"
RUN chmod +x kubectl

FROM workspace AS argo-rollouts
ARG ARGO_ROLLOUTS_VERSION
RUN source util.sh && wget -q -O kubectl-argo-rollouts "https://github.com/argoproj/argo-rollouts/releases/download/v${ARGO_ROLLOUTS_VERSION}/kubectl-argo-rollouts-$(getos)-$(getarch)"
RUN chmod +x kubectl-argo-rollouts

FROM workspace AS vegeta
ARG VEGETA_VERSION
RUN source util.sh && wget -q "https://github.com/tsenart/vegeta/releases/download/v${VEGETA_VERSION}/vegeta_${VEGETA_VERSION}_$(getos)_$(getarch2).tar.gz" -O - | tar -xz -C / -f - vegeta
RUN chmod +x vegeta

# output
FROM alpine:3.17.3

ARG APK_PACKAGES
RUN apk add ${APK_PACKAGES}

COPY --from=vegeta /vegeta /usr/local/bin/
COPY --from=argo-rollouts /kubectl-argo-rollouts /usr/local/bin/
COPY --from=kubectl /kubectl /usr/local/bin/

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sh"]
