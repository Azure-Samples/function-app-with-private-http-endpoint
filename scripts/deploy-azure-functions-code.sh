#!/bin/bash

SUBSCRIPTION_ID=$1
RESOURCE_GROUP_NAME=$2
FUNCTION_APP_NAME=$3

if [[ -z $SUBSCRIPTION_ID ]] || [[ -z $RESOURCE_GROUP_NAME ]] || [[ -z $FUNCTION_APP_NAME ]]
then  
    echo "Parameters missing."
    echo "Usage: deploy-azure-functions-code.sh subscription_id resource_group_name function_app_name"
    echo "Try: deploy-azure-functions-code.sh XXX-XXX-XXX myRG myFunctionApp"
    exit
fi

# Generate random storage account name
STORAGE_ACCOUNT_RANDOM_SUFFIX=$(echo $RANDOM | md5sum | head -c 15)
STORAGE_ACCOUNT_NAME="storage$STORAGE_ACCOUNT_RANDOM_SUFFIX"
STORAGE_CONTAINER_NAME="app-code"

# Pull location from function app
LOCATION=$(az functionapp show --resource-group "$RESOURCE_GROUP_NAME" --name "$FUNCTION_APP_NAME" --query location -o tsv) || exit 1

# Create storage account
echo "Creating storage account . . ."
az storage account create --location "$LOCATION" --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --allow-blob-public-access false --https-only true --kind Storage --sku Standard_GRS || exit 1

# Create a container
az storage container create --name $STORAGE_CONTAINER_NAME --account-name "$STORAGE_ACCOUNT_NAME"

# Assign function app identity to storage account
echo "Creating function app managed identity and assigning to storage account . . ."
export MSYS_NO_PATHCONV=1
az functionapp identity assign \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$FUNCTION_APP_NAME" \
    --role "Storage Blob Data Reader" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

# Sleep for a few seconds to let AAD permissions update.
echo "Sleeping for 30 seconds . . . "
sleep 30
echo "Awake . . . resuming."

# Build code
cd ../src/http-trigger/ || exit

dotnet publish --configuration Release

# zip code
cd ./bin/Release/netcoreapp3.1/publish || exit
zip -r code.zip .

# Copy the zipped file to the http-trigger folder.
cp code.zip ../../../../code.zip

# Change directory back to the http-trigger folder.
cd ../../../.. || exit

# Upload zipped code to storage account
echo "Uploading code to storage account . . . "
az storage blob upload --account-name "$STORAGE_ACCOUNT_NAME" --container $STORAGE_CONTAINER_NAME --file ./code.zip --name code.zip --auth-mode key

# Get URI for uploaded blob -
BLOB_PACKAGE_URI="https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$STORAGE_CONTAINER_NAME/code.zip"

cd ../../scripts || exit

echo "Adding package setting to function app and restarting . . . "
az functionapp config appsettings set --resource-group "$RESOURCE_GROUP_NAME" --name "$FUNCTION_APP_NAME" --settings WEBSITE_RUN_FROM_PACKAGE="$BLOB_PACKAGE_URI"

# May only need to restart if a new package was uploaded.
az functionapp restart --resource-group "$RESOURCE_GROUP_NAME" --name "$FUNCTION_APP_NAME"