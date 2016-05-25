# Brooklyn Hyperledger

This repository contains [Apache Brooklyn](https://brooklyn.apache.org/) blueprints for a
[Hyperledger Fabric](https://github.com/hyperledger/fabric) cluster deployment.


## Instructions

You can skip Step 1 if you have previously installed Cloudsoft AMP.


### Step 1: Get Cloudsoft AMP

First, register to ensure that you receive regular updates:

    http://www.cloudsoft.io/get-started/

Then follow the online instructions (reproduced here for simplicity):

    git clone https://github.com/cloudsoft/amp-vagrant
    cd amp-vagrant
    vagrant up amp


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


## Using Your Cluster

To monitor the deployment status of your cluster, go back to the AMP Console in your
browser and click the "Applications" tab.

When the cluster has been successfully deployed, explore all of the nodes in the list
under "Applications" on the left.


### Operations on the cluster

Hyperledger Fabric exposes the 
[Open Blockchain REST service](https://github.com/openblockchain/obc-docs/blob/60852a53c3659104130b5809534dc0de03775df9/protocol-spec.md#61-rest-service) 
endpoints as Apache Brooklyn 
[effectors](https://brooklyn.apache.org/v/latest/concepts/configuration-sensor-effectors.html#sensors-and-effectors)
on the peer node 
[entities](https://brooklyn.apache.org/v/latest/concepts/entities.html).


#### User management

Corresponds to the 
[registrar API](https://github.com/openblockchain/obc-docs/blob/60852a53c3659104130b5809534dc0de03775df9/protocol-spec.md#6215-registrar-api-member-services).

| Name        | API Endpoint                          | Description                                                                                                                                                                                                       |
|-------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Check Login | `GET /registrar/{enrollmentID}`       | Confirms whether the given user is registered with the CA.                                                                                                                                                        |
| Login User  | `POST /registrar`                     | Sign the given user in with the given password.                                                                                                                                                                   |
| Get TCert   | `GET /registrar/{enrollmentID}/tcert` | Retrieve the [transaction certificates](https://github.com/openblockchain/obc-docs/blob/60852a53c3659104130b5809534dc0de03775df9/protocol-spec.md#42-user-privacy-through-membership-services) of the given user. |
| Get ECert   | `GET /registrar/{enrollmentID}/ecert` | Retrieve the [enrollment certificate](https://github.com/openblockchain/obc-docs/blob/60852a53c3659104130b5809534dc0de03775df9/protocol-spec.md#42-user-privacy-through-membership-services) of the given user.   |


#### Chaincode

Corresponds to the 
[chaincode API](https://github.com/openblockchain/obc-docs/blob/60852a53c3659104130b5809534dc0de03775df9/protocol-spec.md#6213-chaincode-api).

Use the **Deploy Chaincode** effector to deploy a chaincode on a node's filesystem. Its parameters are:

* _chaincode_ a path to the directory containing the chaincode
* _function_ the chaincode function to invoke (defaults to `init`)
* _args_ a list of parameters for the function
* _secureContext_ the enrollment ID of a logged in user

For example, to deploy Hyperledger Fabric's
[example02 chaincode](https://github.com/hyperledger/fabric/blob/f7ce5afcfcde3085fa07327203d764888fabb84e/examples/chaincode/go/chaincode_example02/chaincode_example02.go)
use the effector with:

* _chaincode_ `github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02`
* _args_ `["a","100", "b", "200"]`
* _secureContext_ `lukas`

On successful invocation of the deploy effector Brooklyn will return the name of the newly-started chaincode. 
Take a note of this.


Use the **Invoke Chaincode** effector to execute a function within the chaincode. Its parameters are:

* _name_ the name of the chaincode as returned by the deploy transaction.
* _function_ the chaincode function to invoke (defaults to `invoke`)
* _args_ a list of parameters for the function
* _secureContext_ the enrollment ID of a logged in user

To continue the `example02` example, to move ten units from `Alice` to `Bob`, use the effector with:

* _name_ the chaincode name
* _function_ `invoke`
* _args_ `["Alice", "Bob", "10"]`
* _secureContext_ `lukas`

On successful invocation of this effector Brooklyn will return the output of the command.


Lastly, use the **Query Chaincode** effector to query the state of a chaincode. Its parameters are much as 
the invoke effector:

* _name_ the name of the chaincode as returned by the deploy transaction.
* _function_ the chaincode function to invoke (defaults to `query`)
* _args_ a list of parameters for the function
* _secureContext_ the enrollment ID of a logged in user

For example, to check the value Alice has:

* _name_ the chaincode name
* _function_ `query`
* _args_ `["Alice"]`
* _secureContext_ any user

On successful invocation of this effector Brooklyn will return the output of the command.


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
