# Human OS, local web build: a tiny web server that only listens on this
# computer (localhost) and opens the app in your browser. Nothing is sent
# anywhere. Close this window to stop it.
$ErrorActionPreference = 'Stop'
$port = 8765
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'app'))
$mime = @{
  '.html' = 'text/html; charset=utf-8'; '.js' = 'text/javascript'
  '.mjs' = 'text/javascript'; '.css' = 'text/css'; '.json' = 'application/json'
  '.wasm' = 'application/wasm'; '.png' = 'image/png'; '.ico' = 'image/x-icon'
  '.svg' = 'image/svg+xml'; '.otf' = 'font/otf'; '.ttf' = 'font/ttf'
  '.woff2' = 'font/woff2'; '.txt' = 'text/plain; charset=utf-8'
}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() } catch {
  Write-Host "Port $port is in use. Close the other Human OS window and try again."
  Write-Host "Port $port kullanimda. Diger Human OS penceresini kapatip tekrar dene."
  Read-Host 'Press Enter'
  exit 1
}
Write-Host "Human OS is running at http://localhost:$port/  (close this window to stop)"
Write-Host "Human OS su adreste calisiyor: http://localhost:$port/  (durdurmak icin bu pencereyi kapat)"
Start-Process "http://localhost:$port/"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ($rel -eq '') { $rel = 'index.html' }
    $full = [IO.Path]::GetFullPath((Join-Path $root $rel))
    if (-not $full.StartsWith($root) -or -not (Test-Path -LiteralPath $full -PathType Leaf)) {
      $ctx.Response.StatusCode = 404
      $ctx.Response.Close()
      continue
    }
    $type = $mime[[IO.Path]::GetExtension($full).ToLower()]
    if (-not $type) { $type = 'application/octet-stream' }
    $bytes = [IO.File]::ReadAllBytes($full)
    $ctx.Response.ContentType = $type
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
  } catch {
    try { $ctx.Response.Abort() } catch { }
  }
}
