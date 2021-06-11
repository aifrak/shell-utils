#!/usr/bin/env bash

function dockerfile:help {
  cat <<EOF

  Dockerfile commands:
    dockerfile:format          Format all Dockerfiles
    dockerfile:lint            Lint all Dockerfiles
EOF
}

function dockerfile:lint {
  hadolint ./Dockerfile*
}

function dockerfile:format {
  shfmt -w ./Dockerfile*
}
