[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Version,
    [string]$ZipName = 'akarnokd-all.zip',
    [string]$Owner = 'akarnokd',
    [string]$Repo = 'ThePlanetCrafterMods',
    [string]$TargetPath = (Get-Location).Path,
    [int]$ReleaseMenuCount = 9
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        [void][System.IO.Directory]::CreateDirectory($Path)
    }
}

function Remove-DirectoryContents {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return
    }

    Get-ChildItem -LiteralPath $Path -Force | ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

function Get-TopLevelZipFolderName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ZipEntryName
    )

    $normalized = $ZipEntryName.Replace('\', '/').TrimStart('/')

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return $null
    }

    $parts = $normalized.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries)

    if ($parts.Count -lt 2) {
        return $null
    }

    return $parts[0]
}

function Get-ReleaseDisplayText {
    param(
        [Parameter(Mandatory = $true)]
        $Release
    )

    function Clean-ReleaseLine {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Text
        )

        $text = $Text.Trim()

        if ([string]::IsNullOrWhiteSpace($text)) {
            return $null
        }

        if ($text -match '^\s*[-=*`>]+\s*$') {
            return $null
        }

        # Strip markdown heading markers
        $text = $text -replace '^\s*#{1,6}\s*', ''

        # Strip leading/trailing markdown emphasis markers
        $text = $text -replace '^\s*[*_~`]+\s*', ''
        $text = $text -replace '\s*[*_~`]+\s*$', ''

        # Strip GitHub emoji shortcodes like :tada: or :warning:
        $text = $text -replace ':[a-zA-Z0-9_+\-]+:', ''

        # Collapse repeated whitespace left behind
        $text = $text -replace '\s+', ' '

        $text = $text.Trim()

        if ([string]::IsNullOrWhiteSpace($text)) {
            return $null
        }

        return $text
    }

    if (-not [string]::IsNullOrWhiteSpace($Release.name)) {
        $name = Clean-ReleaseLine -Text $Release.name
        if (-not [string]::IsNullOrWhiteSpace($name) -and $name -ne $Release.tag_name) {
            return $name
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Release.body)) {
        $lines = $Release.body -split "`r?`n"

        foreach ($line in $lines) {
            $text = Clean-ReleaseLine -Text $line
            if (-not [string]::IsNullOrWhiteSpace($text)) {
                return $text
            }
        }
    }

    return $Release.tag_name
}
function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )

    Invoke-RestMethod -Uri $Uri -Headers @{
        'Accept' = 'application/vnd.github+json'
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent' = 'PowerShell'
    }
}

function Get-ReleaseAssetObject {
    param(
        [Parameter(Mandatory = $true)]
        $Release,

        [Parameter(Mandatory = $true)]
        [string]$ZipName
    )

    $wantedAsset = $Release.assets | Where-Object { $_.name -eq $ZipName } | Select-Object -First 1
    if ($null -eq $wantedAsset) {
        return $null
    }

    [pscustomobject]@{
        TagName        = $Release.tag_name
        Name           = $Release.name
        Body           = $Release.body
        PublishedAt    = $Release.published_at
        DisplayText    = Get-ReleaseDisplayText -Release $Release
        ZipName        = $wantedAsset.name
        DownloadUrl    = $wantedAsset.browser_download_url
    }
}

function Get-GitHubReleasesForMenu {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,

        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter(Mandatory = $true)]
        [string]$ZipName,

        [Parameter(Mandatory = $true)]
        [int]$Count
    )

    $uri = "https://api.github.com/repos/$Owner/$Repo/releases?per_page=$Count"
    $rawReleases = Invoke-GitHubApi -Uri $uri

    $results = @()

    foreach ($release in $rawReleases) {
        $releaseObject = Get-ReleaseAssetObject -Release $release -ZipName $ZipName
        if ($null -ne $releaseObject) {
            $results += $releaseObject
        }
    }

    return $results
}

function Get-GitHubReleaseByTag {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,

        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter(Mandatory = $true)]
        [string]$Tag,

        [Parameter(Mandatory = $true)]
        [string]$ZipName
    )

    $uri = "https://api.github.com/repos/$Owner/$Repo/releases/tags/$Tag"

    try {
        $release = Invoke-GitHubApi -Uri $uri
    }
    catch {
        throw "GitHub release tag '$Tag' was not found in $Owner/$Repo."
    }

    $releaseObject = Get-ReleaseAssetObject -Release $release -ZipName $ZipName

    if ($null -eq $releaseObject) {
        throw "Release '$Tag' exists, but asset '$ZipName' was not found on that release."
    }

    return $releaseObject
}

function Select-ReleaseFromMenu {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Releases
    )

    if ($Releases.Count -eq 0) {
        throw "No matching releases were returned."
    }

    Write-Host ''
    Write-Host 'Available releases:'
    Write-Host ''

    for ($i = 0; $i -lt $Releases.Count; $i++) {
        $r = $Releases[$i]
        Write-Host (" {0}. {1} [{2}]" -f ($i + 1), $r.DisplayText, $r.TagName)
    }

    Write-Host ''

    while ($true) {
        $choice = Read-Host "Enter the number to download (1-$($Releases.Count))"
        [int]$selectedIndex = 0

        if ([int]::TryParse($choice, [ref]$selectedIndex)) {
            if ($selectedIndex -ge 1 -and $selectedIndex -le $Releases.Count) {
                return $Releases[$selectedIndex - 1]
            }
        }

        Write-Host "Invalid selection: $choice"
    }
}

function Update-ModFoldersFromZip {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ZipFile,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $localFolders = Get-ChildItem -LiteralPath $TargetPath -Directory | Select-Object -ExpandProperty Name

    if (-not $localFolders -or $localFolders.Count -eq 0) {
        Write-Warning "No local folders found in '$TargetPath'. Nothing to update."
        return
    }

    $localFolderSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($folder in $localFolders) {
        [void]$localFolderSet.Add($folder)
    }

    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)

    try {
        $zipTopFolders = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        foreach ($entry in $zip.Entries) {
            $topFolder = Get-TopLevelZipFolderName -ZipEntryName $entry.FullName
            if ($null -ne $topFolder) {
                [void]$zipTopFolders.Add($topFolder)
            }
        }

        $foldersToUpdate = @()

        foreach ($folder in $localFolders) {
            if ($zipTopFolders.Contains($folder)) {
                $foldersToUpdate += $folder
            }
            else {
                Write-Host "Skipping '$folder' - not found in zip"
            }
        }

        if ($foldersToUpdate.Count -eq 0) {
            Write-Warning "No matching folders found between local path and zip."
            return
        }

        Write-Host ''
        Write-Host 'Folders to update:'
        foreach ($folder in $foldersToUpdate) {
            Write-Host " - $folder"
        }
        Write-Host ''

        foreach ($folder in $foldersToUpdate) {
            $fullFolderPath = Join-Path $TargetPath $folder

            if ($PSCmdlet.ShouldProcess($fullFolderPath, "Replace folder contents from zip")) {
                Remove-DirectoryContents -Path $fullFolderPath
            }
        }

        foreach ($entry in $zip.Entries) {
            $topFolder = Get-TopLevelZipFolderName -ZipEntryName $entry.FullName
            if ($null -eq $topFolder) {
                continue
            }

            if (-not $localFolderSet.Contains($topFolder)) {
                continue
            }

            if (-not $zipTopFolders.Contains($topFolder)) {
                continue
            }

            $relativePath = $entry.FullName.Replace('/', '\')
            $destinationPath = Join-Path $TargetPath $relativePath

            if ([string]::IsNullOrEmpty($entry.Name)) {
                Ensure-Directory -Path $destinationPath
            }
            else {
                $destinationDir = Split-Path -Path $destinationPath -Parent
                Ensure-Directory -Path $destinationDir

                if ($PSCmdlet.ShouldProcess($destinationPath, "Extract file from zip")) {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destinationPath, $true)
                }
            }
        }
    }
    finally {
        $zip.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "Target path '$TargetPath' does not exist or is not a directory."
}

$selectedRelease = $null

if (-not [string]::IsNullOrWhiteSpace($Version)) {
    $selectedRelease = Get-GitHubReleaseByTag -Owner $Owner -Repo $Repo -Tag $Version -ZipName $ZipName
}
else {
    $menuReleases = Get-GitHubReleasesForMenu -Owner $Owner -Repo $Repo -ZipName $ZipName -Count $ReleaseMenuCount

    if (-not $menuReleases -or $menuReleases.Count -eq 0) {
        throw "No recent releases containing '$ZipName' were found."
    }

    $selectedRelease = Select-ReleaseFromMenu -Releases $menuReleases
}

Write-Host ''
Write-Host "Chosen release: $($selectedRelease.DisplayText)"
Write-Host "Tag:            $($selectedRelease.TagName)"
Write-Host "Asset:          $($selectedRelease.ZipName)"
Write-Host "Target path:    $TargetPath"
Write-Host ''

$tempZip = Join-Path ([System.IO.Path]::GetTempPath()) "$([guid]::NewGuid().ToString())-$($selectedRelease.ZipName)"

try {
    Write-Host "Downloading $($selectedRelease.DownloadUrl)"
    Invoke-WebRequest -Uri $selectedRelease.DownloadUrl -OutFile $tempZip

    Update-ModFoldersFromZip -ZipFile $tempZip -TargetPath $TargetPath

    Write-Host ''
    Write-Host 'Done.'
}
finally {
    if (Test-Path -LiteralPath $tempZip) {
        Remove-Item -LiteralPath $tempZip -Force
    }
}
