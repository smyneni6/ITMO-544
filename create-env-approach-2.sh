#!/bin/bash
echo -ne "Hello $1\n"
echo -ne "*********Finding subnet***********\n"
SubnetId=`aws ec2 describe-subnets --filters "Name=availabilityZone,Values=us-west-2b" --query 'Subnets[].SubnetId'`
echo -ne "****Creating load balancer with listeners and subnet*********\n"
aws elb create-load-balancer --load-balancer-name test-week4-elb --listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 --subnets $SubnetId
echo -ne "******Launch configuration************\n"
aws autoscaling create-launch-configuration --launch-configuration-name test-webserver --image-id $1 --instance-type t2.micro --user-data file://installenv.sh
echo -ne "**********create auto-scaling-group***********\n"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name test-asg --launch-configuration-name test-webserver --availability-zones "us-west-2b" \
--load-balancer-names "test-week4-elb" \
--max-size 5 --min-size 1 --desired-capacity 2
echo -ne "**********Successfully completed************\n"
