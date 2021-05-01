FROM node:12.14.1
COPY . /app
WORKDIR /app
RUN npm install
RUN npm run deploy

EXPOSE 3001

ENV BACKEND_URL=http://localhost:3001
ENV MONGODB_STORE_CONNECTION_STRING=mongodb://test:test@mongodb.default.svc.cluster.local:27017/test
ENV JWT_SECRET=dd8f07db7a90e1682b72fccab3bb780f9942f161e746aaf879b3259e185e530343a0a37ccad5b4a447b80b0ecdbe97b14fd3e36bd4f5d57071086463507399a7

ENTRYPOINT ["npm", "run", "start"]
