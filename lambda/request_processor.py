import json
import asyncio
import os
import boto3
import logging
from typing import List, Dict, Any, TypedDict
from dataclasses import dataclass
from botocore.exceptions import BotoCoreError, ClientError
from urllib3 import request

# Sets up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Custom exception
class ConfigurationError(Exception):
    """Raised when there's an issue with the configuration or environment variables."""
    pass

# TypedDict for return type of retrieve_context
class RetrievalResult(TypedDict):
    context: str
    is_rag_working: bool
    rag_sources: List['RAGSource']

@dataclass
class RAGSource:
    """
    Represents a source from the Retrieval-Augmented Generation (RAG) process.

    Attributes:
        id (str): Unique identifier for the source.
        file_name (str): Name of the file associated with the source.
        snippet (str): A text snippet from the source.
        score (float): Relevance score of the source.
    """
    id: str
    file_name: str
    snippet: str
    score: float

def get_bedrock_client() -> boto3.client:
    """
    Creates and returns a boto3 client for Amazon Bedrock.

    Raises:
        ConfigurationError: If required environment variables are missing.

    Returns:
        boto3.client: Configured Bedrock client.
    """

    required_env_vars = ["REGION", "BAWS_ACCESS_KEY_ID", "BAWS_SECRET_ACCESS_KEY"]
    missing_vars = [var for var in required_env_vars if not os.environ.get(var)]

    if missing_vars:
        raise ConfigurationError(f"Missing required environment variables: {', '.join(missing_vars)}")

    try:
        return boto3.client(
            'bedrock-agent-runtime',
            region_name=os.environ["REGION"],
            aws_access_key_id=os.environ["BAWS_ACCESS_KEY_ID"],
            aws_secret_access_key=os.environ["BAWS_SECRET_ACCESS_KEY"]
        )

    except (BotoCoreError, ClientError) as e:
        logger.error(f"Failed to create Bedrock client: {str(e)}")
        raise

async def retrieve_context(client: boto3.client, query: str, knowledge_base_id: str, n: int = 8
) -> RetrievalResult:
    """
    Retrieves context from the knowledge base using the provided query.

    Args:
        client (boto3.client): Bedrock client.
        query (str): The query to search for.
        knowledge_base_id (str): ID of the knowledge base to search in.
        n (int): Number of results to retrieve. Defaults to 5.

    Returns:
        RetrievalResult: A dictionary containing the retrieved context, RAG status, and sources.
    """
    if not knowledge_base_id:
        logger.warning("knowledgeBaseId is not provided")
        return RetrievalResult(context="", is_rag_working=False, rag_sources=[])

    try:
        response = client.retrieve(
            knowledgeBaseId=knowledge_base_id,
            retrievalQuery={'text': query},
            retrievalConfiguration={
                'vectorSearchConfiguration': {'numberOfResults': n}
            }
        )
        return parse_retrieval_response(response)
    except Exception as error:
        logger.error(f"RAG Error: {error}")
        return RetrievalResult(context="", is_rag_working=False, rag_sources=[])

def parse_retrieval_response(response: Dict[str, Any]) -> RetrievalResult:
    """
    Parses the retrieval response from Bedrock.

    Args:
        response (Dict[str, Any]): The raw response from Bedrock's retrieve API.

    Returns:
        RetrievalResult: Parsed retrieval result.
    """
    raw_results = response.get('retrievalResults', [])
    rag_sources = []
    context_parts = []

    for index, result in enumerate(raw_results):
        if result.get('content') and result['content'].get('text'):
            uri = result.get('location', {}).get('s3Location', {}).get('uri', '')
            file_name = uri.split('/')[-1] if uri else f'Source-{index}.txt'

            rag_source = RAGSource(
                id=result.get('metadata', {}).get('x-amz-bedrock-kb-chunk-id', f'chunk-{index}'),
                file_name=file_name.replace('_', ' ').replace('.txt', ''),
                snippet=result['content']['text'],
                score=result.get('score', 0)
            )
            rag_sources.append(rag_source)
            context_parts.append(result['content']['text'])

    context = "\n\n".join(context_parts)
    logger.info(f"🔍 Parsed {len(rag_sources)} RAG Sources")

    return RetrievalResult(
        context=context,
        is_rag_working=True,
        rag_sources=rag_sources
    )

async def async_handler(event:Dict[str, Any]) -> Dict[str, Any]:
    """
    Asynchronous handler function to process the retrival request.
    """
    try:
        query = event['body']
        knowledge_base_id = os.environ['KNOWLEDGE_BASE_ID']
    except KeyError as error:
        logger.error(f"Missing required request body: {str(error)}")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing required request body"}),
            "headers": {
                "Content-Type": "application/json",
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://www.typingmind.com',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            }
        }

    try:
        bedrock_client = get_bedrock_client()
        result = await retrieve_context(bedrock_client, query, knowledge_base_id)

        if result['is_rag_working']:
            logger.info(f"Context retrieved successfully")
            logger.info(f"Context: {result['context'][:100]}...")  # Logs first 100 characters
            logger.info("RAG Sources:")
            for source in result["rag_sources"]:
                logger.info(f"- {source.file_name}: {source.snippet[:200]}...")

            # Prepare response
            response_body = {
                "is_rag_working": result["is_rag_working"],
                "context": result["context"],
                "rag_sources": [source.__dict__ for source in result["rag_sources"]]
             }
            return {
                "statusCode": 200,
                "body":json.dumps(response_body),
                "headers": {
                    "Content-Type": "application/json",
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Origin': 'https://www.typingmind.com',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                }
            }
        else:
            logger.warning(f"Failed to retrieve context")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Failed to retrieve context"}),
                "headers": {
                    "Content-Type": "application/json",
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Origin': 'https://www.typingmind.com',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                }
            }
    except Exception as error:
        logger.error(f"An error occurred: {str(error)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"An internal error occurred: {str(error)}"}),
            "headers": {
                "Content-Type": "application/json",
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://www.typingmind.com',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            }
        }
    
def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main handler function that wraps the async_handler.
    """
    return asyncio.run(async_handler(event))

