# Code challenge

## Building the project

The only local dependency required is Terraform. It can be downloaded
and installed from:

https://www.terraform.io/downloads.html

Once Terraform has been installed, you'll need to set appropriate
environment variables for your AWS credentials, namely:

```shell
$ export AWS_ACCESS_KEY_ID=xxxx
$ export AWS_SECRET_ACCESS_KEY=xxxx
```

The infrastructure can be built and the Hello app launched by running:

`$ ./launch.sh`

Upon completion, you'll be given a URL which you can curl to test out
the service:

```shell
$ curl http://x.x.x.x/hello
$ curl http://x.x.x.x/hello?name=JD
```

## Some final thoughts

By and large, my initial approach held, with the notable exception that
I decided that Chef was overkill for the amount of provisioning needed
on the EC2 instance once it had been launched. Instead, I opted for a
short shell script that is uploaded and executed by Terraform.

## Initial approach

After reading the written requirements and asking EJ for clarification
on a few points, I've decided to take the following approach, breaking
the project into essentially 3 distinct phases.

1. I'll write a simple web service in Ruby, using the Sinatra framework.
   This service will expose one endpoint, `/hello`, which will take a
   single, optional parameter, `name`. If no name is specified, the
   service will simply return an HTTP status of 200 with the string
   "Hello!" in the body. If `name` is provided, the service will respond
   with a 200 and "Hello, <name>!" as its response. I will provide a
   `Dockerfile` alongside the service to build an image which can then
   be deployed. The image will expose a single port, Sinatra's default
   `4567`. For simplicity and because I don't have access to EC2
   Container Registry for this exercise, I'll cheat just a bit and build
   this image in the next phase, rather than building and then pushing
   to a Docker repo.

2. With a deployable image available, my next phase will be to write
   a Chef cookbook to configure an Ubuntu host with the following
   objectives:

   - Install and run Docker on the host
   - Build the application image from phase 1
   - Run the application as a Docker container, exposing port `4567` and
     mapping it to local port `80`

3. With configuration management code written to configure a host to
   serve the application, the final piece will be to actually run the
   application in EC2. To accomplish this, I'll write Terraform code to
   do the following:

   - Create a VPC in which to run the EC2 instance (and potentially an
     ALB)
   - Create a security group for the EC2 instance, allowing inbound
     traffic from anywhere to port 22 for SSH and port 80 for the web
     service
   - Create an EC2 instance, bootstrap it with Chef, transfer the
     configuration management code from phase 2 to the instance, run Chef
     to configure the instance, and output the public hostname of the
     EC2 instance where the web service will be reachable.
   - If time allows, I may add an ALB in front of the instance, though
     it's not required to meet the objectives of this assignment.
