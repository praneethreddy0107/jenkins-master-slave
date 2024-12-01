#!/bin/bash

LOG_FILE="terraform_$(date +%F_%T).log"

echo "Initializing Terraform..." | tee -a $LOG_FILE
if ! terraform init 2>&1 | tee -a $LOG_FILE; then
  echo "Error during init. Exiting..." | tee -a $LOG_FILE
  exit 1
fi

echo "Planning Terraform..." | tee -a $LOG_FILE
if ! terraform plan -out=tfplan 2>&1 | tee -a $LOG_FILE; then
  echo "Error during plan. Exiting..." | tee -a $LOG_FILE
  exit 1
fi

echo "Applying Terraform..." | tee -a $LOG_FILE
if ! terraform apply tfplan 2>&1 | tee -a $LOG_FILE; then
  echo "Error during apply. Exiting..." | tee -a $LOG_FILE
  exit 1
fi

echo "Terraform process completed successfully." | tee -a $LOG_FILE
