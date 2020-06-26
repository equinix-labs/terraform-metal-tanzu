# Adapted from: https://vthinkbeyondvm.com/script-to-configure-vsphere-supervisor-cluster-using-rest-apis/

import requests
import json
import ssl
import atexit
import sys
import argparse
import getpass

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

s=requests.Session()
s.verify=False

# Vars from Terraform
host = '${vcenter_host}'
user = '${vcenter_admin}'
password = '${vcenter_password}'
clustername = '${cluster_name}'
mastervmnetwork = '${cp_vm_network}'
startingip = '${starting_ip}'
mastersm = '${cp_subnet_mask}'
gatewayip = '${cp_gateway_ip}'
dnsserver = '${dns_server}'
ntpserver = '${ntp_server}'
storagepolicy = '${storage_policy_name}'
egressaddress = '${egress_starting_ip}'
ingressaddress = '${ingress_starting_ip}'

# Constants
wcpsize = 'TINY'
podcidr = '10.244.0.0/21'
servicecidr = '10.96.0.0/24'

egressingressprefix = '/27'

headers = {'content-type':'application/json'}
session_response= s.post('https://'+host+'/rest/com/vmware/cis/session',auth=(user,password))

if session_response.ok:
	print ("Session creation is successful")
else:
	print ("Session creation is failed, please check")
	quit()

#Getting cluster moid
cluster_object=s.get('https://'+host+'/rest/vcenter/cluster?filter.names='+clustername)
if len(json.loads(cluster_object.text)["value"])==0:
	print ("NO cluster found, please enter valid cluster name")
	sys.exit()
cluster_id=json.loads(cluster_object.text)["value"][0].get("cluster")
print ("cluster-id::"+cluster_id)

#Getting storage policy id
storage_policy_object=s.get('https://'+host+'/rest/vcenter/storage/policies')
sp_policy_response=json.loads(storage_policy_object.text)
sp_policies=sp_policy_response["value"]
sp_id=""
for policy in sp_policies:
	if (policy.get("name")==storagepolicy):
		sp_id=policy.get("policy")
		break
if sp_id=="":
	print ("policy name not found, please check")
	sys.exit()
print ("storage policy id:"+sp_id)

#Getting distributed switch id , assuming only one VDS associated with cluster that NSX TZ is configured with. Just avoiding further processing
#TODO: null check handling if we do not get compatible cluster
dvs_object=s.get('https://'+host+'/api/vcenter/namespace-management/distributed-switch-compatibility?cluster='+cluster_id+'&compatible=true')
dvs_id=json.loads(dvs_object.text)[0]['distributed_switch']
print (dvs_id)
	
#Getting edge cluster id. Assuming only one edge cluster asscociated with this VDS
edge_object=s.get('https://'+host+'/api/vcenter/namespace-management/edge-cluster-compatibility?cluster='+cluster_id+'&compatible=true&distributed_switch='+dvs_id)
edge_id=json.loads(edge_object.text)[0]['edge_cluster']
print (edge_id)

#Getting master network portgroup id
network_object=s.get('https://'+host+'/rest/vcenter/network?filter.names='+mastervmnetwork)
if len(json.loads(network_object.text)["value"])==0:
	print ("NO network found, please enter valid master network port group name")
	sys.exit()
network_id=json.loads(network_object.text)["value"][0].get("network")
print ("network id::"+network_id)


payload = {
   "image_storage":{
      "storage_policy": sp_id
   },
   "ncp_cluster_network_spec":{
      "nsx_edge_cluster": edge_id,
      "pod_cidrs":[
         {
            "address": podcidr.split('/')[0],
            "prefix": podcidr.split("/",1)[1]
         }
      ],
      "egress_cidrs":[
         {
            "address": egressaddress,
            "prefix": egressingressprefix
         }
      ],
      "cluster_distributed_switch": dvs_id,
      "ingress_cidrs":[
         {
            "address": ingressaddress,
            "prefix": egressingressprefix
         }
      ]
   },
   "master_management_network":{
      "mode":"STATICRANGE",
      "address_range":{
         "subnet_mask": mastersm,
         "starting_address": startingip,
         "gateway": gatewayip,
         "address_count":5
      },
      "network": network_id
   },
   "master_NTP_servers":[
      ntpserver
   ],
   "ephemeral_storage_policy": sp_id,
   "service_cidr":{
      "address":servicecidr.split('/')[0],
      "prefix":servicecidr.split("/",1)[1]
   },
    "size_hint": wcpsize,
   "master_DNS":[
      dnsserver
   ],
    "worker_DNS":[
      dnsserver
   ],
   "network_provider":"NSXT_CONTAINER_PLUGIN",
   "master_storage_policy": sp_id
}

json_payload = json.loads(json.dumps(payload))
json_response = s.post('https://'+host+'/api/vcenter/namespace-management/clusters/'+cluster_id+'?action=enable',headers=headers,json=json_payload)
if json_response.ok:
	print ("Enable API invoked, checkout your H5C")
else:
	print ("Enable  API NOT invoked, please check your inputs once again")
print (json_response.text)
session_delete=s.delete('https://'+host+'/rest/com/vmware/cis/session',auth=(user,password))
