FROM node:10.24.0
COPY . /app
WORKDIR /app
RUN npm install
RUN /bin/bash src/run.sh

EXPOSE 3002

ENTRYPOINT ["npm", "run", "start"]
