#!/bin/bash
# Time widget matching zjstatus-widgets: green clock icon + HH:MM.
set -eo pipefail
printf '#[fg=#a6e3a1,bg=#1e1e2e]󰥔 %s  ' "$(date '+%H:%M')"
