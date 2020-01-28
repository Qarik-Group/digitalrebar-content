# MoltenCore Digital Rebar Content Pack
This content pack allows you to install and configure a [MoltenCore](https://github.com/starkandwayne/molten-core) Cluster

## Install contents
Install Prerequisites:
```
drpcli catalog item install task-library
drpcli catalog item install drp-community-content
drpcli catalog item install coreos
```

Download coreos bootenv isos:
```
drpcli bootenvs list | jq -r 'map(select(.Name | contains("coreos"))) | .[].Name' \
    | xargs -L1 drpcli bootenvs uploadiso
```

Install MoltenCore Content Pack:
```
curl -s https://raw.githubusercontent.com/starkandwayne/digitalrebar-content/master/molten-core/molten-core.yaml \
    | drpcli contents create -
```

## Configure cluster
Create a profile to store the cluster information
```
PROFILE_NAME=mc-demo
drpcli profiles create ${PROFILE_NAME}
jq --arg name ${PROFILE_NAME} -n '{"molten-core/cluster-profile": $name, "cluster/profile": $name, "cluster/machines": []}' \
   | drpcli profiles params ${PROFILE_NAME} -
```

Now assign the profile we just created to all machines which will be part of you cluster.
For now we assume all known machines in DRP will be used:
```
drpcli machines list \
    | jq -r '.[].Uuid' \
    | xargs -L1 -I{} drpcli machines addprofile {} ${PROFILE_NAME}
```

## Deploy
```
drpcli machines list \
    | jq -r '.[].Uuid' \
    | xargs -L1 -I{} drpcli machines workflow {} install-molten-core
```

## Use MolteCore
All management in a MoltenCore Cluster is perform on the first node (node z0):
```
ssh core@$(drpcli machines list | jq -r 'map(select(.Params["molten-core/zone"] == "0"))[0].Address')
```

For further steps follow the docs in the MoltenCore repo:
- [Accessing BUCC](https://github.com/starkandwayne/molten-core#accessing-bucc)
- [Deploy CloudFoundry or Kubernetes](https://github.com/starkandwayne/molten-core/tree/master/examples)
