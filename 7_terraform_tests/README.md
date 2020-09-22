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
+ Run `go test -v 30m`. 30m to make sure resources get created (override default Go execution timeout of 10m).