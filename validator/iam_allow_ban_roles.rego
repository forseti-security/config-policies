#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package templates.gcp.GCPIAMAllowBanRolesConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset

	binding := asset.iam_policy.bindings[_]
	role := binding.role

	matches_found = {r | r := role; glob.match(params.roles[_], ["/"], r)}

	mode := lib.get_default(params, "mode", "allow")

	desired_count := target_match_count(mode)
	count(matches_found) != desired_count

	message := output_msg(desired_count, asset.name, role)
	ancestry_path = lib.get_default(asset, "ancestry_path", "")
	metadata := {
		"resource": asset.name,
		"role": role,
		"ancestry_path": ancestry_path,
	}
}

###########################
# Rule Utilities
###########################

# Determine the overlap between matches under test and constraint
target_match_count(mode) = 0 {
	mode == "ban"
}

target_match_count(mode) = 1 {
	mode == "allow"
}

# Output message based on type of violation
output_msg(0, asset_name, role) = msg {
	msg := sprintf("%v is in the banned list of IAM policy for %v", [role, asset_name])
}

output_msg(1, asset_name, role) = msg {
	msg := sprintf("%v is NOT in the allowed list of IAM policy for %v", [role, asset_name])
}

#ENDINLINE
