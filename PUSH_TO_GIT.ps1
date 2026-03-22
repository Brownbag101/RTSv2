# PUSH_TO_GIT.ps1
# Pushes OpsRoom_Dev to GitHub repository
# Usage: Right-click -> Run with PowerShell, or run from terminal

$repoPath = "C:\Users\Brown\Desktop\OpsRoom_Dev"
$remoteUrl = "https://github.com/Brownbag101/RTSv2.git"
$branch = "main"

Set-Location $repoPath

# Initialize git if not already a repo
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    git branch -M $branch
    git remote add origin $remoteUrl
    Write-Host "Git initialized and remote added." -ForegroundColor Green
} else {
    Write-Host "Git repo already initialized." -ForegroundColor Green
    
    # Ensure remote is set correctly
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote -ne $remoteUrl) {
        git remote set-url origin $remoteUrl
        Write-Host "Remote URL updated." -ForegroundColor Yellow
    }
}

# Stage all changes
Write-Host "`nStaging all files..." -ForegroundColor Yellow
git add -A

# Show status
Write-Host "`nCurrent status:" -ForegroundColor Cyan
git status --short

# Prompt for commit message
$commitMsg = Read-Host "`nEnter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMsg = "OpsRoom update - $timestamp"
}

# Commit
git commit -m $commitMsg

# Push
Write-Host "`nPushing to $remoteUrl ($branch)..." -ForegroundColor Yellow
git push -u origin $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPush successful!" -ForegroundColor Green
} else {
    Write-Host "`nPush failed. If the remote has existing commits, try:" -ForegroundColor Red
    Write-Host "  git pull --rebase origin $branch" -ForegroundColor Yellow
    Write-Host "  Then run this script again." -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
