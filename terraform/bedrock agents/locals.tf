data "aws_caller_identity" "current" {}

locals {

  collaborators = [
    {
      name                        = "${local.prefix}-${var.agent_name2}"
      supervisor_agent_id         = module.bedrock.agent_id
      collaborator_name           = "BulkRuleOperationsAgent"
      foundation_model            = "anthropic.claude-3-5-sonnet-20241022-v2:0"
      instruction                 = var.instruction_bulk_rule_operations_agent
      collaboration_instruction   = var.collaboration_instruction_bulk_rule_operations_agent
      alias_name                  = "AliasforBulkRuleOperationsAgent"
      description                 = "BulkRuleOperationsAgent"
      relay_conversation_history  = "TO_COLLABORATOR"
      prepare_agent               = true
      idle_session_ttl_in_seconds = 600
      action_groups               = local.action_group_2
    }
  ]

  action_groups = [{
    name                       = "${local.prefix}_${var.actiongroupname_1}"
    state                      = "ENABLED"
    agent_version              = "DRAFT"
    skip_resource_in_use_check = true
    action_group_executor      = { lambda = {
      name           = data.aws_lambda_function.existing.function_name
      add_permission = true
      } }

    function_schema = [
      {
        functions = [
          {
            name        = "extract_general_props"
            description = "Function to extract the general info properties based on the user prompt.\nWhen the instruction is to create/generate a rule no rule_context is expected.\nIt returns the final general info properties of the rule."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "the user instruction/prompt to create or edit the rule"
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "the existing rule to be updated, if provided along with the prompt, if not properties will be created for a new rule"
                required      = false
              }
            ]
          },
          {
            name        = "extract_static_props"
            description = "Function to extract the static properties based on the user prompt.\nWhen the instruction is to create/generate a rule no rule_context is expected.\nIt returns the final static properties of the rule."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user instruction/prompt to create or edit the rule."
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "the existing rule to be updated, if provided along with the prompt, if not properties will be created for a new rule"
                required      = false
              }
            ]
          },
          {
            name        = "extract_dynamic_props"
            description = "Function to extract the dynamic properties based on the user prompt.\nWhen the instruction is to create/generate a rule no rule_context is expected.\nIt returns the final static properties of the rule."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "the user instruction/prompt to create or edit the rule"
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "the existing rule to be updated, if provided along with the prompt, if not properties will be created for a new rule"
                required      = false
              },
              {
                map_block_key = "static_properties"
                type          = "string"
                description   = "the static properties of the rule definition to utilize the context for generating the dynamic properties"
                required      = true
              }
            ]
          }

        ]
      }
    ]
  }]

  action_group_2 = [{
    name                       = "${local.prefix}-${var.actiongroupname_2}"
    state                      = "ENABLED"
    agent_version              = "DRAFT"
    skip_resource_in_use_check = true
    action_group_executor      = { lambda = {
      name           = data.aws_lambda_function.existing.function_name
      add_permission = true
      } }

    function_schema = [
      {
        functions = [
          {
            name        = "prepare_rule_filter"
            description = "For bulk edit cases prepare_rule_filter accepts the user prompts and returns the rule filter to be used in filtering the rules on which the edits to be performed on."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user prompt in its original form"
                required      = true
              }
            ]
          }
        ]
      }
    ]
  }]
}
