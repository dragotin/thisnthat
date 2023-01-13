#!/bin/bash

#
# Quick and dirty quickstart script to fire up a local ocis instance.
# Klaas Freitag <kfreitag@owncloud.com>
#

dlversion="2.0.0"
dlurl="https://download.owncloud.com/ocis/ocis/stable/${dlversion}/"
dlarch="amd64"

sandbox="ocis-sandbox"

# Create a sandbox
[ -d "./${sandbox}" ] && old "${sandbox}"
mkdir ${sandbox} && cd ${sandbox}

os="linux"

if [[ $OSTYPE == 'darwin'* ]]; then
  os="darwin"
fi

dlfile="ocis-${dlversion}-${os}-${dlarch}"

# download
echo "Downloading ${dlurl}${dlfile}"

wget -q --show-progress "${dlurl}${dlfile}"
chmod 755 ${dlfile}

mkdir data config

export OCIS_CONFIG_DIR=`pwd`/config
export OCIS_BASE_DATA_PATH=`pwd`/data

./${dlfile} init --insecure yes --ap admin

echo "#!/bin/bash
export OCIS_CONFIG_DIR=`pwd`/config
export OCIS_BASE_DATA_PATH=`pwd`/data

export OCIS_INSECURE=true
export OCIS_URL=https://localhost:9200
export IDM_CREATE_DEMO_USERS=true
export PROXY_ENABLE_BASIC_AUTH=true
export OCIS_LOG_LEVEL=warning

./${dlfile} server
" > runocis.sh

chmod 755 runocis.sh

echo "Connect to ownCloud Infinte Scale at https://localhost:9200"
echo ""
echo "*** This is a fragile test setup, not suitable for production! ***"

./runocis.sh

