[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryPath = (Get-Location).Path,

    [Parameter()]
    [switch]$AllowDirty,

    [Parameter()]
    [switch]$SkipDocker
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$results = [System.Collections.Generic.List[object]]::new()
$dockerStarted = $false
$repoRoot = $null

function Add-CheckResult {
    param(
        [string]$Name,
        [ValidateSet("PASS", "WARN", "FAIL")]
        [string]$Status,
        [string]$Details
    )

    $results.Add([pscustomobject]@{
        Check   = $Name
        Status  = $Status
        Details = $Details
    })

    $symbol = switch ($Status) {
        "PASS" { "[OK]" }
        "WARN" { "[AVISO]" }
        "FAIL" { "[ERROR]" }
    }

    Write-Host "$symbol $Name - $Details"
}

function Test-CommandAvailable {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-NativeCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )

    & $FilePath @Arguments | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "El comando '$FilePath $($Arguments -join ' ')' terminó con código $LASTEXITCODE."
    }
}

function Invoke-ReleaseCheck {
    param(
        [string]$Name,
        [scriptblock]$Action,
        [switch]$WarningOnly
    )

    try {
        $details = & $Action
        if ([string]::IsNullOrWhiteSpace([string]$details)) {
            $details = "Comprobación completada."
        }
        Add-CheckResult -Name $Name -Status "PASS" -Details ([string]$details)
    }
    catch {
        $status = if ($WarningOnly) { "WARN" } else { "FAIL" }
        Add-CheckResult -Name $Name -Status $status -Details $_.Exception.Message
    }
}

try {
    if (-not (Test-Path -LiteralPath $RepositoryPath -PathType Container)) {
        throw "No existe la carpeta indicada: $RepositoryPath"
    }

    $resolvedRepository = (Resolve-Path -LiteralPath $RepositoryPath).Path
    Push-Location $resolvedRepository

    Invoke-ReleaseCheck -Name "Repositorio Git" -Action {
        if (-not (Test-CommandAvailable "git")) {
            throw "Git no está disponible en PATH."
        }

        $root = (& git rev-parse --show-toplevel 2>$null).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
            throw "La carpeta no es un repositorio Git válido."
        }

        $script:repoRoot = (Resolve-Path -LiteralPath $root).Path
        "Raíz detectada: $script:repoRoot"
    }

    if ($repoRoot) {
        Set-Location $repoRoot
    }

    Invoke-ReleaseCheck -Name "Rama de publicación" -Action {
        $branch = (& git branch --show-current).Trim()
        if ($branch -notin @("redesign-2026", "main")) {
            throw "La rama actual es '$branch'. Usa redesign-2026 para la revisión o main después del merge."
        }
        "Rama actual: $branch"
    }

    Invoke-ReleaseCheck -Name "Estado del árbol de trabajo" -WarningOnly:$AllowDirty -Action {
        $status = (& git status --porcelain=v1)
        if ($status) {
            throw "Hay cambios sin confirmar. Confírmalos o usa -AllowDirty solo durante una prueba preliminar."
        }
        "No hay cambios pendientes."
    }

    Invoke-ReleaseCheck -Name "Repositorio remoto" -Action {
        $remote = (& git remote get-url origin 2>$null).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($remote)) {
            throw "No se encontró el remoto origin."
        }
        if ($remote -notmatch "Dkrxchelita13[\\/]Dkrxchelita13\.github\.io(?:\.git)?$") {
            throw "El remoto origin no parece corresponder a Dkrxchelita13/Dkrxchelita13.github.io: $remote"
        }
        "origin: $remote"
    }

    Invoke-ReleaseCheck -Name "Archivos obligatorios" -Action {
        $requiredFiles = @(
            "hugo.toml",
            "Dockerfile",
            "docker-compose.yml",
            "nginx.conf",
            ".github/workflows/deploy.yml",
            "scripts/validate_site.py",
            "static/files/CV_Luz_Graciela_Torales_ES.pdf",
            "static/files/Luz_Graciela_Torales_Resume_EN.pdf",
            "content/_index.es.md",
            "content/_index.en.md",
            "content/projects/protectpyme/index.es.md",
            "content/projects/netadmin-api/index.es.md"
        )

        $missing = @($requiredFiles | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
        if ($missing.Count -gt 0) {
            throw "Faltan: $($missing -join ', ')"
        }
        "$($requiredFiles.Count) archivos obligatorios presentes."
    }

    Invoke-ReleaseCheck -Name "Limpieza del sitio antiguo" -Action {
        $legacyPaths = @(
            ".Rhistory",
            "LGTR.Rproj",
            ".gitlab-ci.yml",
            "hugo.yaml",
            "netlify.toml",
            "package.json",
            "package-lock.json",
            "package.hugo.json",
            "go.mod",
            "go.sum",
            "data/bn",
            "content/notes",
            "content/posts",
            "static/videos/sample.mp4",
            "static/files/resume.pdf",
            "static/files/cven.pdf"
        )

        $remaining = @($legacyPaths | Where-Object { Test-Path -LiteralPath $_ })
        if ($remaining.Count -gt 0) {
            throw "Aún existen elementos antiguos: $($remaining -join ', ')"
        }
        "No quedan dependencias ni contenidos heredados de Toha."
    }

    Invoke-ReleaseCheck -Name "Privacidad y posibles secretos" -Action {
        $patterns = @(
            "Fraccionamiento Alameda",
            "271-213-5027",
            "BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY",
            "github_pat_[A-Za-z0-9_]{20,}",
            "ghp_[A-Za-z0-9]{20,}",
            "xox[baprs]-[A-Za-z0-9-]+",
            "TELEGRAM_BOT_TOKEN[[:space:]]*=",
            "DATABASE_URL[[:space:]]*=",
            'postgresql://[^[:space:]"'']+'
        )

        $matches = [System.Collections.Generic.List[string]]::new()
        foreach ($pattern in $patterns) {
            $output = & git grep -n -I -E -e $pattern -- . ":(exclude)scripts/release_check.ps1" 2>$null
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0 -and $output) {
                foreach ($line in $output) {
                    $matches.Add([string]$line)
                }
            }
            elseif ($exitCode -notin @(0, 1)) {
                throw "git grep falló al revisar el patrón: $pattern"
            }
        }

        if ($matches.Count -gt 0) {
            throw "Se encontraron datos que deben revisarse:`n$($matches -join "`n")"
        }
        "No se detectaron el domicilio, teléfono ni patrones comunes de secretos."
    }

    Invoke-ReleaseCheck -Name "Hugo Extended" -Action {
        if (-not (Test-CommandAvailable "hugo")) {
            throw "Hugo no está instalado o no está disponible en PATH."
        }
        $version = (& hugo version | Select-Object -First 1)
        if ($version -notmatch "extended") {
            throw "La instalación de Hugo no parece ser Extended: $version"
        }
        $version
    }

    Invoke-ReleaseCheck -Name "Compilación de producción" -Action {
        Invoke-NativeCommand -FilePath "hugo" -Arguments @(
            "--gc",
            "--minify",
            "--cleanDestinationDir",
            "--environment",
            "production"
        )
        "Hugo generó la carpeta public sin errores."
    }

    Invoke-ReleaseCheck -Name "Validador de sitio" -Action {
        if (Test-CommandAvailable "python") {
            Invoke-NativeCommand -FilePath "python" -Arguments @("scripts/validate_site.py", "public")
        }
        elseif (Test-CommandAvailable "py") {
            Invoke-NativeCommand -FilePath "py" -Arguments @("-3", "scripts/validate_site.py", "public")
        }
        else {
            throw "No se encontró Python 3."
        }
        "Metadatos, enlaces, fragmentos, imágenes y archivos públicos validados."
    }

    Invoke-ReleaseCheck -Name "Rutas públicas esenciales" -Action {
        $requiredPublicFiles = @(
            "public/index.html",
            "public/en/index.html",
            "public/projects/index.html",
            "public/projects/protectpyme/index.html",
            "public/projects/netadmin-api/index.html",
            "public/en/projects/index.html",
            "public/404.html",
            "public/robots.txt",
            "public/sitemap.xml",
            "public/site.webmanifest",
            "public/files/CV_Luz_Graciela_Torales_ES.pdf",
            "public/files/Luz_Graciela_Torales_Resume_EN.pdf"
        )

        $missing = @($requiredPublicFiles | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
        if ($missing.Count -gt 0) {
            throw "No se generaron: $($missing -join ', ')"
        }
        "$($requiredPublicFiles.Count) rutas esenciales generadas."
    }

    if ($SkipDocker) {
        Add-CheckResult -Name "Docker y Nginx" -Status "WARN" -Details "Prueba omitida mediante -SkipDocker."
    }
    elseif (-not (Test-CommandAvailable "docker")) {
        Add-CheckResult -Name "Docker y Nginx" -Status "WARN" -Details "Docker no está disponible; GitHub Pages puede publicarse, pero la prueba contenerizada quedó pendiente."
    }
    else {
        Invoke-ReleaseCheck -Name "Configuración Docker Compose" -Action {
            Invoke-NativeCommand -FilePath "docker" -Arguments @("compose", "config", "--quiet")
            "docker-compose.yml es válido."
        }

        Invoke-ReleaseCheck -Name "Construcción y health check Docker" -Action {
            try {
                Invoke-NativeCommand -FilePath "docker" -Arguments @("compose", "up", "--build", "-d")
                $script:dockerStarted = $true

                $deadline = (Get-Date).AddSeconds(90)
                $lastError = "El contenedor aún no responde."
                do {
                    Start-Sleep -Seconds 3
                    try {
                        $health = Invoke-WebRequest -Uri "http://127.0.0.1:8080/healthz" -UseBasicParsing -TimeoutSec 5
                        $home = Invoke-WebRequest -Uri "http://127.0.0.1:8080/" -UseBasicParsing -TimeoutSec 5
                        $english = Invoke-WebRequest -Uri "http://127.0.0.1:8080/en/" -UseBasicParsing -TimeoutSec 5
                        $projects = Invoke-WebRequest -Uri "http://127.0.0.1:8080/projects/" -UseBasicParsing -TimeoutSec 5

                        if ($health.StatusCode -eq 200 -and
                            $home.StatusCode -eq 200 -and
                            $english.StatusCode -eq 200 -and
                            $projects.StatusCode -eq 200) {
                            return "Nginx respondió 200 en healthz, portada, inglés y proyectos."
                        }
                    }
                    catch {
                        $lastError = $_.Exception.Message
                    }
                } while ((Get-Date) -lt $deadline)

                throw "El contenedor no quedó listo en 90 segundos. Último error: $lastError"
            }
            finally {
                if ($script:dockerStarted) {
                    & docker compose down | Out-Host
                    $script:dockerStarted = $false
                }
            }
        }
    }
}
catch {
    Add-CheckResult -Name "Ejecución general" -Status "FAIL" -Details $_.Exception.Message
}
finally {
    if ($dockerStarted -and (Test-CommandAvailable "docker")) {
        try {
            & docker compose down | Out-Host
        }
        catch {
            Write-Warning "No fue posible detener Docker Compose automáticamente."
        }
    }

    try {
        Pop-Location
    }
    catch {
        # No se había cambiado de ubicación.
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = Join-Path $env:TEMP "portfolio-release-check-$timestamp.txt"
$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("PORTAFOLIO DE LUZ TORALES - INFORME DE PUBLICACIÓN")
$reportLines.Add("Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
$reportLines.Add("Repositorio: $RepositoryPath")
$reportLines.Add("")

foreach ($result in $results) {
    $reportLines.Add("[$($result.Status)] $($result.Check): $($result.Details)")
}

$failures = @($results | Where-Object Status -eq "FAIL")
$warnings = @($results | Where-Object Status -eq "WARN")
$passes = @($results | Where-Object Status -eq "PASS")

$reportLines.Add("")
$reportLines.Add("Resumen: $($passes.Count) correctas, $($warnings.Count) avisos, $($failures.Count) errores.")
$reportLines | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "Informe guardado en: $reportPath"
Write-Host "Resumen: $($passes.Count) correctas, $($warnings.Count) avisos, $($failures.Count) errores."

if ($failures.Count -gt 0) {
    exit 1
}

Write-Host "El portafolio está listo para crear o completar el pull request."
exit 0
