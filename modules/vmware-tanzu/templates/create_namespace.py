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
nsuser = '${nsuser}'
nsdomain = '${nsdomain}'
clustername = '${cluster_name}'
namespace = '${namespace}'
storagepolicy = '${storagepolicy}'
storagelimit = '${storagelimit}'

# Constants
description = 'Tanzu Namespace'
subjecttype = 'USER'
nsrole = 'EDIT'



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


payload = {
  "cluster" : cluster_id,
  "namespace" : namespace,
  "description" : description,
  "access_list" : [
  {
  "role" : nsrole,
  "subject_type" : subjecttype,
  "subject" : nsuser,
  "domain" : nsdomain
  }
  ],
  "storage_specs" : [
  {
  "limit" : storagelimit,
  "policy" : sp_id 
  }
  ],
  "resource_spec" : {
  }
}

json_payload = json.loads(json.dumps(payload))
json_response = s.post('https://'+host+'/api/vcenter/namespaces/instances',headers=headers,json=json_payload)
if json_response.ok:
	print ("Supervisor Namespace creation invoked, checkout your H5C")
else:
	print ("Supervisor Namespace creation NOT invoked, please check your inputs once again")
print (json_response.text)
session_delete=s.delete('https://'+host+'/rest/com/vmware/cis/session',auth=(user,password))
