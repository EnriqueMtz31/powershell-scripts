while ($true)
{
  $usStr = Read-Host "Enter tag to replace"

  if (($usStr -match "work-items")) {
    Write-Host "Input already has 'work-items' in it" -BackgroundColor Red -ForegroundColor Black
  } elseif (!($usStr -match "user-stories")) {
    Write-Host "Input doesn't have 'user-stories' in it" -BackgroundColor Red -ForegroundColor Black
  } else {
    $usStr = $usStr.Replace("user-stories", "work-items")
    Set-Clipboard $usStr

    Write-Host "`"$($usStr)`" has been stored on clipboard" -ForegroundColor Green
  }
  
  Write-Host `n
}