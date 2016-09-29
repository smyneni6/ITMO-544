#!/bin/bash
echo -ne "hello 544 /n"
echo -ne "launching instances $1 $2"
aws ec2 run-instances --image-id $1 --key-name week3 --security-group-ids sg-d36ea2aa --instance-type t2.micro --count $2 --user-data file://installenv.sh
echo -ne "---------------instances are launching-------------/n"
aws ec2 wait instance-running --filters "Name=availability-zone,Values=us-west-2b"
sleep 90
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
aws autoscaling create-launch-configuration --launch-configuration-name webserver --image-id $1 --key-name week3 --instance-type t2.micro --user-data file://installenv.sh
echo -ne "Launch configuration created/n"
sleep 5
echo -ne "Creating auto-scaling-group/n"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name week4 --launch-configuration webserver --availability-zone us-west-2b --load-balancer-names week4-elb --max-size 5 --min-size 2 --desired-capacity 4
echo -ne "***Auto-scaling group configured.Completed sucessfully!******** "