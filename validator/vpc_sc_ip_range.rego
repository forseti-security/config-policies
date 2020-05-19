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

package templates.gcp.GCPVPCSCIPRangeConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset

	asset.asset_type == "cloudresourcemanager.googleapis.com/Organization"
	lib.has_field(asset, "access_level")
	conditions := asset.access_level.basic.conditions
	condition := conditions[_]

	count(lib.get_default(condition, "ip_subnetworks", [])) > 0

	lib.get_constraint_params(constraint, params)

	ip_network := condition.ip_subnetworks[_]
	ip_network_parts := split(ip_network, "/")
	ip_network_size := to_number(ip_network_parts[1])

	maximum_size := params.maximum_cidr_size

	maximum_size > ip_network_size

	message := sprintf("IP range %v too broad in acess level %v.", [ip_network, asset.access_level.name])
	ancestry_path = lib.get_default(asset, "ancestry_path", "")
	metadata := {"resource": asset.name, "access_level": asset.access_level.name, "ancestry_path": ancestry_path}
}
