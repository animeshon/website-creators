#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

cat > ${AUTO_TFVARS_FILE} <<EOF
image_tag = ${IMAGE_TAG}
EOF

exit 0