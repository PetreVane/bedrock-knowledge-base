
output "embedings_model_arn" {
  value = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedings_model}"
}

output "knowledge_base_arn" {
  value = aws_bedrockagent_knowledge_base.knowledge_base_with_pinecone.arn
}