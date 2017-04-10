# Brooklyn Hyperledger

This repository contains [Apache Brooklyn](https://brooklyn.apache.org/) blueprints for a
[Hyperledger Fabric](https://github.com/hyperledger/fabric) v0.6.1 cluster deployment using the official Docker images.

## Deployment Instructions

### Step 1: Install Cloudsoft AMP

**Note**: If you select the Vagrant installation, replace the following line in the guide below:
```
git clone https://github.com/cloudsoft/amp-vagrant.git
```

with:
```
git clone -b hyperledger-fabric https://github.com/cloudsoft/amp-vagrant.git
```

Use [this guide](http://docs.cloudsoft.io/tutorials/tutorial-get-amp-running.html) to install AMP.

For the simplest path to a Hyperledger Fabric deployment, select the Vagrant installation option and create
[5 BYON nodes](http://docs.cloudsoft.io/tutorials/tutorial-get-amp-running.html#starting-byon-nodes).

### Step 1.5: Add Hyperledger Fabric to the AMP Catalog

**Note**: You can skip this step if you selected the Vagrant installation option.

* Download the latest release JAR from this repository and place it in the
`deploy` folder inside the AMP install directory.
* Browse to the AMP user interface (address listed in the installation guide)
* Click the button with nine small squares on the top right
* Click "Blueprint importer"
* Copy and paste the contents of [`hyperledger.bom`](hyperledger.bom) into the editor
* Click "Import" on the bottom right

### Step 2: Create a Deployment Location

**Note**: You can skip this step if you selected the Vagrant installation option and started the 5 BYON nodes,
in which case you will already have a location named `byon-cluster` configured and ready to be used.
If you would like to deploy to a different location, proceed with this step.

Use [this guide](http://docs.cloudsoft.io/locations/first-location/index.html) to create a deployment location.

### Step 3a: Deploy a Hyperledger Fabric Single-cluster

* Browse to the AMP user interface (address listed in the installation guide)
* Scroll through the "Quick launch" tile and click "Hyperledger Fabric Cluster"
* Optionally provide a name
* Provide the location that you created (or `byon-cluster` by default, if using Vagrant)
* Increase the number of peers if desired
* Click the "Deploy" button

**Note**: If you plan on deploying to Vagrant VMs running locally, the maximum supported value of
`hyperledger.peers.per.location` is 4. However, the size of the cluster can be increased if you add more VMs
to [`servers.yaml`](https://github.com/cloudsoft/amp-vagrant/blob/hyperledger-fabric/servers.yaml) in your `amp-vagrant` repository.

### Step 3b: Deploy a Hyperledger Fabric Multi-cluster

This deployment is capable of creating multiple clusters of validating peer nodes across
multiple locations; all of the nodes are part of the same Hyperledger Fabric.

* Browse to the classic view of the AMP user interface (address listed in the installation guide) by appending `/amp-classic-ui/`
* Click the "+ add application" button
* Click the "YAML Composer" button
* Copy and paste the contents of the [multi-cluster blueprint](examples/hyperledger-multi-cluster.yaml) and add the names of your configured location(s)

**Note**: This deployment requires at least 5 locations listed (can contain duplicates).

## Demo Application Instructions

Once your cluster has successfully deployed, perform the following steps to deploy the asset management demonstration app.  This app repeatedly assigns an asset "Picasso" from one owner to another.  For more information about this app as well as its source code, see the [Fabric repository](https://github.com/hyperledger/fabric/tree/v0.6.1-preview/examples/chaincode/go/asset_management).

### Run Using AMP Effector

* Browse to the AMP user interface (address listed in the installation guide)
* Click the "App Inspector" tile
* Hover over the down arrow next to your Hyperledger Fabric cluster and press the listed key combination to "expand all children"
* Click "CLI Node"
* Click the "Effectors" tab
* Click "Invoke" next to "Run Demo Application"

### Run Manually

#### Step 1: SSH into CLI Node

* Browse to the AMP user interface (address listed in the installation guide)
* Click the "App Inspector" tile
* Hover over the down arrow next to your Hyperledger Fabric cluster and press the listed key combination to "expand all children"
* Click "Expand All"
* Click "CLI Node"
* Click the "Sensors" tab
* Copy the `host.sshAddress` value
* Open up your terminal and run command: `ssh <ssh-address-here>`

**Note 1**: You may need to supply an SSH key or a username / password depending on your
deployment location's configuration.

**Note 2**: If `host.sshAddress` ends with a port (e.g. `:22`), remove the colon and the port from the SSH command.

**Note 3**: If you deployed to local Vagrant VMs, you can SSH into any of these VMs by running this command instead:
`vagrant ssh byon<number here>`. The name of the VM is based on the last digit of the IP address.
For example, if the CLI node's IP is `10.10.10.102` then the command would be: `vagrant ssh byon2`.

#### Step 2: Build and Run the Asset Management App

From the same terminal window from the previous step, execute the following commands:
```
sudo docker exec -it cli bash
cd $APP_HOME
go build
./app
```

This enters the CLI container, builds the app, and executes the app. When the app runs, the output should clearly indicate the transfer of ownership of "Picasso" ultimately ending with "Dave" as the owner.

## Appendix

### AWS EC2 instances

If deploying to AWS You should use an up-to-date CentOS AMI. The "CentOS 7 (x86_64) with Updates HVM"
images ([link](https://aws.amazon.com/marketplace/ordering?productId=b7ee8a69-ee97-4a49-9e68-afaee216db2e))
are a good choice. The following is a sample catalogue blueprint for the `us-east-1` version of this AMI:

    brooklyn.catalog:
      id:       aws-virginia-centos7
      name:     AWS Virginia CentOS 7
      itemType: location
      item:
        type: jclouds:aws-ec2
        brooklyn.config:
          identity:   <YOUR IDENTITY>
          credential: <YOUR CREDENTIAL>
          region:     us-east-1
          imageId:    us-east-1/ami-6d1c2007
          minRam:     2000
          loginUser:  centos
          installDevUrandom: true
          allocatePTY: true
