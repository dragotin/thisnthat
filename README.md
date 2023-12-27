# This and That

Here is some stuff that fell on my feet and that does not really fit elsewhere.

## scripts/quickocis.sh

Litte bash script to download, configure and start a test version of ownCloud 
Infinite Scale in the current directory in a new sandbox folder.

The script can be used like this:

```bash
curl -L https://owncloud.com/runocis.sh | /bin/bash
```

(the -L option for curl is needed to follow http redirects)

The script creates the sandbox folder with config and data directories and another
script that can be used to start the Infinte Scale instance later.

The installation does not have a valid certificate. That is why your browser will
complain.

Note that this is for testing purposes only. Do not use it in production.
