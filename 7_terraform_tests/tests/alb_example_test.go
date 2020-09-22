package test

import (
	"fmt"
	"time"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	"testing"
)

func TestAlbExample(t *testing.T) {
	opts := &terraform.Options{
		// relative path to module example
		TerraformDir: "../examples/alb",

		Vars:map[string]interface{}{
			"cluster_name": fmt.Sprintf("test-%s", random.UniqueId()),
		},
	}	

	// clean up after running test
	defer terraform.Destroy(t, opts)

	// deploy the example
	terraform.InitAndApply(t, opts)

	// get the DNS of the ALB
	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	// test that default status 404 is returned
	expectedStatus := 404
	expectedBody := "404: page not found"

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(
		t,
		url,
		nil, // setting tlsConfig argument to nil
		expectedStatus,
		expectedBody,
		maxRetries,
		timeBetweenRetries,
	)
}
