#!/usr/bin/env bash
set -e
set -x

export BACKEND_URL=http://realworld-backend.default.svc.cluster.local:3001
export FRONTEND_URL=http://realworld-frontend.default.svc.cluster.local:3002

npm run build
