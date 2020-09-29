# Team Workflow for Terraform Code

## General App Code Workflow
+ Check out/fork the main repo. `git clone`
+ Create a new feature branch. `git checkout -b branch-name`
+ Make changes. Test locally. Commit changes. `git commit`
+ Submit changes for review. Create a pul request (Github). `git push origin branch-name`
+ Run automated tests. Use commit hooks or branch identifiers to run specific tests.
+ Review code changes and merge to main branch after verifying.
+ Create a release. Example Docker image, tar file. Always tag with a unique identifier.
    + Some examples of creating a release:
    ```bash
    # Using commit IDs. Drawback: difficult to read or remember.
    git commit -m "update code"
    commit_id=$(git rev-parse HEAD)
    docker build -t username/app-code:$commit_id .

    # Using Git tags.
    git tag -a "v0.0.4" -m "update code"
    git push --follow tags

    git_tag=$(git describe --tags)
    docker build -t username/app-code:$git_tag .
    ```
+ Deploy the artifact.
    + Deployment tooling
        + Terraform
        + Ochestration platforms (eg: for containers => Kubernetes/ECS/etc)
        + Scripts (eg: configuration management tools Ansible/Chef/etc)
    + Deployment strategies
        + Rolling deployment with replacement
            + old vesion taken down, new version deployed, pass health check and direct live traffic to new version.
        + Rolling deployment without replacement.
            + new version deployed, pass health check and direct live traffic to new version and old version. old versions taken down following the same steps.
        + Blue-green deployment.
            + new version deployed at full capacity, pass health check and direct live traffic, remove old versions.
        + Canary deployment.
            + new version deployed, pass health check and direct live traffic, pause deployment, compare with defined metrics, based on collected stats, can proceed to ramp up deployment or perform rollback. can also use in-built feature toggles to enable/disable features for groups of users.
    + Deployment server
        + Fully automated
        + Consistent environment
        + Better permissions management
    + Promote artifacts acrosss environments.
        + Use the same artifact across Dev, Stage and Prod environments.
            + Run manual and automated tests in each environmet before before proceeding to the next one.
        + Rollback to previous versions if any issues in any of the environments.

## Terraform Code Workflow
+ Use version control
    + Live repo
        + Actual live environments code.
    + Modules repo
        + Resuable and versioned modules.
        + Create a consumable library of modules that meet production-grade checklist.
        + Provide configurable options (exposed using *variables*), documentation (*examples* folder) and automated tests.
+ **Golden Rule:** Main branch of *live* repo **should be a 1:1 match of what is actually deployed** in production.
    + `terraform plan` should show no changes (except when it's time to deploy changes).
        + Never make out-of-band changes once you start using Terraform.
    + Workspaces does not represent the number of resources actually deployed.
        + Use separate environment folders and files.
    + Main branch should always be the source for all Terraform actions (plan, apply).
        + Do not deploy from working branches.
+ Make the code changes and run the tests locally, against a sandbox environment, for manual and automated testing.
+ Submit changes for review. Use clear guidelines.
    + Documentation.
        + Written documentation.
        + Code documentation, use of descriptions.
        + Example code.
    + Include automated tests.
    + Use File isolation layout for different environments.
    + Style guide.
        + Strive for a consistent style.
+ Run automated tests.
    + Have commit hooks that initiate tests automatically on CI server.
    + Always run plan before apply.
+ Merge and release.
    + Use tags to create a release of the code.
+ Deploy the code.
    + Deployment tooling
        + Atlantis, Terraform Enterprise, Terragrunt, Scripts
    + Deployment strategies
        + Use retries to handle known errors.
        + Handle state errors (*errored.tfstate*).
        + Error releasing locks (*terraform force-unlick <lock_id>)*
    + Deployment server
        + Run CI server in private subnets. Poll for changes.
        + Lock down the CI server.
        + Give fixed set of permissions to deploy the infrastructure. Temporary credentials.

## Use of TerraGrunt
+ [TerraGrunt]()
+ Define common configurations such as provider, partial backend in modules.
+ Use single `terragrunt.hcl` files to pass in configuration parameters per environment.
    + Results in reduced number of duplicated code and file.
    + Keeps configurations DRY.