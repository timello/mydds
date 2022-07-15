#!/bin/bash

AWS_REGION="eu-central-1"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="terraform-tfstate-tiagomello-${AWS_ACCOUNT_ID}-${AWS_REGION}"

aws s3api create-bucket \
    --region "${AWS_REGION}" \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}" \
    --bucket "${BUCKET_NAME}"

aws s3api put-bucket-versioning --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

aws dynamodb create-table \
    --region "${AWS_REGION}" \
    --table-name terraform-tiagomello-${AWS_ACCOUNT_ID}-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

# Create role for automation
aws iam create-role --role-name terraformAutomationRole --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"AWS": "arn:aws:iam::'${AWS_ACCOUNT_ID}':root"},"Action": "sts:AssumeRole"}]}'
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name terraformAutomationRole
