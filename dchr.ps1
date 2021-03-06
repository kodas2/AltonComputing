if (Test-Path "C:\Users\$env:username\Downloads\chrome") {
    & "C:\Users\$env:username\Downloads\chrome\App\Chrome-bin\chrome.exe" "--allow-outdated-plugins"
    Exit
}

function Expand-ZIPFile($file, $destination) {
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}

$client = New-Object System.Net.WebClient
$client.DownloadFileAsync("https://github.com/kodas2/AltonComputing/archive/master.zip", "C:\Users\$env:username\Downloads\master.zip")

Register-ObjectEvent -InputObject $client -EventName "DownloadProgressChanged" -SourceIdentifier "download_progress" -Action {
    Write-Progress -Activity "Chrome Download" -Status "Downloading..." -PercentComplete $EventArgs.ProgressPercentage -SecondsRemaining -1
}

Register-ObjectEvent -InputObject $client -EventName "DownloadFileCompleted" -SourceIdentifier "download_complete"
Wait-Event -SourceIdentifier "download_complete"
Write-Host DONE

Write-Progress -Activity "Chrome Download" -Status "Downloading..." -PercentComplete -1 -SecondsRemaining -1 -Completed

Unregister-Event "download_complete"
Unregister-Event "download_progress"

New-Item "C:\Users\$env:username\Downloads\temp1" -type directory
Expand-ZIPFile -File "C:\Users\$env:username\Downloads\master.zip" -Destination "C:\Users\$env:username\Downloads\temp1"
New-Item "C:\Users\$env:username\Downloads\chrome" -type directory
Expand-ZIPFile -File "C:\Users\$env:username\Downloads\temp1\AltonComputing-master\app.zip" -Destination "C:\Users\$env:username\Downloads\chrome"

Remove-Item -Recurse "C:\Users\$env:username\Downloads\temp1"
Remove-Item "C:\Users\$env:username\Downloads\master.zip"

& "C:\Users\$env:username\Downloads\chrome\App\Chrome-bin\chrome.exe" "--allow-outdated-plugins"