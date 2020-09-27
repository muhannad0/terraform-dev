package test

import (
	"fmt"
	"time"
	"strings"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"testing"
)

const dbDirStage = "../live/stage/data-stores/mysql"
const appDirStage = "../live/stage/services/hello-world-app"

func TestHelloWorldAppStage(t *testing.T) {
	t.Parallel()
	
	// Deploy the MySQL DB
	dbOpts := createDbOpts(t, dbDirStage)
	defer terraform.Destroy(t, dbOpts)
	terraform.InitAndApply(t, dbOpts)

	// Deploy the hello-world-app
	helloOpts := createHelloOpts(dbOpts, appDirStage)
	defer terraform.Destroy(t, helloOpts)
	terraform.InitAndApply(t, helloOpts)

	// Validate that hello-world-app works
	validateHelloApp(t, helloOpts)
}

func createDbOpts(t *testing.T, terraformDir string) *terraform.Options {
	uniqueId := random.UniqueId()

	bucketForTesting := "bucket-with-some-data-files"
	bucketRegionsForTesting := "us-east-1"
	dbStateKey := fmt.Sprintf("%s%s/terraform.tfstate", t.Name(), uniqueId)

	return &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"db_name": fmt.Sprintf("test%s", uniqueId),
			"db_username": "admin",
		},

		BackendConfig: map[string]interface{}{
			"bucket": bucketForTesting,
			"region": bucketRegionsForTesting,
			"key": dbStateKey,
			"encrypt": true,
		},
	}
}

func createHelloOpts(
	dbOpts *terraform.Options, terraformDir string) *terraform.Options {
	
	return &terraform.Options{
		TerraformDir: terraformDir,

		Vars:map[string]interface{}{
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key": dbOpts.BackendConfig["key"],
			"environment": dbOpts.Vars["db_name"],
		},

		// handling known errors like timeouts
		MaxRetries: 3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
	}
}

func validateHelloApp(t *testing.T, helloOpts *terraform.Options) {
	albDnsName := terraform.OutputRequired(t, helloOpts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 &&
				strings.Contains(body, "Hello World Stage")
		},
	)
}

func TestHelloWorldAppStageWithStages(t *testing.T) {
	t.Parallel()

	stage := test_structure.RunTestStage

	// deploy MySQL DB
	defer stage(t, "teardown_db", func() { tearDownDb(t, dbDirStage) })
	stage(t, "deploy_db", func() { deployDb(t, dbDirStage) })

	// deploy Hello World App
	defer stage(t, "teardown_app", func() { tearDownApp(t, appDirStage) })
	stage(t, "deploy_app", func() { deployApp(t, dbDirStage, appDirStage) })

	// validate whether Hello World App works
	stage(t, "validate_app", func() { validateApp(t, appDirStage) })

	// redeploy Hello World App
	stage(t, "redeploy_app", func() { redeployApp(t, appDirStage) })
}

func deployDb(t *testing.T, dbDir string) {
	dbOpts := createDbOpts(t, dbDir)

	//save data to disk so that other test stages can read data later
	test_structure.SaveTerraformOptions(t, dbDir, dbOpts)

	terraform.InitAndApply(t, dbOpts)
}

func tearDownDb(t *testing.T, dbDir string) {
	// load options data matching this test stage and then run Terraform
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	defer terraform.Destroy(t, dbOpts)
}

func deployApp(t *testing.T, dbDir string, helloAppDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	helloOpts := createHelloOpts(dbOpts, helloAppDir)

	test_structure.SaveTerraformOptions(t, helloAppDir, helloOpts)

	terraform.InitAndApply(t, helloOpts)
}

// func redeployApp(t *testing.T, helloAppDir string) {
// 	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)
// 	terraform.InitAndApply(t, helloOpts)
// }

func tearDownApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)
	defer terraform.Destroy(t, helloOpts)
}

func validateApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)

	validateHelloApp(t, helloOpts)
}

func redeployApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)

	albDnsName := terraform.OutputRequired(t, helloOpts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	// start checking whether the app is responding with 200 OK every 1s
	stopChecking := make(chan bool, 1)
	waitGroup, _ := http_helper.ContinuouslyCheckUrl(
		t,
		url,
		stopChecking,
		1*time.Second,
	)

	// update the server text and redploy
	newServerText := "Hello World New Text"
	helloOpts.Vars["server_text"] = newServerText
	terraform.Apply(t, helloOpts)

	// make sure the new versino is deployed
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, newServerText)
		},
	)

	// stop checking
	stopChecking <- true
	waitGroup.Wait()
}