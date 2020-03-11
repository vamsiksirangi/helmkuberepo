FROM alpine:latest AS k8scomponents

ARG k8sVERSION=v1.15.7
ARG HELMVERSION=v2.16.0
ARG TAR_FILE="helm-${HELMVERSION}-linux-amd64.tar.gz"

RUN mkdir -p /tmp/apps

WORKDIR /tmp/apps

RUN apk add --update --no-cache curl && \
    curl -L https://get.helm.sh/${TAR_FILE} |tar xvz   
	
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$k8sVERSION/bin/linux/amd64/kubectl
	
FROM microsoft/azure-cli

ARG JENKINS_USER="10011"
ARG JENKINS_USERNAME="cicduser"

RUN addgroup -S $JENKINS_USER && \
    adduser --disabled-password -S $JENKINS_USERNAME -G $JENKINS_USER

RUN mkdir -p /tmp/apps 

WORKDIR /tmp/apps

COPY --from=k8scomponents /tmp/apps .

RUN mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64
	
RUN chmod +x /tmp/apps/kubectl && \
    mv /tmp/apps/kubectl /usr/local/bin/kubectl
	
#ENV http_proxy=http://nonprod.inetgw.aa.com:9093/ \
#  https_proxy=http://nonprod.inetgw.aa.com:9093/ \
#ENV no_proxy="artifacts.aa.com, nexusread.aa.com"

USER $JENKINS_USERNAME



 
