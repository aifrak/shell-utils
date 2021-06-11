#!/usr/bin/env bash

function shell:help {
  cat <<EOF

  Shell commands:
    shell:format               Lint Shell scripts (included Shellspec files)
    shell:lint                 Lint Shell scripts
    shell:test                 Run Shell unit tests
EOF
}

function shell:lint {
  local sh_files=(
    ./run
    ./scripts/**/*.sh
    ./src/*.sh
    ./spec/*.sh
    ./spec/**/*.sh
  )

  # Lint all shell script
  shellcheck "${sh_files[@]}" -x

  # Lint all shellspec files
  shellspec --syntax-check
}

function shell:test {
  shellspec --shell bash --format progress --jobs 10
}

function shell:format {
  shfmt -w ./**/*.sh
}
