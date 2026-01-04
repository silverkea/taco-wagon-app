# Get the GitHub repository name from git remote
$gitRemote = git remote get-url origin
if ($gitRemote -match '([^/:]+)/([^/]+?)(\.git)?$') {
    $githubRepo = "$($matches[1])/$($matches[2])"
    Write-Host "Using GitHub repo: $githubRepo" -ForegroundColor Green
} else {
    Write-Error "Could not extract GitHub repo from remote URL: $gitRemote"
    exit 1
}

# Run terraform plan
$args = @(
    "plan"
    "-var=github_repo=$githubRepo"
    "-out=oicd.tfplan"
)
& terraform $args
