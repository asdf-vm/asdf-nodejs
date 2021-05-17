#! /usr/bin/env bash

userbin_location="$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/wrappers/bin"

printf '%s\n' "$userbin_location"
