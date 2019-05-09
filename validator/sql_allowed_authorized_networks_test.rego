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

package templates.gcp.GCPSQLAllowedAuthorizedNetworksV1

import data.test.fixtures.constraints as fixture_constraints

# Find all violations of data.test_constraints.
find_violations[violation] {
	# Selecting only the Cloud SQL resources relevant for this test
	resource_list := [test_data |
		fixture_data := data.test.fixtures.assets.cloudsql[_]
		startswith(fixture_data.name, "//cloudsql.googleapis.com/projects/noble-history-87417/instances/authorized-networks")
		test_data := fixture_data
	]

	resource := resource_list[_]
	constraint := data.test_constraints[_]

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

test_sql_allowed_authorized_networks_default {
	constraints := [fixture_constraints.sql_allowed_authorized_networks_default]
	violations := find_violations with data.test_constraints as constraints
	count(violations) == 1

	violation := violations[_]
	violation.details.resource == "//cloudsql.googleapis.com/projects/noble-history-87417/instances/authorized-networks-35"
}

test_sql_allowed_authorized_networks_whitelist {
	constraints := [fixture_constraints.sql_allowed_authorized_networks_whitelist]
	violations := find_violations with data.test_constraints as constraints

	count(violations) == 0
}