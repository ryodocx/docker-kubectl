#!/bin/sh -e

getos() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

getarch() {
  case $(uname -m) in
  aarch64)
    echo arm64
    ;;
  x86_64)
    echo amd64
    ;;
  *)
    echo unknown
    ;;
  esac
}

getarch2() {
  case $(uname -m) in
  aarch64)
    echo 386
    ;;
  x86_64)
    echo amd64
    ;;
  *)
    echo unknown
    ;;
  esac
}
