#!/usr/bin/env bash
set -e
set -x

export BACKEND_URL=http://realworld-backend.default.svc.cluster.local:3001
export FRONTEND_URL=http://realworld-frontend.default.svc.cluster.local:3002
export JWT_SECRET=490c05b9648b59f4608750876ce56fac5644f53ce6edb3d0fbaa3d6f1670744cd1bf2c7c27d37139bfb865d9440aa3babfc6fa422705dfa89477fdf85b55d958

npm run build
