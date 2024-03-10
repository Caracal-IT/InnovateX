function Read-HostWithDefault {
    param(
        [string]$Message,
        [string]$DefaultValue,
        [boolean]$AsSecureString = $false
    )

    if (-not $Message) {
        $Message = "Enter your input"
    }

    $result = "";

    if($AsSecureString) {
        $inputVariable = Read-Host $Message " [***********]" -AsSecureString

        if ($inputVariable.Length -eq 0) {
            $result = ConvertTo-SecureString $DefaultValue -AsPlainText -Force
        } else {
            $result = $inputVariable
        }
    } else {
        $result = Read-Host $Message " [$DefaultValue]"
    }

    if ([string]::IsNullOrEmpty($result)) {
        $result = $DefaultValue
    }

    return $result
}

function New-RandomPassword {
    param (
        [int]$Length = 12
    )

    # Define character sets
    $LowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz'
    $UpperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $Numbers = '0123456789'
    $SpecialCharacters = '!@#$%^&*()_+-=[]{}|;:,.<>?'

    # Combine character sets
    $CharacterSet = $LowerCaseLetters + $UpperCaseLetters + $Numbers + $SpecialCharacters

    # Generate random password
    $Password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $RandomIndex = Get-Random -Minimum 0 -Maximum $CharacterSet.Length
        $Password += $CharacterSet[$RandomIndex]
    }

    return $Password
}

function New-Directory {
    param (
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -ItemType Directory
    }
}