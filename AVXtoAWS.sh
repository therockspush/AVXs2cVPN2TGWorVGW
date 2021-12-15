#!/bin/bash


read -p 'Aviatrix Controller IP: ' ControllerIP

read -sp 'Aviatrix Controller Password: ' ControllerPW
echo
read -p 'Aviatrix Transit VPC ID w/Name: ' VPCID
read -p 'Aviatrix Gateway to Build Tunnel From: ' GWName
read -p 'Config file 1 from AWS Console: ' File1
read -p 'Config file 2 from AWS Console: ' File2
read -p 'Tunnel 1 name: ' ConnectionName1
read -p 'Tunnel 2 name: ' ConnectionName2



#Login
CID=`curl -s -k --location --request POST "https://$ControllerIP/v1/api" \
--form 'action=login' \
--form 'username=admin' \
--form "password=$ControllerPW" | grep -o 'CID.*'|cut -d'"' -f3`


#Get info from aws files
VPG1=($(awk '/- Virtual Private Gateway/ {print}' $File1 | awk -F":" '{ print $2}')) 
CGW1=($(awk '/- Customer Gateway/ {print}' $File1 | awk -F":" '{ print $2}'))
VPG2=($(awk '/- Virtual Private Gateway/ {print}' $File2 | awk -F":" '{ print $2}'))
CGW2=($(awk '/- Customer Gateway/ {print}' $File2 | awk -F":" '{ print $2}'))
PSK1=($(awk '/- Pre-Shared Key/ {print}' $File1 | awk -F":" '{ print $2}'))
PSK2=($(awk '/- Pre-Shared Key/ {print}' $File2 | awk -F":" '{ print $2}'))
ASN=($(awk '/- Virtual Private  Gateway ASN/ {print}' $File1 | awk -F":" '{ print $2}'))

#echo ${VPG1[@]}
#echo ${CGW1[@]}
#echo ${VPG2[@]}
#echo ${CGW2[@]}
#echo ${PSK1[@]}
#echo ${PSK2[@]}
#echo ${ASN[@]}

#echo ${VPG1[0]},${VPG2[0]}

#build part1
curl -s -k --location --request POST "https://$ControllerIP/v1/api" \
--form 'action=connect_transit_gw_to_external_device' \
--form "vpc_id=$VPCID" \
--form "connection_name=$ConnectionName1" \
--form "transit_gw=$GWName" \
--form "pre_shared_key=${PSK1[0]},${PSK2[0]}" \
--form 'enable_ha=false' \
--form 'enable_ikev2=false' \
--form "external_device_ip_address=${VPG1[0]},${VPG2[0]}" \
--form "local_tunnel_ip=${CGW1[1]},${CGW2[1]}" \
--form 'routing_protocol=bgp' \
--form 'tunnel_protocol=IPsec' \
--form "external_device_as_number=${ASN[0]}" \
--form "bgp_local_as_number=${CGW1[2]}" \
--form 'direct_connect=false' \
--form "remote_tunnel_ip=${VPG1[1]},${VPG2[1]}" \
--form "CID=$CID"

#build part2
curl -s -k --location --request POST "https://$ControllerIP/v1/api" \
--form 'action=connect_transit_gw_to_external_device' \
--form "vpc_id=$VPCID" \
--form "connection_name=$ConnectionName2" \
--form "transit_gw=$GWName" \
--form "pre_shared_key=${PSK1[1]},${PSK2[1]}" \
--form 'enable_ha=false' \
--form 'enable_ikev2=false' \
--form "external_device_ip_address=${VPG1[2]},${VPG2[2]}" \
--form "local_tunnel_ip=${CGW1[4]},${CGW2[4]}" \
--form 'routing_protocol=bgp' \
--form 'tunnel_protocol=IPsec' \
--form "external_device_as_number=${ASN[0]}" \
--form "bgp_local_as_number=${CGW1[2]}" \
--form 'direct_connect=false' \
--form "remote_tunnel_ip=${VPG1[3]},${VPG2[3]}" \
--form "CID=$CID"







