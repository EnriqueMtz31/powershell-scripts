while ($true)
{
  $usStr = Read-Host "Enter tag to replace"

  if (($usStr -match "work-items")) {
    Write-Host "Input already has 'work-items' in it" -BackgroundColor Red -ForegroundColor Black
  } elseif (!($usStr -match "user-story")) {
    Write-Host "Input doesn't have 'user-story' in it" -BackgroundColor Red -ForegroundColor Black
  } else {
    $usStr = $usStr.Replace("user-story", "work-items")
    Set-Clipboard $usStr

    Write-Host "`"$($usStr)`" has been stored on clipboard" -ForegroundColor Green
  }
  
  Write-Host `n
}