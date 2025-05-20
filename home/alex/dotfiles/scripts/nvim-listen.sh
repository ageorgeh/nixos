#!/usr/bin/env bash
rm "/tmp/nvim-$(basename "$PWD").sock"
exec nvim --listen "/tmp/nvim-$(basename "$PWD").sock" "$@"

