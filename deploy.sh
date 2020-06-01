#!/usr/bin/env bash
### Paste in here latest File Revisions
REV=https://raw.githubusercontent.com/b23prodtm/vagrant-shell-scripts/b23prodtm-patch/vendor/cni/balena_deploy.sh
#REV=https://raw.githubusercontent.com/b23prodtm/vagrant-shell-scripts/36a8e73ed1c1a8eca501ddbbfdf73a5238a45ef4/vendor/cni/balena_deploy.sh
sudo curl -SL -o /usr/local/bin/balena_deploy $REV
sudo chmod 0755 /usr/local/bin/balena_deploy
rm -f mysqldb/conf.d/custom.cnf
source balena_deploy ${BASH_SOURCE[0]} "$@"
