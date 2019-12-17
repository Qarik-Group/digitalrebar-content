# Stark & Wayne Digital Rebar Content

This repository contains a collection of Content Packs maintained by [Stark & Wayne](https://starkandwayne.com/)
for use with [Digital Rebar Provision (DRP)](http://rebar.digital).

To install the Content Packs in this repository, you will first need to install DRP.
Below a short summary of the steps need to install DRP on docker for use in a
home lab environment are documented. If the steps below don't work for you,
please referrer to the [official documentation](https://provision.readthedocs.io/en/latest/doc/install.html).

## Install DRP on Docker
The one-liner below will run DRP in a single docker container (named `drp`)
with a single volume (named `drp-data`) for storing its state.
```
curl -fsSL get.rebar.digital/stable | bash -s -- --container install
```
Next steps can be performed through the UI via the RackN portal or by using the `drpcli`.

## Bootstrap using the web UI
To find your UI endpoint use the following snippet:
```
IP=$(docker exec -it drp ip addr show eth0 | grep -Po 'inet \K[\d.]+')
echo -e "- browse to https://${IP}:8092
- accept the self signed certificate
- login with user: rocketskates and password: r0cketsk8ts
- follow the onscreen instruction in the System Bootstrap Wizard"
```

## Bootstrap using the drpcli
Install the cli:
```
IP=$(docker exec -it drp ip addr show eth0 | grep -Po 'inet \K[\d.]+')
curl -s -o /usr/local/bin/drpcli http://${IP}:8091/files/drpcli.amd64.linux
chmod +x /usr/local/bin/drpcli
```

Change the default password:
```
export RS_ENDPOINT=https://${IP}:8092
export RS_KEY="rocketskates:r0cketsk8ts"

PASSWORD=$(openssl rand -base64 14) # please store this password in your password manager
drpcli users password rocketskates ${PASSWORD}
export RS_KEY="rocketskates:${PASSWORD}"
```

Install some basic Content Packs:
```
drpcli catalog item install task-library
drpcli catalog item install drp-community-content
```

Upload iso for discovery BootEnv:
```
drpcli bootenvs uploadiso discovery
```

Create a subnet:
```
drpcli interfaces show eth0 \
  | jq '.ActiveAddress | {Name: "eth0", Proxy: true, Strategy: "MAC", Enabled: true, subnet: .}' \
  | drpcli subnets create -
```

Configure default discovery preferences:
```
drpcli prefs set defaultBootEnv sledgehammer
drpcli prefs set defaultWorkflow discover-base
drpcli prefs set unknownBootEnv discovery
```

Add ssh key to global profile:
```
jq --arg user $(whoami) \
   --arg key "$(curl -s https://github.com/$(whoami).keys)" \
   -n '{"access-keys": {"\($user)": $key}}' \
   | drpcli profiles params global -
```

At this point you should be all set to PXE boot your first machine.

## Further steps
Please follow the instructions in the README's located in the sub directories of this repo.
