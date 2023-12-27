#!/bin/bash

set -euxo pipefail

#
# Quick and dirty quickstart script to fire up a local ocis instance.
# Klaas Freitag <kfreitag@owncloud.com>
#

# Call this script directly from github:
# wget -O - https://raw.githubusercontent.com/dragotin/thisnthat/master/scripts/quickocis.sh | /bin/bash

# This function is borrowed from openSUSEs /usr/bin/old, thanks.
function backup_file () {
    local DATESTRING=`date +"%Y%m%d"`

    i=${1%%/}
    if [ -e "$i" ] ; then
        local NEWNAME=$i-$DATESTRING
        local NUMBER=0
        while [ -e "$NEWNAME" ] ; do
            NEWNAME=$i-$DATESTRING-$NUMBER
            let NUMBER=$NUMBER+1
        done
        echo moving "$i" to "$NEWNAME"
        if [ "${i:0:1}" = "-" ] ; then
            i="./$i"
            NEWNAME="./$NEWNAME"
        fi
        mv "$i" "$NEWNAME"
    fi
}

dlrepo="stable"
dlversion="4.0.5"
dlurl="https://download.owncloud.com/ocis/ocis/${dlrepo}/${dlversion}"
dlarch="amd64"

sandbox="ocis-sandbox-${dlversion}"

# Create a sandbox
[ -d "./${sandbox}" ] && backup_file ${sandbox}
mkdir ${sandbox} && cd ${sandbox}

os="linux"

if [[ $OSTYPE == 'darwin'* ]]; then
  os="darwin"
fi

if [[ $(uname -m) == 'aarch64'* ]]; then
  dlarch="arm64"
fi

dlfile="ocis-${dlversion}-${os}-${dlarch}"

# download
echo "Downloading ${dlurl}/${dlfile}"

wget -q --show-progress "${dlurl}/${dlfile}"
chmod 755 ${dlfile}

mkdir data config

export OCIS_CONFIG_DIR="$(pwd)/config"
export OCIS_BASE_DATA_PATH="$(pwd)/data"

host="$(hostname)"
echo "Using hostname $host"

./${dlfile} init --insecure yes --ap admin

echo '#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "${0}")")"
cd "${SCRIPT_DIR}"' > runocis.sh

echo "export OCIS_CONFIG_DIR=${OCIS_CONFIG_DIR}
export OCIS_BASE_DATA_PATH=${OCIS_BASE_DATA_PATH}

export OCIS_INSECURE=true
export OCIS_URL=https://${host}:9200
export IDM_CREATE_DEMO_USERS=true
export PROXY_ENABLE_BASIC_AUTH=true
export OCIS_LOG_LEVEL=warning

./"${dlfile}" server
" >> runocis.sh

chmod 755 runocis.sh

echo "Connect to ownCloud Infinte Scale at https://${host}:9200"
echo ""
echo "*** This is a fragile test setup, not suitable for production! ***"
echo "    If you stop this script now, you can run your test ocis again"
echo "    using the script ${sandbox}/runocis.sh"
echo ""
echo "    Find documentation at https://doc.owncloud.com/ocis/next/"

./runocis.sh

