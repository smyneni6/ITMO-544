#!/bin/bash
echo -ne "Hello \n"
echo -ne "***********autoscaling group name************\n"
asgName=`aws autoscaling describe-auto-scaling-groups --query AutoScalingGroups[].AutoScalingGroupName`
echo -ne "************updating autoscaling min max to zero***********\n"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $asgName --max-size 0 --min-size 0
echo -ne "*********Decribe to check no instances running in auto-scaling-group**********\n"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgName
sleep 45
echo -ne "**********Instances terminated**********\n"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $asgName
echo -ne "**********Find and delete launch-configuration**********"
lcName=`aws autoscaling describe-launch-configurations --query LaunchConfigurations[].LaunchConfigurationName`
aws autoscaling delete-launch-configuration --launch-configuration-name $lcName
echo -ne "***************Find and delete load balancer**************\n"
elbName=`aws elb describe-load-balancers --query LoadBalancerDescriptions[].LoadBalancerName`
aws elb delete-load-balancer --load-balancer-name $elbName
echo -ne "*****************AutoScalingGroup destroyed successfully***********"
