$ErrorActionPreference = "Stop"
$Out = Join-Path (Split-Path -Parent $PSScriptRoot) "docs\verifications\kubectl-get-all-A.txt"
kubectl get all -A | Out-File -FilePath $Out -Encoding utf8
