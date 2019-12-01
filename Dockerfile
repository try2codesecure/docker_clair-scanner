# Start from the latest golang base image
FROM golang:latest as builder

LABEL maintainer="try2codesecure <no@e.mail>"

# install dep
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# grab the latest clair-scanner source
WORKDIR /go/src
RUN git clone -b 'v12' --single-branch --depth 1 https://github.com/arminc/clair-scanner.git

# build from source
WORKDIR /go/src/clair-scanner/
RUN make ensure && make build

FROM docker:stable
RUN apk --no-cache --update add \
        jq \
        bash

WORKDIR /bin
# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go/src/clair-scanner /bin/
ADD ./bin /bin
ENTRYPOINT ["entrypoint.sh"]
