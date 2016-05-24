# brooklyn-hyperledger

This repository contains [Apache Brooklyn](https://brooklyn.apache.org/) blueprints for a
[Hyperledger Fabric](https://github.com/hyperledger/fabric) cluster deployment.

Currently the cluster uses the "noops" consensus plugin, but support for the "pbft" plugin
and member services are both on the short-term roadmap.


## Instructions

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
vagrant up amp
```

If this is successful Cloudsoft AMP will be available at: [http://10.10.10.100:8081/](http://10.10.10.100:8081/)

Note: These steps assume you already have Virtualbox and Vagrant installed on your local machine and have external network access to the Ubuntu update repositories and the Cloudsoft Artifactory server.


### Step 2: Create a Deployment Location

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "Location" under "Add to Catalog"
* Select the desired type of location and fill in the required fields

Be sure to make note of the "Location ID" that you choose during the final step.

For more information about AMP locations, see this guide's appendix and 
[the Apache Brooklyn documentation](https://brooklyn.apache.org/v/latest/ops/locations/).


### Step 3: Add Hyperledger to the AMP Catalog

* Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "YAML" under "Add to Catalog"
* This take you to the Blueprint Composer which should be set to "Catalog" by default
* Copy and paste [catalog.bom](catalog.bom)
* Click "Add to Catalog" button


### Step 4: Deploy a Hyperledger Cluster

Go to [http://10.10.10.100:8081/](http://10.10.10.100:8081/) in your browser (the Cloudsoft AMP Console)
* Click the "Catalog" tab
* Click the circle with a plus sign inside it (next to "Catalog" on the left)
* Click "YAML" under "Add to Catalog"
* This take you to the Blueprint Composer which should be set to "Catalog" by default
* Select "Application"
* Copy and paste [hyperledger-cluster.yaml](hyperledger-cluster.yaml) and replace `<your-location>`
with the "Location ID" you created above
* Click "Deploy" button


## Monitor and Use Your Cluster

To monitor the deployment status of your cluster, go back to the AMP Console in your
browser and click the "Applications" tab.

When the cluster has been successfully deployed, explore all of the nodes in the list
under "Applications" on the left.

To test out your cluster, SSH into one of the nodes (using the value of the
`host.sshAddress` sensor) and follow [these instructions](https://github.com/hyperledger/fabric/blob/master/docs/dev-setup/devnet-setup.md#deploy-invoke-and-query-a-chaincode)
from the HyperLedger Fabric documentation.


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
          installDevUrandom: true
