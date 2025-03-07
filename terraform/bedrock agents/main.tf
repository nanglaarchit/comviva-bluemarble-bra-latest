terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.1"
    }
  }
  backend "s3" {}
}

provider "opensearch" {
  url         = "null"
  healthcheck = false
}

provider "aws" {
  region = var.aws_region
}


locals {
  prefix = "${var.namespace}-${var.environment}"
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = "dev"
  project     = "terraform-aws-arc-bedrock"

  extra_tags = {
    Example = "True"
  }
}

module "bedrock" {
  source = "github.com/sourcefuse/terraform-aws-arc-bedrock?ref=feature/bedrock-agent"
  bedrock_agent_config = {
    create              = true
    name                = "${local.prefix}-${var.supervisor_name}"
    foundation_model    = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    instruction         = var.supervisor_instruction
    agent_collaboration = "SUPERVISOR"
    prepare_agent       = false
    description         = "Supervisor Agent"
  }
  agent_collaborator = {
    name                        = "${local.prefix}-${var.agent_name1}"
    collaborator_name           = "SingleRuleGenerationAgent"
    foundation_model            = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    instruction                 = var.instruction_single_rule_generation_agent
    collaboration_instruction   = var.collaboration_instruction_single_rule_generation_agent
    alias_name                  = "AliasforSingleRuleGenerationAgent"
    description                 = "SingleRuleGenerationAgent"
    relay_conversation_history  = "TO_COLLABORATOR"
    prepare_agent               = true
    idle_session_ttl_in_seconds = 600
    action_groups              = local.action_groups
  }
  tags = module.tags.tags
}

# resource "aws_bedrockagent_agent_alias" "single_rule_generation_agent_alias" {
#   agent_alias_name         = "AliasforSingleRuleGenerationAgent"
#   agent_id     = module.bedrock.agent_collaborator["${local.prefix}-${var.agent_name1}"].id
#   description  = "Alias for SingleRuleGenerationAgent"

#   depends_on = [module.bedrock]
# }

module "collaborator_agent_1" {
  source   = "github.com/sourcefuse/terraform-aws-arc-bedrock?ref=feature/bedrock-agent"
  for_each = { for idx, collaborator in local.collaborators : collaborator.name => collaborator }

  agent_collaborator = each.value
  tags               = module.tags.tags
}

data "aws_lambda_function" "existing" {
  function_name = var.function_name
}