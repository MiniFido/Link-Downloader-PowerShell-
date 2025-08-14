# --- Indstillinger ---
$ListPath = ".\links.txt"
$OutDir   = ".\downloads"
$BufferSz = 65536   # 64 KB

# --- Hjælpefunktioner ---
function Get-FileNameFromUrl([string]$url) {
    try {
        $u = [System.Uri]$url
        $name = [System.IO.Path]::GetFileName($u.AbsolutePath)
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = ("fil_" + (Get-Date -Format "yyyyMMdd_HHmmss_fff") + ".bin")
        }
        return $name
    } catch {
        return ("fil_" + (Get-Date -Format "yyyyMMdd_HHmmss_fff") + ".bin")
    }
}

function Format-Size([long]$bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes/1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes/1MB) }
    elseif ($bytes -ge 1KB) { "{0:N0} KB" -f ($bytes/1KB) }
    else { "$bytes B" }
}

function Format-Rate([double]$bytesPerSec) {
    if ($bytesPerSec -ge 1GB) { "{0:N2} GB/s" -f ($bytesPerSec/1GB) }
    elseif ($bytesPerSec -ge 1MB) { "{0:N2} MB/s" -f ($bytesPerSec/1MB) }
    elseif ($bytesPerSec -ge 1KB) { "{0:N0} KB/s" -f ($bytesPerSec/1KB) }
    else { "{0:N0} B/s" -f $bytesPerSec }
}

# --- Setup ---
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
if (-not (Test-Path $ListPath)) {
    Write-Host "Kan ikke finde $ListPath" -ForegroundColor Red
    Pause
    exit 1
}

$links = Get-Content -Path $ListPath | ForEach-Object { $_.Trim() } | Where-Object {
    $_ -and -not $_.StartsWith("#")
}

# --- Download én ad gangen med live status på én linje ---
foreach ($url in $links) {
    $fileName = Get-FileNameFromUrl $url
    $outFile  = Join-Path $OutDir $fileName

    # Start download
    try {
        $req = [System.Net.HttpWebRequest]::Create($url)
        $req.Method = "GET"
        $resp = $req.GetResponse()
        $total = $resp.ContentLength               # kan være -1 (ukendt)
        $inStr = $resp.GetResponseStream()
        $outStr = [System.IO.File]::Create($outFile)

        $buf = New-Object byte[] $BufferSz
        $readTotal = 0L

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $lastUpdate = [TimeSpan]::Zero

        # Skriv første statuslinje (tom, samme linje genbruges)
        $base = "Henter: $fileName"
        Write-Host ($base + " ...") -NoNewline

        while (($read = $inStr.Read($buf, 0, $buf.Length)) -gt 0) {
            $outStr.Write($buf, 0, $read)
            $readTotal += $read

            # Opdater status max ~5 gange/sekund
            if ($sw.Elapsed - $lastUpdate -gt [TimeSpan]::FromMilliseconds(200)) {
                $lastUpdate = $sw.Elapsed
                $elapsedSec = [math]::Max($sw.Elapsed.TotalSeconds, 0.001)
                $rate = $readTotal / $elapsedSec

                if ($total -gt 0) {
                    $pct = [math]::Round(($readTotal / $total) * 100)
                    $etaSec = [math]::Max(($total - $readTotal) / $rate, 0)
                    $status = ("`r{0}  {1}%  {2}/{3}  {4}  ETA {5:mm\:ss}" -f `
                        $base, $pct, (Format-Size $readTotal), (Format-Size $total), (Format-Rate $rate),
                        ([TimeSpan]::FromSeconds($etaSec)))
                } else {
                    # Ukendt total: vis kun hentet og hastighed
                    $status = ("`r{0}  {1}  {2}" -f $base, (Format-Size $readTotal), (Format-Rate $rate))
                }

                Write-Host $status -NoNewline
            }
        }

        # Luk streams
        $outStr.Close()
        $inStr.Close()
        $resp.Close()

        # Afslutningslinje (100% hvis total kendes)
        $elapsedSec = [math]::Max($sw.Elapsed.TotalSeconds, 0.001)
        $avgRate = $readTotal / $elapsedSec
        if ($total -gt 0) {
            $final = ("`r{0}  100%  {1}/{2}  {3}  {4}`n" -f $base, (Format-Size $readTotal), (Format-Size $total), (Format-Rate $avgRate), ("Færdig"))
        } else {
            $final = ("`r{0}  {1}  {2}  {3}`n" -f $base, (Format-Size $readTotal), (Format-Rate $avgRate), ("Færdig"))
        }
        Write-Host $final

    } catch {
        Write-Host ("`rHenter: {0}  FEJL: {1}`n" -f $fileName, $_.Exception.Message) -ForegroundColor Red
        if (Test-Path $outFile) { Remove-Item $outFile -Force -ErrorAction SilentlyContinue }
    }
}

