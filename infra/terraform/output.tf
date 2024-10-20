# Output the MSK Kafka broker endpoints
output "kafka_broker_endpoints" {
  # value = aws_msk_cluster.msk_kafka.bootstrap_brokers
  # I think it has TLS enabled by detail
  value = aws_msk_cluster.msk_kafka.bootstrap_brokers_tls
}

# Output the EKS broker endpoints
output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}
