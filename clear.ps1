# Remove todas as pastas __history e __recovery (artefatos do Delphi/IDE).
# Uso: .\Remove-DelphiHistoryFolders.ps1
# Opcional: .\Remove-DelphiHistoryFolders.ps1 -Root "C:\caminho\do\projeto"

[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $Root = ''
)

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = if ($PSScriptRoot) { $PSScriptRoot } else {
        Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
    }
}

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Error "Pasta nao encontrada: $Root"
    exit 1
}

$names = @('__history', '__recovery')

$folders = Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $names -contains $_.Name }

# Remove do mais profundo para o mais raso (evita problemas se houver aninhamento raro)
$sorted = $folders | Sort-Object { $_.FullName.Length } -Descending

$count = 0
foreach ($dir in $sorted) {
    if ($PSCmdlet.ShouldProcess($dir.FullName, 'Remover pasta')) {
        try {
            Remove-Item -LiteralPath $dir.FullName -Recurse -Force -ErrorAction Stop
            Write-Host "Removido: $($dir.FullName)"
            $count++
        }
        catch {
            Write-Warning "Falha ao remover $($dir.FullName): $_"
        }
    }
}

Write-Host "Concluido. Pastas removidas: $count."
