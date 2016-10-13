#!/bin/bash
echo -ne "hello 544 /n"
echo -ne "Pass required parameter to create environment"
params=$#
if [ $# -ne 5 ] 
echo -ne "Check number of Paramters!Please pass all five parameters in order of AMI ID, Key-name, Security-Group, Launch-configuration and count"
else
aws ec2 run-instances --image-id $1 --key-name $2 --security-group-ids $3 --instance-type t2.micro --count $5 --user-data file://installenv.sh
echo -ne "---------------instances are launching-------------/n"
InstanceID1=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId] --output text | grep us-west-2b | grep pending|awk '{print $3}'`
aws ec2 wait instance-running --instance-ids $InstanceID1
echo -ne "----------------List of instanceId-----------/n"
InstanceId=`aws ec2 describe-instances --query 'Reservations[*].Instances[].[InstanceId,State.Name]' --output text | grep running|awk '{print $1}'`
echo $InstanceId
echo -ne "Finding subnet/n"
SubnetId=`aws ec2 describe-subnets --filters "Name=availabilityZone,Values=us-west-2b" --query 'Subnets[].SubnetId'`
echo -ne "Creating load balancer with listeners and subnet/n"
aws elb create-load-balancer --load-balancer-name week4-elb --listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 --subnets $SubnetId
echo -ne "load balancer created with listners/n"
sleep 5
echo -ne "Registering isntances with load balancer/n"
aws elb register-instances-with-load-balancer --load-balancer-name week4-elb --instances $InstanceId
echo -ne "Instances registered with load balancer/n"
sleep 5
echo -ne "Creating launch-configuration : webserver/n"
aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --instance-type t2.micro --user-data file://installenv.sh
echo -ne "Launch configuration created/n"
sleep 5
echo -ne "Creating auto-scaling-group/n"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name week4 --launch-configuration $4 --availability-zone us-west-2b --load-balancer-names week4-elb --max-size 5 --min-size 2 --desired-capacity 4
echo -ne "***Auto-scaling group configured.Completed sucessfully!******** "
