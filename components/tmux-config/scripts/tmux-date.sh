#!/bin/bash
# Date widget matching zjstatus-widgets: blue calendar icon + short date.
set -eo pipefail
printf '#[fg=#b4befe,bg=#1e1e2e]󰸗 %s ' "$(date '+%a %d %b')"
