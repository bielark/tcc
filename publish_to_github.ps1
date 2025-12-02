param(
  [string]$GitUserName = "Seu Nome",
  [string]$GitUserEmail = "seu@email.com",
  [string]$RepoName = "tcc",
  [string]$GitHubUser = "bielark"
)

Write-Host "Running publish_to_github.ps1 in: $PWD" -ForegroundColor Cyan

# Check for Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "Git não encontrado. Instale Git (https://git-scm.com/) e reexecute o script.";
  exit 1
}

# Move to script folder (project root)
Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Initialize repo if needed
if (-not (Test-Path .git)) {
  Write-Host "Inicializando repositório Git...";
  git init
} else {
  Write-Host "Repositório Git já inicializado.";
}

# Configure user
Write-Host "Configurando usuário Git: $GitUserName <$GitUserEmail>";
git config user.name "$GitUserName"
git config user.email "$GitUserEmail"

# Add & commit
Write-Host "Adicionando arquivos e fazendo commit...";
git add .
try {
  git commit -m "Initial commit: site files" | Out-Null
  Write-Host "Commit criado.";
} catch {
  Write-Host "Nenhum novo commit (já está tudo commitado).";
}

# Set main branch
try {
  git branch -M main
} catch {
  # ignore
}

# Create remote and push using GitHub CLI if available
if (Get-Command gh -ErrorAction SilentlyContinue) {
  Write-Host "GitHub CLI encontrado. Autentique se necessário.";
  Write-Host "Executando: gh auth login (vai pedir interação)" -ForegroundColor Yellow;
  gh auth login

  Write-Host "Criando repositório remoto e enviando (público): $GitHubUser/$RepoName";
  gh repo create $GitHubUser/$RepoName --public --source=. --remote=origin --push
  Write-Host "Push concluído." -ForegroundColor Green;
} else {
  Write-Warning "GitHub CLI (gh) não encontrado. Gerando comandos manuais para você executar:";
  Write-Host "1) Crie o repositório 'tcc' no GitHub (público) ou use a URL abaixo se já existir.";
  Write-Host "2) Execute os comandos abaixo:";
  Write-Host "git remote add origin https://github.com/$GitHubUser/$RepoName.git" -ForegroundColor Cyan;
  Write-Host "git push -u origin main" -ForegroundColor Cyan;
}

Write-Host "Script finalizado." -ForegroundColor Green
