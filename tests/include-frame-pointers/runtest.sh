#!/bin/sh

# Not using set -e on purpose as we manually validate the exit codes to print
# useful messages.
set -u

passed=0
failed=0

rpmeval() {
  # Note: --eval needs to always be *last* here
  rpm "$@" --eval='%optflags'
}

validate() {
  ret=$?
  if [ $ret -eq 0 ]; then
    echo "PASS: $*"
    passed=$((passed+1))
  else
    echo "FAIL: $*"
    failed=$((failed+1))
  fi
}

for arch in aarch64 armv7hl i386 i486 i585 i686 athlon x86_64 ppc64le s390x riscv64; do
  case "$arch" in
    x86_64|aarch64)
      flags='-fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'
      ;;
    s390x)
      flags='-fno-omit-frame-pointer -mbackchain'
      ;;
    *)
      flags='-fno-omit-frame-pointer'
      ;;
  esac

  rpmeval --target="${arch}-linux" --define='%_include_frame_pointers 1' | grep -q -- "$flags"
  validate "[${arch}] Test that the flags are included if the macro is defined"

  rpmeval --target="${arch}-linux" --undefine='_include_frame_pointers' | grep -qv -- "$flags"
  validate "[${arch}] Test that the flags are _not_ included if the macro is undefined"

  rpmeval --target="${arch}-linux" | grep -q -- "$flags"
  validate "[${arch}] Test that the flags are included by default"
done

echo
echo "${passed} passed, ${failed} failed"

exit "$failed"
