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

package templates.gcp.GCPEnforceNamingConstraintV1

import data.validator.gcp.lib as lib

###########################
# Find Whitelist Violations
###########################
deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset
	naming_rules := lib.get_default(params, "naming_rules", [])
	count(naming_rules) > 0 # make sure that we have some rules to validate

	patterns := check_asset_and_return_its_rules(asset.asset_type, naming_rules)
	name := get_only_asset_name(asset.name)
	no_name_match(name, patterns)
	trace(sprintf("no match name:%v, patterns:%v", [name, patterns]))

	message := sprintf("%v does not obey the naming convention. Full address: %v", [name, asset.name])
	ancestry_path = lib.get_default(asset, "ancestry_path", "")
	metadata := {
		"asset_name": name,
		"asset_full_address": asset.name,
		"patterns": patterns,
		"ancestry_path": ancestry_path,
	}
}

get_only_asset_name(asset_full_name) = name {
	# we are interested in the last part of the name,
	# the rest is resource address
	split_name := split(asset_full_name, "/")
	last_index := count(split_name) - 1
	name := split_name[last_index]
}

check_asset_and_return_its_rules(asset_type, naming_rules) = patterns {
	rule = naming_rules[_]
	rule.resource == asset_type
	patterns = rule.patterns
}

no_name_match(asset_name, patterns) {
	not match_name(asset_name, patterns)
}

match_name(name, patterns) {
	re_match(patterns[_], name)
}
