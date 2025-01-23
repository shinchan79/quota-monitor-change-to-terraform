resource "random_uuid" "helper_uuid" {}

resource "null_resource" "launch_data" {
  triggers = {
    uuid = random_uuid.helper_uuid.result
  }
}


    # "QMHelperCreateUUIDE0D423E6": {
    #   "Type": "Custom::CreateUUID",
    #   "Properties": {
    #     "ServiceToken": {
    #       "Fn::GetAtt": [
    #         "QMHelperQMHelperProviderframeworkonEventB1DF6D3F",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/CreateUUID/Default"
    #   }
    # },
    # "QMHelperLaunchData6F23B2C3": {
    #   "Type": "Custom::LaunchData",
    #   "Properties": {
    #     "ServiceToken": {
    #       "Fn::GetAtt": [
    #         "QMHelperQMHelperProviderframeworkonEventB1DF6D3F",
    #         "Arn"
    #       ]
    #     },
    #     "SOLUTION_UUID": {
    #       "Fn::GetAtt": [
    #         "QMHelperCreateUUIDE0D423E6",
    #         "UUID"
    #       ]
    #     }
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/LaunchData/Default"
    #   }
    # },