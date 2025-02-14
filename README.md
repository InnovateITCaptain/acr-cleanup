# Azure Container Registry (ACR) Cleanup Script

## Overview
This PowerShell script is designed to check and untag outdated Docker images from an Azure Container Registry (ACR). It helps in keeping the repository clean by removing surplus images based on a retention policy.

> **WARNING:** This script will delete all image tags within a repository that share the same manifest. Ensure you understand its impact before executing.

## Purpose
- Automates the cleanup of old container images in an ACR repository.
- Helps in maintaining a manageable number of images per repository.
- Provides an option to run in simulation mode before performing actual deletions.

## How It Works
1. Logs into Azure and sets the appropriate subscription.
2. Retrieves a list of repositories within the specified ACR.
3. Determines which images to keep based on the retention settings.
4. Identifies images older than the defined threshold.
5. If enabled, untag surplus images or runs in dry-run mode to simulate actions.

## Parameters

| Parameter         | Description |
|------------------|-------------|
| **AzureRegistryName** | The name of the Azure Container Registry (ACR). This must be set before running the script. |
| **SubscriptionName** | The Azure subscription in which the ACR is located. This must be set before running the script. |
| **ImagestoKeep** | Number of the most recent images to retain per repository (default: 5). |
| **NumberOfDaysToKeep** | Number of days beyond which old images will be considered for removal (default: 30 days). |
| **EnableUntag** | If set to `yes`, images will be untagged. If set to `no`, the script will run in a dry-run mode, displaying what would be untagged without making actual changes. |
| **Repository** | Specific repository to clean up. If set to `all`, it will clean all repositories in the ACR. |

## Setup Instructions
1. **Ensure Azure CLI is installed and logged in:**
   ```sh
   az login
   ```
2. **Set values for required parameters:**
   - Replace `<ACR_NAME>` with your Azure Container Registry name.
   - Replace `<SUBSCRIPTION_NAME>` with the relevant Azure subscription name.
3. **Run the script in dry-run mode (default setting):**
   ```powershell
   .\acr-cleanup.ps1 -AzureRegistryName "myACR" -SubscriptionName "MySubscription"
   ```
4. **Run the script to actually untag images:**
   ```powershell
   .\acr-cleanup.ps1 -AzureRegistryName "myACR" -SubscriptionName "MySubscription" -EnableUntag "yes"
   ```

## Example Use Cases
- **Remove old images but keep the last 10 images:**
  ```powershell
  .\acr-cleanup.ps1 -AzureRegistryName "myACR" -SubscriptionName "MySubscription" -ImagestoKeep 10
  ```
- **Remove images older than 60 days while keeping the last 5 images:**
  ```powershell
  .\acr-cleanup.ps1 -AzureRegistryName "myACR" -SubscriptionName "MySubscription" -NumberOfDaysToKeep 60
  ```
- **Cleanup only a specific repository instead of all repositories:**
  ```powershell
  .\acr-cleanup.ps1 -AzureRegistryName "myACR" -SubscriptionName "MySubscription" -Repository "my-repo"
  ```

## Important Notes
- **This script is meant to be used in an Azure Runbook**; ensure values for `AzureRegistryName` and `SubscriptionName` are properly set before running it.
- Running this script with `EnableUntag="yes"` will **permanently remove tags** from images, making them inaccessible via tag references.
- If multiple images share the same manifest, **all their tags will be deleted**, potentially making the image unavailable.

## Additional Resources
- [Azure CLI ACR Documentation](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro)
- [Azure Runbook Documentation](https://docs.microsoft.com/en-us/azure/automation/automation-runbook-gallery)

This script ensures efficient registry management by automatically untagging obsolete images while allowing a dry-run mode for cautious execution.

