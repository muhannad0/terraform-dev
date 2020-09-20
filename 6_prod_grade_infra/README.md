# Building Production-Grade Infrastructure

## Key Points
+ Go through checklist to determine what will be implemented within Terraform code.
+ Start by writing `examples` for modules that you intend to develop (keeping in mind ease of use and flexibility).
+ Then write the `modules` based on the examples that you have made earlier.
+ Finally write `tests` (which could be the same as examples) to make sure your Terraform config works as intended.

## Writing Modules
+ Always pin Terraform and Providers to specific version to ensure compatibility.
+ Aim for writing small modules. This saves time to execute, reduces risk of mistakes and errors.
+ A common pattern is using 2 types of modules:
    + Generic modules
    + Use-case specific modules

### Use tagged releases in version control and Terraform Registry
+ Always refer to modules with a specific release version (`source = git@github:`).
+ Use Terraform Registry to save time and effort, but **verify the module behaviour** before actual use in production.
