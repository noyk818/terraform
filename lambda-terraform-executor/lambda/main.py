import os
import boto3

ecs = boto3.client('ecs')

cluster_name  = os.environ['CLUSTER_NAME']
service_names = os.environ['SERVICE_NAME'].split(',')

def lambda_handler(event, context):
    desired_count = int(event['desiredCount'])
    
    for service in service_names:
        response = ecs.update_service(
            cluster=cluster_name,
            service=service.strip(),
            desiredCount=desired_count
        )
        print(f"Updated {service}: {response['service']['desiredCount']}")
