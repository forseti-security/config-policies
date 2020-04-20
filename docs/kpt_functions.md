# Policy Library KPT Functions
This repo contains several [KPT](https://googlecontainertools.github.io/kpt-functions-sdk/) functions to manage documentation and make it easier to pull in policy for Config Validator.

These functions are meant to be run against this repo. Before running one of the below functions run `kpt get`:

```
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
```

## Get Policy Bundle
Filters the [samples](../samples) in this repo for a given [policy bundle](./index.md).

### Run with Docker
Copy the `forseti-security` bundle to the constriants directory using Docker.

```
kpt fn source policy-library/samples/ | \
  kpt fn run --image gcr.io/config-validator/get_policy_bundle:latest -- bundle=bundles.validator.forsetisecurity.org/forseti-security | \
  kpt fn sink policy-library/policies/constraints/
```

## Generate Docs
Generates markdown documentation for the templates and constraints in this repo. This function is meant to be run by maintainers of the repo to help manage the docs.

### Run with Node
Generate the markdown docs.

```
kpt fn source ./policy-library/samples/ ./policy-library/policies/ | 
node ./policy-library/bundler/dist/generate_docs_run.js -d sink_dir=./policy-library/docs -d overwrite=true
```