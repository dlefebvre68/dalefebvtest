# Ignore SSL Certificate Errors
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Script Details
Write-Output "This script will uninstall your bot from the Cisco DevNet Mantl Sandbox"
Write-Output ""
Write-Output "The details on the Sandbox can be found at:"
Write-Output "    https://devnetsandbox.cisco.com/"
Write-Output "You can access the Sandbox at:"
Write-Output "    https://mantlsandbox.cisco.com"
Write-Output "    user/pass: admin/1vtG@lw@y"
Write-Output ""

# Mantl Info
$control_address = "mantlsandbox.cisco.com"
$mantl_user = "admin"
$mantl_password = ConvertTo-SecureString "1vtG@lw@y" -AsPlainText -Force
$mantl_domain = "app.mantldevnetsandbox.com"
$mantl_credential = New-Object System.Management.Automation.PSCredential ($mantl_user, $mantl_password)


# Retrieving Information
$docker_username = Read-Host -Prompt "What is your Docker Username?"
Write-Output ""
$bot_name = Read-Host -Prompt "What is the name of your bot?"
Write-Output ""
Write-Output ""
Write-Output "Mantl/Marathon application of:"
Write-Output "    $docker_username/$bot_name from https://mantlsandbox.cisco.com/marathon"
Write-Output " will be destroyed."
Write-Output "App details:"
Invoke-RestMethod -Method Get -Uri "https://$control_address`:8080/v2/apps/$docker_username/$bot_name" -ContentType "application/json" -Credential $mantl_credential | ConvertTo-Json

# Confirm Removal
$ANSWER = Read-Host -Prompt "Is this correct?  yes/no"
if ($ANSWER -ne "yes"){
	Write-Output "Exiting without removing anything"
	exit
}

# Uninstall App
Write-Output ""
Write-Output "Uninstalling the bot at $docker_username/$bot_name"
Invoke-RestMethod -Method Delete -Uri "https://$control_address`:8080/v2/apps/$docker_username/$bot_name" -ContentType "application/json" -Credential $mantl_credential
Write-Output ""