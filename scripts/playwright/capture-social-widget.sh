#!/usr/bin/env bash
set -euo pipefail

# Generate a transparent, element-cropped PNG for every tab from the
# preview-only /screenshots/ page.
site_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
output_dir="$site_dir/themes/socialspec/static/img"
port="${SOCIALSPEC_SCREENSHOT_PORT:-4174}"
scale="${SOCIALSPEC_SCREENSHOT_SCALE:-2}"
session="socialspec-screenshot"
pwcli="${CODEX_HOME:-$HOME/.codex}/skills/playwright/scripts/playwright_cli.sh"
tabs=(posts following about contact)

if ! command -v hyperctl >/dev/null; then
    echo "hyperctl is required to run the preview server." >&2
    exit 1
fi

if ! command -v npx >/dev/null; then
    echo "npx is required to run Playwright. Install Node.js and npm first." >&2
    exit 1
fi

if [[ ! -x "$pwcli" ]]; then
    echo "Playwright CLI helper not found at $pwcli" >&2
    exit 1
fi

if [[ ! "$scale" =~ ^[1-9][0-9]*(\.[0-9]+)?$ ]]; then
    echo "SOCIALSPEC_SCREENSHOT_SCALE must be a positive number." >&2
    exit 1
fi

mkdir -p "$output_dir"
server_log="$(mktemp -t socialspec-screenshot.XXXXXX)"

cleanup() {
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
    rm -f "$server_log"
}
trap cleanup EXIT

cd "$site_dir"
hyperctl website server --config site.yaml --drafts-dir drafts --id socialspec-screenshot --port "$port" >"$server_log" 2>&1 &
server_pid=$!

for _ in {1..100}; do
    if curl --fail --silent --output /dev/null "http://localhost:$port/screenshots/"; then
        break
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
        cat "$server_log" >&2
        exit 1
    fi
    sleep 0.1
done

if ! curl --fail --silent --output /dev/null "http://localhost:$port/screenshots/"; then
    echo "Timed out waiting for the screenshot preview server." >&2
    exit 1
fi

"$pwcli" --session "$session" open "http://localhost:$port/screenshots/"
"$pwcli" --session "$session" resize 820 900
"$pwcli" --session "$session" snapshot
"$pwcli" --session "$session" run-code "async page => { await page.evaluate(async () => { await customElements.whenDefined('social-widget'); await document.fonts.ready; }); }"
"$pwcli" --session "$session" run-code "async page => { await page.locator('social-widget').evaluate((element, scale) => { element.style.zoom = scale; }, '$scale'); }"

for tab in "${tabs[@]}"; do
    output_path="$output_dir/socialspec-$tab-cover.png"
    "$pwcli" --session "$session" run-code "async page => { await page.locator('social-widget').evaluate((element, tab) => { element.setAttribute('active-tab', tab); }, '$tab'); await page.locator('social-widget').screenshot({ path: '$output_path', omitBackground: true }); }"
    echo "Wrote $output_path"
done
