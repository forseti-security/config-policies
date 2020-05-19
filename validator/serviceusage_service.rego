#
# Copyright 2018 Google LLC
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

package templates.gcp.GCPServiceUsageConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset
	asset.asset_type == "serviceusage.googleapis.com/Service"

	service_usage := asset.resource.data
	parent := service_usage.parent
	state := service_usage.state
	service := extract_service(service_usage.name)

	mode := lib.get_default(params, "mode", "allow")

	state == "ENABLED"
	matches_found = [m | m = params.services[_]; m == service]
	target_match_count(mode, desired_count)
	count(matches_found) != desired_count

	message := sprintf("%v violates a service constraint", [asset.name])
	ancestry_path = lib.get_default(asset, "ancestry_path", "")
	metadata := {
		"resource": asset.name,
		"mode": mode,
		"service": service,
		"ancestry_path": ancestry_path,
	}
}

###########################
# Rule Utilities
###########################

extract_service(name) = service {
	array := split(name, "/")
	service := array[3]
}

target_match_count(mode) = 0 {
	mode == "deny"
}

target_match_count(mode) = 1 {
	mode == "allow"
}
