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
function CreateKeys { 
    param (
        $credential
    ) 

    # Establish the name of the key files for the username and password.
    $outUser = ".\" + $credential + "User.key"
    $outPass = ".\" + $credential + "Pass.key"

    # Create the key files for the username and password.
    # The key files are generated using a cryptographic random number generator.
    $EncryptionKeyBytes = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($EncryptionKeyBytes)
    $EncryptionKeyBytes | Out-File $outUser

    $EncryptionKeyBytes = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($EncryptionKeyBytes)
    $EncryptionKeyBytes | Out-File $outPass

}

# This function encrypts a given string using AES encryption with a specified key.
# It returns the encrypted string in Base64 format and stores it in a file.
function EncryptCredential {
    param (
        $sStringUser,
        $sStringPass,
        $credential
    ) 

    # Establish the name of the key files for the username and password.
    $inUser = ".\" + $credential + "User.key"
    $inPass = ".\" + $credential + "Pass.key"

    # Establish the name of the encrypted files for the username and password.
    $outUser = ".\" + $credential + "User.enc"
    $outPass = ".\" + $credential + "Pass.enc"

    # Encrypt the username and password using the keys stored in the key files.
    # The encrypted strings are saved to files in Base64 format.
    $EncryptionKeyData = Get-Content $inUser
    $sStringUser | ConvertFrom-SecureString -Key $EncryptionKeyData | Out-File -FilePath $outUser

    $EncryptionKeyData = Get-Content $inPass
    $sStringPass | ConvertFrom-SecureString -Key $EncryptionKeyData | Out-File -FilePath $outPass
    
}

# Select which type of credentials to encrypt
# Should you need another option, just add them to the switch statement and create a new key file for it.
Write-Host "`nWhich credentials do you want to encrypt?"
Write-Host "	1. Read-Only		"
Write-Host "	2. Administrator	"
Write-Host -BackgroundColor Black -ForegroundColor Red "	q. Quit	"
$credential = read-host "`nCredential to encrypt"

switch ($credential) {	#Which credential to encrypt
	1 {
		$credential = "Read"
	}
	2 {
		$credential = "Admin"
	}
	q {
		break
	}
	default { 
		Write-Host -BackgroundColor Black -ForegroundColor Red "Invalid Option!"
		break 
	}
}

# Here we create the key files for the username and password.
CreateKeys $credential

# The key files are created in the current directory.
$path = (Get-Location).Path
$keyFileUser = $credential + "User.key"
$keyFilePass = $credential + "Pass.key"

Write-Host "`nThe key files to encrypt the Username and Password were created. "
Write-Host "$path\$keyFileUser" -NoNewline -ForegroundColor Green
Write-Host " and " -NoNewline
Write-Host "$path\$keyFilePass" -ForegroundColor Green

# Prompt the user for the username and password to encrypt.
# The password is stored as a secure string to ensure its confidentiality.
$user = Read-Host -Prompt "`nEnter Username"
$sStringUser = ConvertTo-SecureString $user -AsPlainText -Force
$sStringPass = Read-Host -AsSecureString -Prompt "Enter Password"

# The username and password are encrypted using the keys stored in the key files.
EncryptCredential $sStringUser $sStringPass $credential

# The encrypted files are created with these names.
$encFileUser = $credential + "User.enc"
$encFilePass = $credential + "Pass.enc"

Write-Host "`nThe encrypted files for the Username and Password were created. "
Write-Host "$path\$encFileUser" -NoNewline -ForegroundColor Green
Write-Host " and " -NoNewline
Write-Host "$path\$encFilePass" -ForegroundColor Green
