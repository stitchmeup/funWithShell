<#
.SYNOPSIS
    Convert an image to a Base64 string
.DESCRIPTION
    Convert an image to a Base64 string
    The image is read from a file and converted to a Base64 string.
    The Base64 string is then printed or output.
.PARAMETER Path
    Path to the image file to convert.
.EXAMPLE
    PS>.\Convert-ImageToBase64.ps1 -Path "C:\path\to\your\image.jpg"
.NOTES
    Version: 1.0.0
    Author: stitchmeup
    Updates:
    -   1.0.0 - 10-16-2023 - Initial version
#>
Param(
    [Parameter(Mandatory=$true)]
    [String]$Path
)
$imageBytes = [System.IO.File]::ReadAllBytes($Path)
$base64String = [System.Convert]::ToBase64String($imageBytes)

# Print or output the Base64 string
$base64String