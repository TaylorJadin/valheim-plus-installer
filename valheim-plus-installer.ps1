### Config ###
$repo = "valheimPlus/ValheimPlus"
$file = "WindowsClient.zip"
$vp_config_url = "https://raw.githubusercontent.com/TaylorJadin/valheim-plus-installer/main/valheim_plus.cfg"

### Install Paths ###
$installPath1 = "C:\Program Files (x86)\Steam\steamapps\common\Valheim"
$installPath2 = "D:\Steam\steamapps\common\Valheim"

# Write some blank lines to make this look nicer in the console
Write-Host `n`n`n`n`n

# Get-Folder function

Function Get-Folder($initialDirectory="")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

clear

# Find install path
if (Test-Path $installPath1\valheim.exe) {
    Write-Host "Valehim installation found at: $installPath1"
    Write-Host ""
    $valheim = $installPath1
}
elseif (Test-Path $installPath2\valheim.exe) {
    Write-Host "Valehim installation found at: $installPath2"
    Write-Host ""
    $valheim = $installPath2
}
else {
    Write-Host "Please locate the Valheim install folder."
    $selectedPath = Get-Folder
    if (Test-Path $selectedPath\valheim.exe) {
        Write-Host "Valehim installation found at: $selectedPath"
        Write-Host ""
        $valheim = $selectedPath
    }
    else {
        Write-Host "Invalid Path. Please run the script again and locate the install folder for Valheim"
        Pause
        Exit
    }
}

# Download latest release from github
$releases = "https://api.github.com/repos/$repo/releases"
Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

$download = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]
$zip = "$name-$tag.zip"
$dir = "$name-$tag"

Write-Host Dowloading latest release
Invoke-WebRequest $download -Out $zip

Write-Host Extracting release files
Expand-Archive $zip -Force

# Copy mod files into Valheim folder
xcopy $dir $valheim /s /y

# Download valheim_plus.cfg and put into game folder
Write-Host `n
Write-Host Downloading valheim_plus.cfg to game directory
Invoke-WebRequest $vp_config_url -Out $valheim/BepInEx/config/valheim_plus.cfg

# Removing temp files
Remove-Item $zip -Force
Remove-Item $dir -Recurse -Force

Write-Host ""
Write-Host ""
Write-Host "Installation complete!"
Write-Host ""
Write-Host ""
Pause