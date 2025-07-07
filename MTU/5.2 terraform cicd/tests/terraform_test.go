package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

// TestTerraformCICDDev tests the EXISTING development environment
// This runs after the dev deployment in the CI/CD pipeline
func TestTerraformCICDDev(t *testing.T) {
	// Expected bucket name based on dev environment variables
	expectedBucketName := "terraform-cicd-demo-dev-bucket"
	awsRegion := "us-east-1"

	// Test 1: Verify S3 bucket exists
	t.Run("DevBucketExists", func(t *testing.T) {
		aws.AssertS3BucketExists(t, awsRegion, expectedBucketName)
	})

	// Test 2: Verify bucket has correct tags
	t.Run("DevBucketTags", func(t *testing.T) {
		bucketTags := aws.GetS3BucketTags(t, awsRegion, expectedBucketName)
		assert.Equal(t, "dev", bucketTags["Environment"])
		assert.Equal(t, "terraform-cicd-demo", bucketTags["Project"])
		assert.Equal(t, "CI/CD Demo", bucketTags["Purpose"])
		assert.Equal(t, "Terraform", bucketTags["ManagedBy"])
	})

	// Test 3: Verify bucket name follows naming convention
	t.Run("DevBucketNaming", func(t *testing.T) {
		assert.Contains(t, expectedBucketName, "dev")
		assert.Contains(t, expectedBucketName, "terraform-cicd-demo")
	})
}

// TestTerraformCICDProd tests the EXISTING production environment
// This runs after the prod deployment in the CI/CD pipeline
func TestTerraformCICDProd(t *testing.T) {
	// Expected bucket name based on prod environment variables
	expectedBucketName := "terraform-cicd-demo-prod-bucket"
	awsRegion := "us-east-1"

	// Test 1: Verify S3 bucket exists
	t.Run("ProdBucketExists", func(t *testing.T) {
		aws.AssertS3BucketExists(t, awsRegion, expectedBucketName)
	})

	// Test 2: Verify bucket has correct tags including production-specific ones
	t.Run("ProdBucketTags", func(t *testing.T) {
		bucketTags := aws.GetS3BucketTags(t, awsRegion, expectedBucketName)
		assert.Equal(t, "prod", bucketTags["Environment"])
		assert.Equal(t, "terraform-cicd-demo", bucketTags["Project"])
		assert.Equal(t, "CI/CD Demo", bucketTags["Purpose"])
		assert.Equal(t, "High", bucketTags["Criticality"])
		assert.Equal(t, "Terraform", bucketTags["ManagedBy"])
	})

	// Test 3: Verify bucket has versioning enabled (production feature)
	t.Run("ProdBucketVersioning", func(t *testing.T) {
		versioning := aws.GetS3BucketVersioning(t, awsRegion, expectedBucketName)
		assert.Equal(t, "Enabled", versioning)
	})

	// Test 4: Verify bucket name follows naming convention
	t.Run("ProdBucketNaming", func(t *testing.T) {
		assert.Contains(t, expectedBucketName, "prod")
		assert.Contains(t, expectedBucketName, "terraform-cicd-demo")
	})
}
