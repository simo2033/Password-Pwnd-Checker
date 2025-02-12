# Password-Pwnd-Checker
Powershell script to check password complexity and verify if it's been compromised

This PowerShell script provides a graphical interface for checking password strength and determining if a password has been compromised using the Have I Been Pwned (HIBP) API. It utilizes Windows Forms to allow users to enter a password, click a “Verify” button, and receive feedback on:

• Password Strength Score (based on length, character diversity, etc.)

• Password Strength Category (“Weak”, “Medium”, or “Strong”)

• HIBP Breach Check (whether the password has appeared in known data breaches)



Key Components



1. SHA-1 Hash Calculation (Get-SHA1Hash)



This function computes the SHA-1 hash of the entered password. The HIBP API requires hashed passwords for security reasons. Only the first 5 characters of the hash are sent to HIBP (k-Anonymity model).



2. Password Strength Evaluation (Get-PasswordStrength & Interpret-Strength)



The script scores the password on a scale of 0 to 6, based on:

✔ Minimum length (≥8 characters)

✔ Longer length (≥12 characters)

✔ Lowercase letters

✔ Uppercase letters

✔ Numbers

✔ Special characters



The function Interpret-Strength then classifies the score into Weak (≤2), Medium (3-4), or Strong (5-6).



3. Checking Have I Been Pwned (Check-PwnedPassword)

• The script queries the HIBP API by taking the first 5 characters of the SHA-1 hash and retrieving a list of possible matches.

• It compares the full hash suffix against these results.

• If a match is found, it returns the number of breaches the password appears in.



4. Graphical User Interface (GUI) with Windows Forms

• A TextBox for password input (masked for security).

• A Button (“Verify”) to trigger the check.

• Three Labels to display the score, strength level, and HIBP result.



5. Handling the Button Click Event



When the user clicks “Verify”:

1. The script retrieves the password input.

2. It calculates the strength score and updates the UI.

3. It checks against Have I Been Pwned and updates the UI accordingly.



How the HIBP API is Used

• This script correctly implements the latest “range” API from HIBP, which does not require an API key.

• The API request only sends the first 5 characters of the SHA-1 hash, protecting the full password from being exposed.

• This method ensures secure password verification while maintaining privacy.



How to Use

1. Run the script in PowerShell (ensure execution policies allow scripts). OR you can use the .exe file created with ps2exe module

2. Enter a password in the input field.

3. Click “Verify”.

4. The script will display:

• A numerical strength score

• A strength level (“Weak”, “Medium”, “Strong”)

• Whether the password has been breached (and how many times).



