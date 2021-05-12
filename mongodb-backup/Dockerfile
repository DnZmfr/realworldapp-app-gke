FROM mongo:4

RUN apt-get update && apt-get install -y curl
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk

WORKDIR /scripts

COPY backup.sh .
RUN chmod 700 backup.sh

ENV MONGODB_URI ""
ENV GCS_BUCKET ""

CMD ["/scripts/backup.sh"]
