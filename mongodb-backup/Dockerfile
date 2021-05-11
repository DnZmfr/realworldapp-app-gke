FROM mongo:4

RUN apt update
RUN apt -y install gsutil

WORKDIR /scripts

COPY backup.sh .
RUN chmod 700 backup.sh

ENV MONGODB_URI ""
ENV GCS_BUCKET ""

CMD ["/scripts/backup.sh"]
