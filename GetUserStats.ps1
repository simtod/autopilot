# Function to map SKU IDs to more descriptive license names
function Get-LicenseNameFromSkuId {
    param (
        [string]$SkuId
    )

    switch ($SkuId) {
        '05e9a617-0261-4cee-bb44-138d3ef5d965' { 'Microsoft 365 E3' }
        '18181a46-0d4e-45cd-891e-60aabd171b4e' { 'Office 365 E1' }
        '4ef96642-f096-40de-a3e9-d83fb2f90211' { 'Microsoft Defender for Office 365 (Plan 1)' }
        '3b555118-da6a-4418-894f-7df1e2096870' { 'To-Do (Plan 1)' }
        '2e3c4023-80f6-4711-aa5d-29e0ecb46835' { 'Dynamics 365 for Team Members' }
        '53818b1b-4a27-454b-8896-0dba576410e6' { 'Project Online Professional' }
        'f30db892-07e9-47e9-837c-80727f46fd3d' { 'Microsoft Flow Free' }
        'a403ebcc-fae0-4ca2-8c8c-7a907fd6c235' { 'Power BI Free' }
        'cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46' { 'Microsoft 365 Business Premium' }
        'f991cecc-3f91-4cd0-a9a8-bf1c8167e029' { 'Dynamics 365 Business Central Premium' }
        'f8a1db68-be16-40ed-86d5-cb42ce701560' { 'Power BI Pro' }
        '4b9405b0-7788-4568-add1-99614e613b69' { 'Exchange Online (Plan 1)' }
        '710779e8-3d4a-4c88-adb9-386c958d1fdf' { 'Microsoft Teams Exploratory' }
        'c5928f49-12ba-48f7-ada3-0d743a3601d5' { 'Visio Online Plan 2' }
        'dcb1a3ae-b33f-4487-846a-a640262fadf4' { 'Microsoft Power Apps Plan 2 Trial' }
        '1f2f344a-700d-42c9-9427-5cea1d5d7ba6' { 'Microsoft Stream' }
        default { "Unknown SKU ID: $SkuId" }
    }
}

# Connect to Microsoft Graph with necessary permissions
Connect-MgGraph -Scopes 'User.Read.All','AuditLog.Read.All'

# Get user details and export to CSV with UserType column
Get-MgUser -All -Property 'UserPrincipalName','SignInActivity','Mail','DisplayName','UserType','AssignedLicenses' | 
    Select-Object @{N='UserPrincipalName';E={$_.UserPrincipalName}}, 
                  @{N='DisplayName';E={$_.DisplayName}}, 
                  @{N='LastSignInDate';E={$_.SignInActivity.LastSignInDateTime}}, 
                  @{N='Licenses';E={($_.AssignedLicenses | ForEach-Object { Get-LicenseNameFromSkuId $_.SkuId } | Where-Object { $_ }) -join ', '}},
                  @{N='UserType';E={$_.UserType}} | 
    Export-Csv -Path C:\allusers.csv -NoTypeInformation -NoClobber

# Disconnect from Microsoft Graph
Disconnect-MgGraph
