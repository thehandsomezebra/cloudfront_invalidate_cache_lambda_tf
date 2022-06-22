import boto3
import time
import os
import json


def lambda_handler(event, context):
    dist = event['DISTRIBUTION_ID'] # // get the Distribution ID from the lambda environment variable
    client = boto3.client('cloudfront')
    invalidation = client.create_invalidation(
        DistributionId=dist,
        InvalidationBatch={
            'Paths': {
                'Quantity': 1,
                'Items': [
                    '/*', # // Update this section for specific paths
                ]
        },
        'CallerReference': str(time.time())
    })
    
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully created cache invalidation for ') + dist
    }