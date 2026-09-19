#!/bin/bash
# Time widget matching zjstatus-widgets: green clock icon + HH:MM.
set -eo pipefail
printf '#[fg=#a6e3a1,bg=default]󰥔 %s ' "$(date '+%H:%M')"
