FROM mongo:4

RUN apt update
RUN apt -y install wget
RUN wget https://storage.googleapis.com/pub/gsutil.tar.gz
RUN tar xfz gsutil.tar.gz -C $HOME

WORKDIR /scripts

COPY backup.sh .
RUN chmod 700 backup.sh

ENV MONGODB_URI ""
ENV GCS_BUCKET ""

CMD ["/scripts/backup.sh"]
