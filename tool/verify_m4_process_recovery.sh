#!/usr/bin/env bash
# Runs only the staged OS-termination check, against an emulator/simulator.
set -euo pipefail

M4_DEVICE="${1:?Pass an Android emulator ID or iOS simulator UDID}"
M4_OUTPUT="${2:-/private/tmp/aedify-m4-recovery-${M4_DEVICE}}"
M4_PACKAGE="com.example.aedify"
M4_ADB="${ANDROID_HOME:-${HOME}/Library/Android/sdk}/platform-tools/adb"
mkdir -p "$M4_OUTPUT"

m4_ready() {
  if [[ "$M4_DEVICE" == emulator-* ]]; then
    "$M4_ADB" -s "$M4_DEVICE" shell run-as "$M4_PACKAGE" ls \
      files/aedify_m4_process_ready >/dev/null 2>&1
  else
    M4_CONTAINER="$(xcrun simctl get_app_container "$M4_DEVICE" "$M4_PACKAGE" data 2>/dev/null)" || return 1
    [[ -f "$M4_CONTAINER/Library/Application Support/aedify_m4_process_ready" ]]
  fi
}

# Remove only this harness's synthetic readiness marker, if previously installed.
if [[ "$M4_DEVICE" == emulator-* ]]; then
  "$M4_ADB" -s "$M4_DEVICE" shell run-as "$M4_PACKAGE" rm -f files/aedify_m4_process_ready >/dev/null 2>&1 || true
else
  M4_CONTAINER="$(xcrun simctl get_app_container "$M4_DEVICE" "$M4_PACKAGE" data 2>/dev/null)" || M4_CONTAINER=""
  if [[ -n "$M4_CONTAINER" ]]; then
    rm -f "$M4_CONTAINER/Library/Application Support/aedify_m4_process_ready"
  fi
fi

flutter test integration_test/m4_process_recovery_test.dart -d "$M4_DEVICE" \
  --no-uninstall --dart-define=M4_RECOVERY_PHASE=seed --reporter expanded \
  >"$M4_OUTPUT/seed.txt" 2>&1 &
M4_SEED_PID=$!
trap 'kill "$M4_SEED_PID" 2>/dev/null || true' EXIT

M4_READY=false
for M4_ATTEMPT in $(seq 1 240); do
  if m4_ready; then M4_READY=true; break; fi
  if ! kill -0 "$M4_SEED_PID" 2>/dev/null; then
    cat "$M4_OUTPUT/seed.txt"
    exit 1
  fi
  sleep 2
done
if [[ "$M4_READY" != true ]]; then
  printf '%s\n' 'Timed out before committed test progress was ready.'
  exit 1
fi

if [[ "$M4_DEVICE" == emulator-* ]]; then
  "$M4_ADB" -s "$M4_DEVICE" shell am force-stop "$M4_PACKAGE"
else
  xcrun simctl terminate "$M4_DEVICE" "$M4_PACKAGE"
fi
# The seed runner losing its VM connection is expected after this deliberate kill.
wait "$M4_SEED_PID" || true
trap - EXIT
printf '%s\n' 'Committed seed confirmed; OS process terminated.' >"$M4_OUTPUT/termination.txt"

flutter test integration_test/m4_process_recovery_test.dart -d "$M4_DEVICE" \
  --no-uninstall --dart-define=M4_RECOVERY_PHASE=recover --reporter expanded \
  >"$M4_OUTPUT/recover.txt" 2>&1
cat "$M4_OUTPUT/termination.txt" "$M4_OUTPUT/recover.txt"
