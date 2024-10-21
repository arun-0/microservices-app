#!/bin/bash

# Function to check if a secret exists and contains a value
check_secret_value_exists() {
  secret_id=$1

  if aws secretsmanager get-secret-value --secret-id "$secret_id" >/dev/null 2>&1; then
    echo "Secret $secret_id already exists with a value."
    return 0
  else
    echo "Secret $secret_id does not exist or has no value."
    return 1
  fi
}

# Check if the Kafka Truststore secret exists and has a value
if check_secret_value_exists "kafka-truststore"; then
  echo "Kafka truststore already exists. Skipping download and creation."
  exit 0
fi

# Fetch Kafka Broker Endpoints from AWS Secrets Manager or Terraform output
KAFKA_BROKER_ENDPOINT=$(aws secretsmanager get-secret-value --secret-id kafka_broker_endpoints --query 'SecretString' --output text)

# Alternatively, if using Terraform output, replace the above with:
# KAFKA_BROKER_ENDPOINT=$(terraform output -raw kafka_broker_endpoints)

# Extract the first broker endpoint from the comma-separated list
FIRST_BROKER=$(echo $KAFKA_BROKER_ENDPOINT | cut -d',' -f1)

# Download Kafka certificate from the first broker
echo "Downloading Kafka PEM from $FIRST_BROKER..."
openssl s_client -showcerts -connect $FIRST_BROKER </dev/null 2>/dev/null | openssl x509 -outform PEM > kafka.pem

# Convert PEM to JKS truststore
echo "Converting PEM to Truststore..."
keytool -import -alias kafka -file kafka.pem -keystore kafka.truststore.jks -storepass $TRUSTSTORE_PASSWORD -noprompt

# Upload truststore and PEM to AWS Secrets Manager
echo "Uploading truststore and PEM to AWS Secrets Manager..."
aws secretsmanager update-secret --name kafka-truststore --secret-binary fileb://kafka.truststore.jks --description "Kafka Truststore"
aws secretsmanager update-secret --name kafka-pem --secret-binary fileb://kafka.pem --description "Kafka PEM"
aws secretsmanager update-secret --name truststore-password --secret-string "$TRUSTSTORE_PASSWORD" --description "Truststore Password"
