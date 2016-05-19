# brooklyn-hyperledger

This repository contains [Apache Brooklyn](https://brooklyn.apache.org/) blueprints for a
[Hyperledger Fabric](https://github.com/hyperledger/fabric) cluster deployment.

Currently the cluster uses the "noops" consensus plugin, but support for the "pbft" plugin
and member services are both on the short-term roadmap.

## Instructions

### Download, Configure, and Run Apache Brooklyn

First, ensure that you have Java installed.

Download the release tarball:
```
curl -O https://dist.apache.org/repos/dist/release/brooklyn/apache-brooklyn-0.9.0/apache-brooklyn-0.9.0-bin.tar.gz
```

Extract the tarball:
```
tar zxf apache-brooklyn-0.9.0-bin.tar.gz
```

Create a Brooklyn properties file with your desired login credentials:
```
mkdir -p ~/.brooklyn

echo "brooklyn.webconsole.security.users=<your-username>" >> ~/.brooklyn/brooklyn.properties

echo "brooklyn.webconsole.security.user.<your-username>.password=<your-password>" >> ~/.brooklyn/brooklyn.properties

chmod 600 ~/.brooklyn/brooklyn.properties
```

Launch Brooklyn (will run in the background):
```
cd apache-brooklyn-0.9.0-bin/bin/

nohup ./brooklyn launch > /dev/null 2>&1&
```

### Create a Deployment Location

* Go to [http://localhost:8081](http://localhost:8081) in your browser (the Brooklyn GUI)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "Location" under "Add to Catalog"
* Select the desired type of location and fill in the required fields

Be sure to make note of the "Location ID" that you choose during the final step.

For more information about Brooklyn locations, see [this guide](https://brooklyn.apache.org/v/latest/ops/locations/).

### Add Hyperledger to the Brooklyn Catalog

To accomplish this, we will use the Brooklyn Client CLI.
For more information about the Client CLI, see [this guide](https://brooklyn.apache.org/v/latest/ops/cli/index.html).

Navigate to the CLI folder from the terminal session above with one of the following
commands (depending on your OS):

Mac:
```
cd brooklyn-client-cli/darwin.amd64
```

Linux:
```
cd brooklyn-client-cli/linux.386
```

Windows:
```
cd brooklyn-client-cli/windows.386
```

Log into the Brooklyn server:
```
./br login http://localhost:8081 <your-username> <your-password>
```

Add [catalog.bom](catalog.bom) to the Brooklyn catalog:
```
./br add-catalog /path/to/catalog.bom
```

### Deploy a Hyperledger Cluster

Edit [hyperledger-cluster.yaml](hyperledger-cluster.yaml) and replace `<your-location>`
with the "Location ID" you created above.

Trigger a Hyperledger cluster deployment:
```
./br deploy /path/to/hyperledger-cluster.yaml
```

### Monitor & Use Your Cluster

To monitor the deployment status of your cluster, go back to the Brooklyn GUI in your
browser and click the "Applications" tab.

When the cluster has been successfully deployed, explore all of the nodes in the list
under "Applications" on the left.

To test out your cluster, SSH into one of the nodes (using the value of the
`host.sshAddress` sensor) and follow [these instructions](https://github.com/hyperledger/fabric/blob/master/docs/dev-setup/devnet-setup.md#deploy-invoke-and-query-a-chaincode)
from the HyperLedger Fabric documentation.