# PowerShell script to replace .withValues(alpha: x) with .withOpacity(x)
# Run from project root: .\fix_withValues.ps1

param(
    [string]$Directory = ".\lib",
    [string]$BackupDir = ".\backup_before_fix"
)

# Create backup
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Write-Host "Created backup directory: $BackupDir" -ForegroundColor Yellow
}

$totalFiles = 0
$totalFixes = 0

Get-ChildItem -Path $Directory -Recurse -Filter *.dart | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    $originalContent = $content
    
    # Pattern to match .withValues(alpha: EXPRESSION) and capture EXPRESSION
    # Handles: numbers, method calls, expressions with operators
    $pattern = '\.withValues\(alpha:\s*([^)]*(?:\([^)]*\)[^)]*)*)\)'
    
    # Replace with .withOpacity(EXPRESSION)
    $content = [regex]::Replace($content, $pattern, {
        param($match)
        $expr = $match.Groups[1].Value.Trim()
        return ".withOpacity($expr)"
    })
    
    if ($content -ne $originalContent) {
        # Backup original
        $relPath = $file.Substring((Get-Location).Path.Length + 1)
        $backupPath = Join-Path $BackupDir $relPath
        $backupDir = Split-Path $backupPath
        if (!(Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        Copy-Item $file $backupPath
        
        # Write fixed content
        Set-Content -Path $file -Value $content -NoNewline
        
        $fixCount = ([regex]::Matches($originalContent, $pattern)).Count
        $totalFixes += $fixCount
        $totalFiles++
        Write-Host "Fixed $fixCount occurrence(s) in: $relPath" -ForegroundColor Green
    }
}

Write-Host "`nDone!" -ForegroundColor Cyan
Write-Host "Total files modified: $totalFiles" -ForegroundColor Cyan
Write-Host "Total occurrences fixed: $totalFixes" -ForegroundColor Cyan
Write-Host "Backups saved to: $BackupDir" -ForegroundColor Yellow
