# Word Service

by: Coleman Word

August 2018

### Goals

* Make binaries accessible via localhost:8080 using Docker
* Create a cli that supports --help entrypoint
* Automate the provisioning of local MYSQL
* Create policy for making Put and Get requests to an S3 bucket

### Command Line Interface: Golang- Cobra


![cobra-cli](https://compositecode.files.wordpress.com/2018/04/cobra.png?w=788)

For me, using Golang was an obvious choice since it compiles to binary which can be passed into the container without any additional dependencies. I decided to use the Cobra CLI library since I have experience with it and it has been used on many large-scale projects like Docker and Kubernetes.


To use Cobra:


```
go get github.com//spf13/cobra/cobra
```
navigate to your project directory


```
cobra init "path to project"
```




### Ansible
![ansible](https://www.fullstackpython.com/img/logos/ansible-wide.png)

I decided to use Ansible for creating scalable and reusable automation for bootstraping MYSQL and AWS S3 roles and policies.

I normally use Terraform for large infrastructure deployments to AWS and Ansible for local configurations or ad-hoc tasks.

playbooks can be ran as so:

```
docker run colemanword/ansible "playbook"
```
Replace playbook with the yaml file you'd like to run.



## Results

 *Update playbooks/inventory/groupvars/all before running ansible playbooks*

### Run Bats Test

![alt text](https://github.com/ops2go/word/blob/master/imgs/bats-success.png?raw=true)



### Install MYSQL

```
ansible-playbook install-mysql
```
![](https://github.com/ops2go/word/blob/master/imgs/install-mysql.png?raw=true)

### Create MYSQL DB



```
ansible-playbook create-mysqldb.yml
```
![](https://github.com/ops2go/word/blob/master/imgs/create-mysqldb.png?raw=true)


### Create MYSQL User



```
mysql-create-user.yml
```

![](https://github.com/ops2go/word/blob/master/imgs/create-mysql-usr.png?raw=true)

### Create S3 Bucket

*Note: I decided to use the awscli since it was a pretty quick and simple task to create a bucket and create a policy. Ansible, Terraform, or Cloudformation could be used as an alternative for more complex tasks. I dockerized the awscli so that the user does not have to install all of aws's dependencies onto their machine.

Build the docker image:
```
docker build -t aws .
```

Create the bucket:
```
docker run aws aws s3 mb ibt-homework-bucket


### Create S3 IAM Policy

The json policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:Put*"
            ],
            "Resource": [
                "arn:aws:s3:::ibt-homework-bucket/*"
            ]
        }
    ]
}

```
Build the docker image:
```
docker build -t aws .
```
Create the policy:
```
docker run aws aws iam create-policy --policy-name s3-policy --policy-document file://s3-policy.json
```

## Considerations

### Version Control

Merkle Trees:


*   Git

Git is an excellent tool for version-controlling source code.

*   Docker

Docker is excellent for version control since images are immutable and can be tagged.

*   Dockerhub

Container images should be tagged properly to reflect their contents. Images can be reused by pulling the tagged images from Dockerhub or something like AWS ECR.

Artifact Storage:


*   S3
Artifacts from Golang binaries and Docker images can be uploaded and stored in S3 buckets to ensure they are never lost.








### Scalability/Reproducibility

The process in which I created the Docker Image can be scaled to deliver thousands of binary services by using the cli/ bin/ and tests/ folder as templates for passing binaries into Alpine Linux Docker images. The binaries passed into the container in this repo can be replaced with any binary.

To scale the services, I would use Kubeadm to bootstrap a Kubernetes environment on-prem or in a virtual private cloud(VPC). I would use a secure MYSQL docker image and deploy the services onto Kubernetes using Helm charts with persistant volumes. AWS Relational database service could be used as well. The Kubernetes Kafka operator or AWS kinesis could also be used as a message broker for calling individual services in the cluster.

Kubernetes is preferred since it has built in high availability, failover, namespacing, and more for containerized services. 

The Ansible Playbooks provided could be used by an administrator to replicate and scale MYSQL installations for each developers environment. A hosts file containing the ip addresses of all target hosts could be implemented to accomplish this.



### CICD Pipeline

Although it would be easy to manually deploy images onto a Kubernetes cluster, a CICD pipeline could be designed to autodeploy images based on new commits.  I am accustomed to using Gitlab for creating a CICD pipeline but alternatives include:

- Jenkins

- Travis

- Drone

- Concourse

- Circle CI






### Configuration Secrets

Configuration Secrets can be passed into the container at buildtime with CICD build script or a something like Hashicorp's Vault.

## Final Thoughts



*   The ansible and aws repo should be in a separate repository from the container build repo

*   Building the CLI could be automated with a multistage Docker build

*   The Cobra CLI could be developed to support functionality like http requests, or integrate with aws via their golang sdk.

*   It would be a hassle to require all developers to download Ansible on their PC. A sysadmin should use the playbooks to configure all necessary dev environments using the hosts file in playbooks/inventory/hosts

*  S3fs can be used to mount an S3bucket locally

* Secrets can be passed to containers using Vault
