param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Confirm-Step($message) {
    if ($Force) {
        Write-Host "[FORCED] $message"
        return
    }

    $answer = Read-Host "$message (Y/N)"

    if ($answer -notin @("Y", "y", "Yes", "yes")) {
        Write-Host "Operation cancelled."
        exit
    }
}

function Pause-Step($message) {
    Write-Host $message
    Write-Host "Press Enter to continue..."
    Read-Host
}

$configuration = "Release"
$runtime = "win-x64"
$dotnet = "$env:USERPROFILE\.dotnet\dotnet.exe"
$projectFile = "GHelper.csproj"

[xml]$csproj = Get-Content $projectFile
$version = $csproj.Project.PropertyGroup.AssemblyVersion

Confirm-Step "Compile files for version $version ?"

Write-Host "Publishing version $version..."

& $dotnet publish $projectFile `
    -c $configuration `
    -r $runtime `
    --self-contained false

Confirm-Step "Commit changes to Git?"

Write-Host "Committing and pushing..."

git add .
git commit -m "Release v$version"

Confirm-Step "Push to GitHub?"

git push

Write-Host "Pushed."