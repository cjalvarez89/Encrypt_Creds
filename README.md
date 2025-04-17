# Encrypt_Creds
Encrypt Credentials is designed to encrypt credentials (username and password) using AES encryption. It generates random keys for encryption and saves them to files.

This script is designed to encrypt credentials (username and password) using AES encryption.
It generates random keys for encryption and saves them to files.

The script prompts the user to choose between two sets of credentials (Read-Only or Administrator).
It then collects the username and password from the user, encrypts them, and saves the encrypted data to files.

The script also provides feedback to the user about the location of the generated files.
The script uses PowerShell's built-in cryptography features to perform the encryption.
The encrypted files are saved in the current directory with the specified naming convention.
The script requires appropriate permissions to create files.

The script is intended for use in scenarios where secure storage of credentials is necessary, such as in automation scripts or applications that require authentication.
The script is not intended for use in production environments without proper security measures in place.
The script is provided as-is and should be tested thoroughly before use in any critical systems.
The script is a simple example of how to use PowerShell for credential encryption and should be adapted to meet specific security requirements.
The script is not responsible for any data loss or security breaches that may occur as a result of its use.

Always follow best practices for security and encryption when handling sensitive information.
Use at your own risk.

Usage:
    1. Save the script as EncryptCreds.ps1
    2. Run the script in PowerShell with appropriate permissions.
    3. Follow the prompts to enter the desired credentials and generate encrypted files.
