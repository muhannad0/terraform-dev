# Using TF Workspaces to Isolate State

Using workspaces, we can isolate the TF code into different environments (example, quick experiment on code without copying all the code.)

## Commands Used

```bash
terraform workspace show # show current workspace
terraform workspace new example # create new workspace
terraform workspace select default # switch to default workspace
terraform workspace list # show all workspaces
terraform workspace delete example # delete a workspace (switch to default or another workspace first)
```

## Behaviour Notes

+ `env:` folder in backend contains matching workspace folder with tfstate file.
+ Backend state file is deleted when workspace is deleted.