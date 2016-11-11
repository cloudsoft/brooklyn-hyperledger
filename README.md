# Brooklyn Hyperledger

This repository contains [Apache Brooklyn](https://brooklyn.apache.org/) blueprints for a
[Hyperledger Fabric](https://github.com/hyperledger/fabric) cluster deployment.


## Deployment Instructions

You can skip Step 1 if you have previously installed Cloudsoft AMP.


### Step 1: Get Cloudsoft AMP

First, register to ensure that you receive regular updates:
```
http://www.cloudsoft.io/get-started/
```
Then follow the online instructions (reproduced here for simplicity):
```
git clone https://github.com/cloudsoft/amp-vagrant
cd amp-vagrant
```

If you plan on deploying Hyperledger to external infrastructure, simply run:
```
vagrant up amp
```

If you plan on deploying Hyperledger to Vagrant VMs running locally, run these commands instead:
```
mv servers.yaml servers.yaml.bak
curl -O https://raw.githubusercontent.com/cloudsoft/brooklyn-hyperledger/master/servers.yaml
vagrant up
```

If this is successful Cloudsoft AMP will be available at: [http://10.10.10.100:8081/](http://10.10.10.100:8081/) with "admin" and "password" as the default username and password, respectively.
For more information about getting AMP running, see [this guide](http://docs.cloudsoft.io/tutorials/tutorial-get-amp-running.html).

Note 1: These steps assume you already have Virtualbox and Vagrant installed on your local machine and have external network access to the Ubuntu update repositories and the Cloudsoft Artifactory server.

Note 2: If you're on Windows, you'll need to run Vagrant from a [Cygwin](https://cygwin.com/install.html) terminal
with the `rsync` and `openssl` packages installed (be sure to select these packages when running the Cygwin installer).
If you already have Cygwin installed, simply re-run the setup executable and follow the installation prompts to install
the necessary packages.


### Step 2: Create a Deployment Location

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "Location" under "Add to Catalog"
* Select the desired type of location and fill in the required fields

Be sure to make note of the "Location ID" that you choose during the final step.

If you plan on deploying to Vagrant VMs running locally, follow
[this guide](http://docs.cloudsoft.io/tutorials/tutorial-get-amp-running.html#add-a-location)
to add them as a deployment location. Note that you should include the following IP addresses in the "Hosts" text field:

```
10.10.10.101
10.10.10.102
10.10.10.103
10.10.10.104
10.10.10.105
```

For more information about AMP locations, see this guide's [appendix](#appendix) and
[the Apache Brooklyn documentation](https://brooklyn.apache.org/v/latest/ops/locations/).


### Step 3: Add Hyperledger to the AMP Catalog

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "YAML" under "Add to Catalog"
* This take you to the Blueprint Composer which should be set to "Catalog" by default
* Copy and paste:
```
brooklyn.catalog:
  items:
  - https://raw.githubusercontent.com/cloudsoft/brooklyn-hyperledger/master/docker.bom
  - https://raw.githubusercontent.com/cloudsoft/brooklyn-hyperledger/master/catalog.bom
```
* Click "Add to Catalog" button


### Step 4a: Deploy a Hyperledger Fabric Cluster to One Location

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "+ add application" button
* Click the "Hyperledger Fabric Single-cluster" tile
* Click the "Next" button
* Select the location that you previously created from the "Locations" drop-down list
* Enter a name (optional)
* Click the "Deploy" button

If you plan on deploying to Vagrant VMs running locally, only deployment to one location is supported
with a maximum cluster size of 3. However, the size of the cluster can be increased if you add more VMs
to [servers.yaml](servers.yaml).


### Step 4b: Deploy a Hyperledger Fabric Cluster to Multiple Locations

This deployment is capable of creating multiple clusters of validating peer nodes across
different locations, all members of the same Hyperledger Fabric.

Note that this deployment requires multiple locations to be configured.

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "+ add application" button
* Click the "Hyperledger Fabric Multi-cluster" tile
* Click the "Next" button
* Select a location from the list -- this is for the membership services and CLI hosts
* Click "Add Additional Location"
* Select another location from the list -- this is for the root validating peer node
* Click "Add Additional Location"
* Select another location from the list -- this is for a cluster of validating peer nodes
* Continue adding additional locations to create additional clusters of validating peer nodes
* Enter a name (optional)
* Click the "Deploy" button


## Demo Application Instructions

Once your cluster has successfully deployed, perform the following steps to deploy the asset management demonstration app.  This app repeatedly assigns an asset "Picasso" from one owner to another.  For more information about this app as well as its source code, see the [Fabric repository](https://github.com/hyperledger/fabric/tree/master/examples/chaincode/go/asset_management).

### Run Using AMP Effector
* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click on the "Applications" tab
* Hover over the ">" under "Hyperledger Fabric Application" (or your custom name)
* Click "Expand All"
* Click "CLI Node"
* Click the "Effectors" tab
* Click "Invoke" next to "Run Demo Application"

### Run Manually

#### Step 1: SSH into CLI Node

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click on the "Applications" tab
* Hover over the ">" under "Hyperledger Fabric Application" (or your custom name)
* Click "Expand All"
* Click "CLI Node"
* Click the "Sensors" tab
* Copy the `host.sshAddress` value
* Open up your terminal and run command: `ssh <ssh-address-here>`

Note 1: You may need to supply an SSH key or a username / password depending on your
deployment location's configuration.

Note 2: If `host.sshAddress` ends with a port (e.g. `:22`), remove the colon and the port from the SSH command.

Note 3: If you deployed to local Vagrant VMs, you can SSH into any of these VMs by running this command instead:
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
