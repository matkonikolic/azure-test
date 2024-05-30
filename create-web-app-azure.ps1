param (
	[string]$ResourceGroup = "RG1",
	[string]$Location = "Germany West Central",
	[string]$AppServicePlan = "ASP1",
	[string]$WebAppName = "mn-pwsh-web-app"
)

	
# Check for Azure context
$context = Get-AzContext

if (-not $context) {
	# Connect if no context found
	Write-Output "Log in prompt..."
	Connect-AzAccount
}


$context = Get-AzContext

# Prompt the user for subscription selection
$useCurr = Read-Host "Current subscription: $($context.Subscription.Name) .Would you like to use the current subscription [YES/no]"

if ($useCurr -in "no", "n") {
	# Get available subscriptions
	$subscriptions = Get-AzSubscription

	Write-Output "Available subscriptions:"
	$subscriptions | Select-Object SubscriptionName, SubscriptionId | Format-Table

	$wantedSubId = Read-Host "Enter Id of the subscription you would like to use:"
	Set-AzContext -SubscriptionId $wantedSubId
}
$context = Get-AzContext
Write-Output "Proceeding with subscription $($context.Subscription.Name)"

# Checking if Resource Group exists
$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue

if (-not $rg) {
	# Prompt the user if he would like to create the Resource Group
	$createRg = Read-Host "Resource group: $ResourceGroup does not exist, would you like to create it [YES/no]?"

	if ($createRg -in "no", "n") {
		Write-Output "Stopping the script..."
		return
	}
	else {
		# Create the Resource Group
		Write-Output "Creating Resource Group..."
		New-AzResourceGroup -Name $ResourceGroup -Location $Location
	}
}

Write-Output "Selected Resource Group: $ResourceGroup"

# Does not work properly!
# Prompt the user if he would like to create the App Service Plan
# $app_sp = Get-AzAppServicePlan -ResourceGroupName $ResourceGroup -Name $AppServicePlan -ErrorAction SilentlyContinue

# if (-not $app_sp) {

# 	# Prompt the user if he would like to create the App Service Plan
# 	$create_asp = Read-Host "Selected App Service Plan: $AppServicePlan does not exist. Would you like to create it [YES/no]?"

# 	if ($create_asp -in "no", "n") {
# 		Write-Output "Stopping..."
# 		return
# 	}
# 	else {
# 		# Create App Service Plan
# 		Write-Output "Creating App Service Plan..."
# 		#This command has different location names?
# 		New-AzAppServicePlan -ResourceGroupName $ResourceGroup -Name $AppServicePlan -Location "germanywestcentral" -Tier "Free"
# 	}
# }
# return 
# Write-Output "Selected service plan $AppServicePlan"


try {
	# Creating web app
	Write-Output "Creating web app..."
	New-AzWebApp `
		-ResourceGroupName $ResourceGroup `
		-Name $WebAppName `
		-Location $Location `
		-AppServicePlan $AppServicePlan

	Write-Output "Web app created"
}
catch {
	Write-Output "Failed to create web app"
	# Exit with error
	exit 1
}