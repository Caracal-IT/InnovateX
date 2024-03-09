FROM alpine:latest

# Install OpenSSL and OpenJDK
RUN apk update && \
    apk add --no-cache openssl openjdk21

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/default-jvm

# Optionally, set the PATH environment variable to include Java binaries
ENV PATH=$JAVA_HOME/bin:$PATH