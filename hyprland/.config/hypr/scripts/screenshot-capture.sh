#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

case "$mode" in
    freeze)
        root="${2:-}"
        [[ -n "$root" ]] || die "missing cache dir"
        frames="$root/frames"
        rm -rf "$frames"
        dir="$frames/$(date +%s%N)"
        mkdir -p "$dir"
        python3 - "$dir" <<'PY'
import json, os, subprocess, sys

dest = sys.argv[1]
try:
    monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]))
    clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"]))
except Exception as exc:
    print(f"hyprctl failed: {exc}", file=sys.stderr)
    raise SystemExit(1)

screens = []
procs = []
for mon in monitors:
    name = str(mon.get("name") or "")
    if not name:
        continue
    safe = "".join(ch if ch.isalnum() or ch in "-._" else "_" for ch in name)
    path = os.path.join(dest, safe + ".png")
    proc = subprocess.Popen(["grim", "-o", name, path])
    procs.append((mon, name, path, proc))

failed = []
for mon, name, path, proc in procs:
    if proc.wait() != 0 or not os.path.isfile(path) or os.path.getsize(path) < 32:
        failed.append(name)

if failed:
    print("grim failed for " + ", ".join(failed), file=sys.stderr)
    raise SystemExit(1)

for mon, name, path, proc in procs:
    screens.append({
        "name": name,
        "x": int(mon.get("x") or 0),
        "y": int(mon.get("y") or 0),
        "width": int(mon.get("width") or 0),
        "height": int(mon.get("height") or 0),
        "path": path,
    })

if not screens:
    print("no monitors", file=sys.stderr)
    raise SystemExit(1)

visible = set()
for mon in monitors:
    ws = mon.get("activeWorkspace") or {}
    if "id" in ws:
        visible.add(ws["id"])

windows = []
for client in clients:
    ws = (client.get("workspace") or {}).get("id")
    if visible and ws not in visible:
        continue
    if client.get("hidden"):
        continue
    if "mapped" in client and not client.get("mapped"):
        continue
    at = client.get("at") or [0, 0]
    size = client.get("size") or [0, 0]
    if len(at) < 2 or len(size) < 2:
        continue
    w = int(size[0])
    h = int(size[1])
    if w < 2 or h < 2:
        continue
    windows.append({
        "x": int(at[0]),
        "y": int(at[1]),
        "w": w,
        "h": h,
        "floating": bool(client.get("floating")),
    })

json.dump({"screens": screens, "windows": windows}, sys.stdout)
PY
        ;;
    finish)
        src="${2:-}"
        x="${3:-}"
        y="${4:-}"
        w="${5:-}"
        h="${6:-}"
        action="${7:-}"
        shot_dir="${8:-}"
        out="${9:-}"
        [[ -f "$src" ]] || die "missing image"
        [[ -n "$out" && -n "$shot_dir" ]] || die "missing output"
        [[ "$action" == "copy" || "$action" == "save" || "$action" == "both" ]] || die "bad action"
        [[ "$x" =~ ^[0-9]+$ && "$y" =~ ^[0-9]+$ && "$w" =~ ^[0-9]+$ && "$h" =~ ^[0-9]+$ ]] || die "bad crop"
        [[ "$w" -ge 1 && "$h" -ge 1 ]] || die "empty crop"
        mkdir -p "$(dirname "$out")" "$shot_dir"
        ffmpeg -y -loglevel error -i "$src" -vf "crop=${w}:${h}:${x}:${y}" "$out"
        saved=""
        if [[ "$action" == "save" || "$action" == "both" ]]; then
            saved="$shot_dir/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
            cp -- "$out" "$saved"
        fi
        if [[ "$action" == "copy" || "$action" == "both" ]]; then
            wl-copy --type image/png < "$out"
        fi
        case "$action" in
            copy) notify-send Screenshot Copied || true ;;
            save) notify-send Screenshot "Saved $(basename "$saved")" || true ;;
            both) notify-send Screenshot "Copied and saved $(basename "$saved")" || true ;;
        esac
        ;;
    *)
        die "usage: screenshot-capture.sh freeze <cache> | finish <src> <x> <y> <w> <h> <copy|save|both> <dir> <out>"
        ;;
esac
