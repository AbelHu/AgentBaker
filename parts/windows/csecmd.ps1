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
$outputFile = '%SYSTEMDRIVE%\AzureData\CustomDataSetupScript.ps1';
if (!(Test-Path $inputFile)) { exit 49; };
Copy-Item $inputFile $outputFile;
Invoke-Expression('{0} {1}' -f $outputFile, $arguments);
\"; if (!(Test-Path %SYSTEMDRIVE%\AzureData\CSEResult.log)) { Write-Error 'ErrorCode: \"WINDOWS_CSE_ERROR_NO_CSE_RESULT_LOG\", Error: \"%SYSTEMDRIVE%\AzureData\CSEResult.log does not exist.\"'; exit 50; }; $code=(Get-Content %SYSTEMDRIVE%\AzureData\CSEResult.log); exit $code