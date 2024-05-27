param (
	[string]$ResourceGroup = "RG1",
	[string]$Location = "Italy North",
	[string]$AppServicePlan = "ASP1",
	[string]$WebAppName = "test2-pwsh-mn2705"
)

try {	
	# Check for Azure context
	$context = Get-AzContext
	if (-no $context) {
		throw "No Azure context found, you will have to log in"
	}
}
catch {
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

try {
	# Checking if Resource Group exists
	$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction Stop
}
catch {
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

Write-Output "Selected Resource Group: $($rg.name)"


try {
	# Checking if App Service Plan exists
	$app_sp = Get-AzAppServicePlan -ResourceGroupName $ResourceGroup `
		-Name $AppServicePlan -ErrorAction Stop
}
catch {
	$create_asp = Read-Host "Selected App Service Plan: $AppServicePlan does not exist, would you like to create it [YES/no]?:"
	
	if ($create_asp -in "no", "n") {
		Write-Output "Stopping..."
		return
	}
	else {
		# Create App Service Plan
		New-AzAppServicePlan -ResourceGroupName $ResourceGroup `
			-Name $AppServicePlan `
			-Location $Location -Tier Free
	}
}

Write-Output "Selected service plan $AppServicePlan"


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