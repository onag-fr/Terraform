#######################################################################
## Set variables
#######################################################################
$subscriptionId = Get-AutomationVariable -Name 'SubscriptionId'
$tenantId = Get-AutomationVariable -Name 'TenantId'
$loggingClientID = Get-AutomationVariable -Name 'ClientId'
$loggingSecret = Get-AutomationVariable -Name 'SecretId'
$KVName = Get-AutomationVariable -Name 'KVName'
$KVSecretName = Get-AutomationVariable -Name 'KVSecretName'
$Location = Get-AutomationVariable -Name 'Location'
$RGName = Get-AutomationVariable -Name 'RGName'
$VMName = Get-AutomationVariable -Name 'VMName'
$UserLogin = Get-AutomationVariable -Name 'UserLogin'

#####################################################
## Azure authentication
#####################################################
Try {
    Write-Output ("Starting to authenticate to Azure")
    $secStringPassword = ConvertTo-SecureString $loggingSecret -AsPlainText -Force
    $credObject = New-Object System.Management.Automation.PSCredential ($loggingClientID, $secStringPassword)
    Connect-AzAccount -ServicePrincipal -SubscriptionId $subscriptionId -TenantId $tenantId -Credential $credObject
    Write-Output ("Authentication to Azure is completed")
} Catch {
    Write-Output ("An error occured during the Azure authentication: $($_.Exception.Message)")
}

#####################################################
## Password rotation
#####################################################
#Generate new password and store it to the winsrv001-admin-pwd secret
Try {
    Write-Output ("Generating new password")
    $GeneratePass = -join ((33..63)+(64..93)+(97..125) | Get-Random -count 30 | %{[char]$_}) #See http://www.asciitable.com/ for more details about ASCII
    $SecurePassword = ConvertTo-SecureString $GeneratePass -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $KVName -Name $KVSecretName -SecretValue $SecurePassword
    Write-Output ("The new password is generated and stored in the KV")
} Catch {
    Write-Output ("An error occured during the generation of the password: $($_.Exception.Message)")
}
#Change password of onag-admin on the winsrv001 VM
Try {
    Write-Output ("Changing onag-admin password")
    $credObject = New-Object System.Management.Automation.PSCredential ($UserLogin, $SecurePassword)
    Set-AzVMAccessExtension -ResourceGroupName $RGName -Location $Location -VMName $VMName -Credential (Get-Credential -credential $credObject) -typeHandlerVersion "2.4" -Name "ResetAdminPass"
    Write-Output ("The password of onag-admin has been changed on the winsrv001 VM")
} Catch {
    Write-Output ("An error occured during the change of the onag-admin password: $($_.Exception.Message)")
}

exit
