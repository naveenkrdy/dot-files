#!/bin/sh
# Publishes the current Claude model to Herdr as a `$model` sidebar token.
#
# Sits BESIDE herdr-agent-state.sh rather than editing it - that file is managed
# by Herdr and is overwritten whenever the integration is reinstalled or updated.
#
# Herdr has no built-in model token, but `pane.report_metadata` accepts a `tokens`
# map that surfaces as `$name` tokens in ui.sidebar.agents.rows.

set -eu

hook_input_file="$(mktemp "${TMPDIR:-/tmp}/herdr-model.XXXXXX")" || exit 0
trap 'rm -f "$hook_input_file"' EXIT HUP INT TERM
cat >"$hook_input_file" 2>/dev/null || true

# Only meaningful inside a Herdr pane.
[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HERDR_HOOK_INPUT_FILE="$hook_input_file" python3 - <<'PY'
import json
import os
import random
import socket
import time

pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")
if not pane_id or not socket_path:
    raise SystemExit(0)

try:
    with open(os.environ["HERDR_HOOK_INPUT_FILE"], encoding="utf-8") as fh:
        hook_input = json.loads(fh.read() or "{}")
except Exception:
    raise SystemExit(0)

# A subagent's model is not the session's model - ignore those events entirely.
if hook_input.get("agent_id"):
    raise SystemExit(0)

transcript = hook_input.get("transcript_path")
if not isinstance(transcript, str) or not os.path.isfile(transcript):
    raise SystemExit(0)

PRETTY = {"opus": "Opus", "sonnet": "Sonnet", "haiku": "Haiku", "fable": "Fable"}


def pretty(model_id):
    """claude-opus-5 -> Opus 5 ; claude-haiku-4-5-20251001 -> Haiku 4.5"""
    parts = [p for p in model_id.split("-") if p and p != "claude"]
    if not parts:
        return model_id
    family = PRETTY.get(parts[0])
    if family is None:
        return model_id
    nums = []
    for p in parts[1:]:
        if not p.isdigit():
            break
        if len(p) >= 8:  # trailing date stamp
            break
        nums.append(p)
    return f"{family} {'.'.join(nums)}" if nums else family


# Walk backwards: the newest main-thread assistant line carries the live model,
# so a mid-session /model switch is picked up on the next turn.
model = None
try:
    with open(transcript, "r", encoding="utf-8", errors="replace") as fh:
        lines = fh.readlines()
    for line in reversed(lines[-400:]):
        try:
            d = json.loads(line)
        except Exception:
            continue
        if d.get("type") != "assistant" or d.get("agent_id") or d.get("isSidechain"):
            continue
        m = (d.get("message") or {}).get("model")
        if isinstance(m, str) and m and m != "<synthetic>":
            model = m
            break
except OSError:
    raise SystemExit(0)

if not model:
    raise SystemExit(0)

request = {
    "id": f"herdr:model:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}",
    "method": "pane.report_metadata",
    "params": {
        "pane_id": pane_id,
        "source": "herdr:claude-model",
        "seq": time.time_ns(),
        "tokens": {"model": pretty(model)},
    },
}

try:
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(0.5)
    client.connect(socket_path)
    client.sendall((json.dumps(request) + "\n").encode())
    try:
        client.recv(4096)
    except Exception:
        pass
    client.close()
except Exception:
    pass
PY
