#!/usr/bin/env bash
exec nvim --listen "/tmp/nvim-$(basename "$PWD").sock" "$@"
