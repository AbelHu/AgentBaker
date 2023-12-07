powershell.exe -ExecutionPolicy Unrestricted -command \"
$arguments = '
-MasterIP ''{{ GetKubernetesEndpoint }}''
-KubeDnsServiceIp ''{{ GetParameter "kubeDNSServiceIP" }}''
-MasterFQDNPrefix ''{{ GetParameter "masterEndpointDNSNamePrefix" }}''
-Location ''{{ GetVariable "location" }}''
{{if UserAssignedIDEnabled}}
-UserAssignedClientID ''{{ GetVariable "userAssignedIdentityID" }}''
{{ end }}
-TargetEnvironment ''{{ GetTargetEnvironment }}''
-AgentKey ''{{ GetParameter "clientPrivateKey" }}''
-AADClientId ''{{ GetParameter "servicePrincipalClientId" }}''
-AADClientSecret ''{{ GetParameter "encodedServicePrincipalClientSecret" }}''
-NetworkAPIVersion 2018-08-01
-LogFile %SYSTEMDRIVE%\AzureData\CustomDataSetupScript.log
-CSEResultFilePath %SYSTEMDRIVE%\AzureData\CSEResult.log';
$inputFile = '%SYSTEMDRIVE%\AzureData\CustomData.bin';
$outputFile = '%SYSTEMDRIVE%\AzureData\CustomDataSetupScript.ps1';
if (!(Test-Path $inputFile)) { echo 'AKS Windows CSE ExitCode: 49 (WINDOWS_CSE_ERROR_NO_CUSTOM_DATA_BIN), ErrorMessage: %SYSTEMDRIVE%\AzureData\CustomData.bin does not exist.' | Out-File -FilePath '%SYSTEMDRIVE%\AzureData\CSEResult.log' -Encoding utf8; exit; };
Copy-Item $inputFile $outputFile;
Invoke-Expression('{0} {1}' -f $outputFile, $arguments);
\" >> %SYSTEMDRIVE%\AzureData\CustomDataSetupScript.log 2>&1; if (!(Test-Path %SYSTEMDRIVE%\AzureData\CSEResult.log)) { throw 'AKS Windows CSE ExitCode: 50 (WINDOWS_CSE_ERROR_NO_CSE_RESULT_LOG), ErrorMessage: %SYSTEMDRIVE%\AzureData\CSEResult.log does not exist.'; }; $code=(Get-Content %SYSTEMDRIVE%\AzureData\CSEResult.log); if ($code -ne '0') { throw $code; };