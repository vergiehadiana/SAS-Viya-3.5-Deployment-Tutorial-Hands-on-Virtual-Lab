#!/bin/bash

bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/03-Connecting_to_the_environment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/03-Connecting_to_the_environment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/04-YUM_and_RPM.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/04-YUM_and_RPM.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/05-Installing_Ansible_on_SASVIYA01.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/05-Installing_Ansible_on_SASVIYA01.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/06-Configuring_Ansible_to_target_the_servers.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/06-Configuring_Ansible_to_target_the_servers.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/07-Building_your_deployment_playbook.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/07-Building_your_deployment_playbook.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/08-Mirror_Creation.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/08-Mirror_Creation.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/09-Performing_the_pre-requisites.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/09-Performing_the_pre-requisites.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/10-OpenLDAP_deployment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/10-OpenLDAP_deployment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/11-Playbook_upload_and_prep.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/11-Playbook_upload_and_prep.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/12-Split_Deployment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/12-Split_Deployment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/13-Viya_Services_Management.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/13-Viya_Services_Management.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/14-Validation.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/14-Validation.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/15-Add_a_new_CAS_Server.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/15-Add_a_new_CAS_Server.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/16-HA_Deployment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/16-HA_Deployment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/18-Update_your_order_with_a_new_product.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/18-Update_your_order_with_a_new_product.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/19-Configure_Data_connector_to_access_Hive.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/19-Configure_Data_connector_to_access_Hive.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/20-Creating_a_new_account_for_Viya_deployment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/20-Creating_a_new_account_for_Viya_deployment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/21-Jupyter_Hub.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/21-Jupyter_Hub.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/22-Configure_remote_HDFS_Access.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/22-Configure_remote_HDFS_Access.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/23-1-FullSplit_Deployment.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/23-1-FullSplit_Deployment.log   
bash -x /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/23-2-Configure_local_HDFS.sh 2>&1 | tee -a  /home/cloud-user/GELVIYADEP35-deploying-viya-3.5-on-linux/23-2-Configure_local_HDFS.log   
