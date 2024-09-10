# Define an output variable for the ARN of the embedding model
output "embedings_model_arn" {
  # Construct the ARN using the current AWS partition and region, along with the specified embedding model variable
  value = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedings_model}"
}

# Define an output variable for the ARN of the knowledge base
output "knowledge_base_arn" {
  # Retrieve and output the ARN of the created knowledge base resource
  value = aws_bedrockagent_knowledge_base.knowledge_base_with_pinecone.arn
}

output "knowledge_base_name" {
  # Retrieve and output the ARN of the created knowledge base resource
  value = aws_bedrockagent_knowledge_base.knowledge_base_with_pinecone.name
}