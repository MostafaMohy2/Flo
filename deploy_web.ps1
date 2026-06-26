Param(
  [string]$Remote = "Flo",
  [string]$Branch = "gh-pages",
  [string]$Worktree = "..\flo-gh-pages"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

# Build web output
flutter build web --release

# Ensure worktree exists for gh-pages
if (-not (Test-Path $Worktree)) {
  git worktree add -B $Branch $Worktree
}

# Clean worktree (keep .git)
Set-Location $Worktree
Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force

# Copy build artifacts
Copy-Item -Recurse (Join-Path $repoRoot "build\web\*") $Worktree

# Ensure .nojekyll
New-Item -ItemType File -Name ".nojekyll" -Force | Out-Null

# Commit + push
git add .
if (git status --porcelain) {
  git commit -m "Deploy web build"
}

git push -f $Remote $Branch
