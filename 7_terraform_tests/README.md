# Testing Terraform Code

## Installing Go in WSL Ubuntu
+ [Install](https://golang.org/doc/install) go binary for Linux.
+ Configure `$PATH` variable. Edit `~/.profile` to include the below code.
```bash
# set PATH so it includes go binary if it exists
if [ -d "/usr/local/go" ] ; then
    PATH="/usr/local/go/bin:$HOME/go:$PATH"
fi
```
+ Run `source ~/.profile`.
+ Run `go version` to check if installation was successful.

## Example code serves 3 purposes
+ Executable documentation.
+ A way to run manual tests for modules.
+ A way to run automated tests for modules.

## Using Terratest
### Setting up the `tests` folder
```bash
go mod init <github>/<username>/<repo>/<folder-optional>
go mod vendor # downloads the modules to vendor folder
```

### Write the test file
+ Use `<module>_<example>_test.go` name to create a file.
+ Import the required modules and write the test.
+ Run `go test -v -timeout 30m`. 30m to make sure resources get created (override default Go execution timeout of 10m).

## Tips to handle external dependencies
+ Create a separate file `dependencies.tf` so that users are aware of what are the external dependencies for the module.
+ Allow variable inputs to set these values with a `default = null` parameter. In resource definition have conditional check for `null` to decide whether query the external source for the data, or use the provided values.
+ Put the queried/provided values in a `locals` block (again using a conditional check for presence of `null`). Reference the local values in the module.

## Tips to handle a hard-coded remote backend
+ Use a partial configuration for the S3 remote state backend.
    + Leave the backend configuration empty in `main.tf`.
    + Create a `backend.hcl` file with the configuration values.
    + Use `terraform init -backend-config=backend.hcl` when deploying.
    + Pass in backend configuration values in your test as required.
+ TODO: Figure out how to cleanup the S3 test folder after running tests.