Script

# This script check and untag the old docker images from the azure container registry
# WARNING: this script will delete all image tags within a repository that share the same manifest

[CmdletBinding()]
Param(
    # Define ACR Name
    [String] $AzureRegistryName = "<ACR_NAME>",

    # Define Azure Subscription Name
    [String] $SubscriptionName = "<SUBSCRIPTION_NAME>",
  
    # Number of images to retain per respository
    [Int] $ImagestoKeep = 5,

    # Number of days to keep surplus images per repository
    [Int] $NumberOfDaysToKeep = 30,

    # If set to "yes", images will be untagged. If set to "no", the script will run in simulation mode, 
    # only displaying what would be untagged without making actual changes.
    [String] $EnableUntag = "no",

    # Specify repository to cleanup (if not specified will default to all repositories within the registry)
    [String] $Repository = "all"
)

$imagesDeleted = 0

if ($SubscriptionName) {
    Write-Host "Setting subscription to: $SubscriptionName"
    az account set --subscription $SubscriptionName
}

az acr login --name $AzureRegistryName

if ($Repository -ne "all") {
    $RepoList = @($Repository)
}
else {
    Write-Host "Getting list of all repositories in container registry: $AzureRegistryName"
    $RepoList = (az acr repository list --name $AzureRegistryName | ConvertFrom-Json)
}


foreach ($RepositoryName in $RepoList) {
    write-host ""
    Write-Host "Checking repository: $RepositoryName"
    $RepositoryTags = (az acr repository show-tags --name $AzureRegistryName --repository $RepositoryName --orderby time_desc --detail | ConvertFrom-Json) | Select-Object name, lastUpdateTime
    write-host "Total images:"$RepositoryTags.Count
    write-host "Images to keep:"$ImagestoKeep 
    $oldTags = $RepositoryTags |   Select-Object  -Skip ($ImagestoKeep) | Where-Object { $_.lastUpdateTime -lt (Get-Date).AddDays(-$NumberOfDaysToKeep) }
    write-host "Images to untag (older than $NumberOfDaysToKeep days, except last $ImagestoKeep):"$oldTags.Length
    if ($oldTags.Count -gt 0) {
        write-host "Untagging surplus images..."
        foreach ($item in $oldTags) {
            $ImageName = $RepositoryName + ":" + $item.name
            $imagesDeleted++
            if ($EnableUntag -eq "yes") {
                write-host "untagging:"$ImageName last updated on $item.lastUpdateTime
                az acr repository untag --name $AzureRegistryName --image $ImageName
            }
            else {
                write-host "dummy untag:"$ImageName  last updated on $item.lastUpdateTime
            }
        }
    }
}

write-host ""
Write-Host "ACR cleanup completed"
write-host "Total images untagged:"$imagesDeleted
