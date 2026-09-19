#!/bin/bash
# Date widget matching zjstatus-widgets: blue calendar icon + short date.
set -eo pipefail
printf '#[fg=#b4befe,bg=default]󰸗 %s ' "$(date '+%a %d %b')"
