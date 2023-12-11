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
if (!(Test-Path $inputFile)) { echo 'ExitCode: \"49\", Output: \"WINDOWS_CSE_ERROR_NO_CUSTOM_DATA_BIN\", Error: \"%SYSTEMDRIVE%\AzureData\CustomData.bin does not exist.\", ExecDuration: \"0\"' | Out-File -FilePath '%SYSTEMDRIVE%\AzureData\CSEResult.log' -Encoding utf8; exit; };
Copy-Item $inputFile $outputFile;
Invoke-Expression('{0} {1}' -f $outputFile, $arguments);
\" >> %SYSTEMDRIVE%\AzureData\CustomDataSetupScript.log 2>&1; if (!(Test-Path %SYSTEMDRIVE%\AzureData\CSEResult.log)) { echo 'ExitCode: \"50\", Output: \"WINDOWS_CSE_ERROR_NO_CSE_RESULT_LOG\", Error: \"%SYSTEMDRIVE%\AzureData\CSEResult.log does not exist.\", ExecDuration: \"0\"' | Out-File -FilePath '%SYSTEMDRIVE%\AzureData\CSEResult.log' -Encoding utf8; }; $result=(Get-Content %SYSTEMDRIVE%\AzureData\CSEResult.log); $match=(Select-String 'ExitCode: "(\d+)"' -inputobject $result); if ($match) { Write-Error \"$result\"; exit $match.matches.groups[1].value }; throw $result