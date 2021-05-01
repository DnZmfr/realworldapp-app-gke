#!/usr/bin/env bash
set -e
set -x

export BACKEND_URL=http://localhost:3001
export FRONTENT_URL=http://localhost:3000

npm run build
