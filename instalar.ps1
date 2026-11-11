# Instala as skills deste repositório no Windows (PowerShell 5.1+ ou 7+).
#
#   .\instalar.ps1                          → instala em $HOME\.claude\skills
#   .\instalar.ps1 -Destino C:\pasta        → instala em outra pasta
#   .\instalar.ps1 -SemBaixar               → só as skills copiadas aqui
#
# Se o Windows bloquear scripts: powershell -ExecutionPolicy Bypass -File .\instalar.ps1
param(
  [string]$Destino = (Join-Path $HOME ".claude\skills"),
  [switch]$SemBaixar
)
$ErrorActionPreference = "Stop"
$Raiz = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $Destino | Out-Null

function Copiar-Skill([string]$Origem) {
  $alvo = Join-Path $Destino (Split-Path $Origem -Leaf)
  if (Test-Path $alvo) { Remove-Item -Recurse -Force $alvo }
  Copy-Item -Recurse -Force $Origem $alvo
}

$n = 0
Get-ChildItem -Directory (Join-Path $Raiz "skills") | ForEach-Object { Copiar-Skill $_.FullName; $n++ }
Write-Host "OK: $n skills copiadas para $Destino"

$falhas = 0
if (-not $SemBaixar) {
  foreach ($linha in Get-Content (Join-Path $Raiz "fontes.conf")) {
    if ($linha -notmatch '^baixar\|') { continue }
    $tipo, $repo, $commit, $padrao = $linha.Split('|')
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
      git -C $tmp init -q; if ($LASTEXITCODE) { throw "git init" }
      git -C $tmp fetch -q --depth 1 "https://github.com/$repo" $commit; if ($LASTEXITCODE) { throw "git fetch" }
      git -C $tmp checkout -q FETCH_HEAD; if ($LASTEXITCODE) { throw "git checkout" }
      $base = Join-Path $tmp (Split-Path $padrao -Parent)
      $m = 0
      Get-ChildItem -Directory $base | ForEach-Object { Copiar-Skill $_.FullName; $m++ }
      Write-Host "OK: $m itens de $repo ($($commit.Substring(0,7)))"
    } catch {
      Write-Warning "Nao consegui baixar $repo ($($commit.Substring(0,7))): $_"; $falhas++
    } finally {
      Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
  }
}
Write-Host "Pronto. Reinicie o Claude Code para carregar as skills."
if ($falhas) { exit 3 }
