# components/kubernetes.star
#
# platform: all
#
# Kubernetes toolchain — OPT-IN, deliberately not listed in init.star's
# `after`. Nothing here is installed by default.
#
# This machine works with containers via OrbStack but does not run Kubernetes
# yet; the grouping exists so the tooling is one line away when that changes.
# Enable it per machine from local.star:
#
#     component("@dotmeow//components/kubernetes")
#
# Do not "clean up" this component for being unreferenced — being unreferenced
# is the point.

after = [
    "@stdlib//components/kubectl",
    "@stdlib//components/kubectx",
    "@stdlib//components/stern",
    "@stdlib//components/helm",
    "@stdlib//components/k9s",
]
