package test 

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	"testing"
)

func TestMySqlExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/mysql",
		Vars: map[string]interface{}{
			"db_name": fmt.Sprintf("test_%s", random.UniqueId()),
			"db_username": fmt.Sprintf("user_%s", random.UniqueId()),
			"db_password": "test_password",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}