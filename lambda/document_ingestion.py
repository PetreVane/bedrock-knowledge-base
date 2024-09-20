
import boto3
import os
import logging
import json
import uuid
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

bedrock = boto3.client("bedrock-agent")
s3 = boto3.client("s3")
idempotency_token = str(uuid.uuid4())


def handler(event, context):

    # Extract the file name from S3 event
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']

    logger.info(f"File uploaded: s3://{bucket}/{key}")

    # Get environment variables
    knowledge_base_id = os.environ['KNOWLEDGE_BASE_ID']
    data_source_id = os.environ['DATA_SOURCE_ID']
    logger.info(f"Knowledge Base ID: {knowledge_base_id}")
    logger.info(f"Data Source ID: {data_source_id}")

    if knowledge_base_id is None or data_source_id is None:
        return {
             'statusCode': 400,
             'body': json.dumps('KNOWLEDGE_BASE_ID and DATA_SOURCE_ID environment variables are required')
         }

    try:
        # Start document ingestion
        response = bedrock.start_ingestion_job(
            clientToken=idempotency_token,
            knowledgeBaseId=knowledge_base_id,
            dataSourceId=data_source_id,
            description=f"Ingestion started for file: {key}"
        )

        logger.info(f"Ingestion job started: {json.dumps(response, default=str)}")
        ingestion_job = response.get('IngestionJob', {})
        job_id = ingestion_job.get('ingestionJobId', '')
        status = ingestion_job.get('status', '')
        if status == 'FAILED':
            logger.error(f"Ingestion job failed: {job_id}")

        return {
            'statusCode': 200,
            'body': json.dumps('Ingestion job started successfully')
        }

    except ClientError as e:
        logger.error(f"Error starting ingestion job: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Unexpected error: {str(e)}")
        }
