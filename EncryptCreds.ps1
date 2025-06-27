<# 
	
	Encrypt Credentials v1
	*by Chris*

    This script is designed to encrypt credentials (username and password) using AES encryption.
    It generates random keys for encryption and saves them to files.
   
    The script prompts the user to choose between two sets of credentials (Read-Only or Administrator).
    It then collects the username and password from the user, encrypts them, and saves the encrypted data to files.

    Always follow best practices for security and encryption when handling sensitive information.
    Use at your own risk.

    Usage:
        1. Save the script as EncryptCreds.ps1
        2. Run the script in PowerShell with appropriate permissions.
        3. Follow the prompts to enter the desired credentials and generate encrypted files.
	
#> 

# This script generates a random 32-byte key for encryption and saves it to a file.
# The key is used to encrypt a password and username, which are also saved to files.

$ErrorActionPreference = "Stop"
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Read", "Admin")]
    [string]$CredentialType,
)

function CreateKeys { 
    param (
	$fullPathUserKey,
 	$fullPathPassKey
    ) 
    
    try {
        # Create the key files for the username and password.
        # The key files are generated using a cryptographic random number generator.
        $EncryptionKeyBytes = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($EncryptionKeyBytes)
        [System.IO.File]::WriteAllBytes($fullPathUserKey, $EncryptionKeyBytes)

        $EncryptionKeyBytes = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($EncryptionKeyBytes)
        [System.IO.File]::WriteAllBytes($fullPathPassKey, $EncryptionKeyBytes)

        #Prints the Path to the key files.
        Write-Host "`nThe key files to encrypt the Username and Password were created. "
        Write-Host "$fullPathUserKey and $fullPathPassKey" -NoNewline -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating key files: $_" -ForegroundColor Red
        exit 1
    }
}

# This function encrypts a given string using AES encryption with a specified key.
# It returns the encrypted string in Base64 format and stores it in a file.
function EncryptCredential {
    param (
        $sStringUser,
        $sStringPass,
	$fullPathUserKey,
 	$fullPathPassKey,
  	$fullPathUserCred,
   	$fullPathPassCred
    )

    try {
        if (!(Test-Path $inUser) -or !(Test-Path $inPass)) {
            throw "Key files not found. Please generate keys first."
        }

        # Encrypt the username and password using the keys stored in the key files.
        # The encrypted strings are saved to files in Base64 format.
        $EncryptionKeyData = [System.IO.File]::ReadAllBytes($fullPathUserKey)
        $sStringUser | ConvertFrom-SecureString -Key $EncryptionKeyData | Out-File -FilePath $fullPathUserCred

        $EncryptionKeyData = [System.IO.File]::ReadAllBytes($fullPathPassKey)
        $sStringPass | ConvertFrom-SecureString -Key $EncryptionKeyData | Out-File -FilePath $fullPathPassCred
    }
     catch {
        Write-Host "Error encrypting credentials: $_" -ForegroundColor Red
        exit 1
    }

}

# Select which type of credentials to encrypt
# Should you need another option, just add them to the switch statement and create a new key file for it.
Write-Host "`nWhich credentials do you want to encrypt?"
Write-Host "	1. Read-Only		"
Write-Host "	2. Administrator	"
Write-Host -BackgroundColor Black -ForegroundColor Red "	q. Quit	"
$credentialInput = read-host "`nCredential to encrypt"

switch ($credentialInput) {	#Which credential to encrypt
	1 { $CredentialType = "Read" }
	2 { $CredentialType = "Admin" }
	q { exit }
	default { 
		Write-Host "Invalid Option!" -BackgroundColor Black -ForegroundColor Red 
		exit 1 
	}
}

# The key files are created in the C:\SecureKeys directory.
$pathKey = 'C:\SecureKeys'
if (!(Test-Path $pathKey)) {
	New-Item -Path $pathKey -ItemType Directory -Force | Out-Null
}
$keyFileUser = $CredentialType + "User.key"
$keyFilePass = $CredentialType + "Pass.key"
$fullPathUserKey = "$pathKey\$keyFileUser"
$fullPathPassKey = "$pathKey\$keyFilePass"

# The encrypted files are created with the current directory.
$pathCred = (Get-Location).Path
$encFileUser = $CredentialType + "User.enc"
$encFilePass = $CredentialType + "Pass.enc"
$fullPathUserCred = "$pathCred\$encFileUser"
$fullPathPassCred = "$pathCred\$encFilePass"

# Here we create the key files for the username and password.
CreateKeys $fullPathUserKey $fullPathPassKey

# Prompt the user for the username and password to encrypt.
# The password is stored as a secure string to ensure its confidentiality.
$user = Read-Host -Prompt "`nEnter Username"
$sStringUser = ConvertTo-SecureString $user -AsPlainText -Force
$sStringPass = Read-Host -AsSecureString -Prompt "Enter Password"

# The username and password are encrypted using the keys stored in the key files.
EncryptCredential $sStringUser $sStringPass $fullPathUserKey $fullPathPassKey $fullPathUserCred $fullPathPassCred

Write-Host "`nThe encrypted files for the Username and Password were created. "
Write-Host "$fullPathUserCred and $fullPathPassCred" -ForegroundColor Green

# Securely clear plaintext password from memory
[System.GC]::Collect()
