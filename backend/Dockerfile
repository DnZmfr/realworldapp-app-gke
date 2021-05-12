FROM node:12.14.1
COPY . /app
WORKDIR /app
RUN npm install
RUN npm run deploy

EXPOSE 3001

ENV BACKEND_URL=http://realworld-backend.default.svc.cluster.local:3001
ENV MONGODB_STORE_CONNECTION_STRING=mongodb://user:password@mongodb.default.svc.cluster.local:27017/test
ENV JWT_SECRET=490c05b9648b59f4608750876ce56fac5644f53ce6edb3d0fbaa3d6f1670744cd1bf2c7c27d37139bfb865d9440aa3babfc6fa422705dfa89477fdf85b55d958

ENTRYPOINT ["npm", "run", "start"]
