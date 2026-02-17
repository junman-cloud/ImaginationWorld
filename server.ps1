$port = 8000
$root = "c:\Users\junai\OneDrive\Desktop\JUNAID\Imagination World"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
} catch {
    Write-Host "Port 8000 is busy. Trying 8080."
    $port = 8080
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

Write-Host "Server started at http://localhost:$port/"
Write-Host "Press Ctrl+C to stop."

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $path = $root + $request.Url.LocalPath.Replace("/", "\")
    
    if (Test-Path $path -PathType Container) {
        $path += "\Imagination world.html"
    }

    if (Test-Path $path -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $response.ContentLength64 = $bytes.Length
        
        $ext = [System.IO.Path]::GetExtension($path).ToLower()
        switch ($ext) {
            ".html" { $response.ContentType = "text/html" }
            ".css"  { $response.ContentType = "text/css" }
            ".js"   { $response.ContentType = "application/javascript" }
            ".png"  { $response.ContentType = "image/png" }
            ".jpg"  { $response.ContentType = "image/jpeg" }
            ".jpeg" { $response.ContentType = "image/jpeg" }
            default { $response.ContentType = "application/octet-stream" }
        }
        
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }
    $response.Close()
}
