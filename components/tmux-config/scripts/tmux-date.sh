#!/bin/bash
# Date widget matching zjstatus-widgets: blue calendar icon + short date.
set -eo pipefail
printf '#[fg=#89b4fa,bg=#1e1e2e]󰸗 %s  ' "$(date '+%a %d %b')"
