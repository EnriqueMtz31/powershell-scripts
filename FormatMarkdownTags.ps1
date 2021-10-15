$appDirEnums = @{"MAIN_MENU" = "mainmenu"; "SUB_MENU" = "submenu" }
$appCommandEnums = @{"GO_BACK" = ":gb"; "QUIT" = ":q" }

function Approve-StateString {
  param (
    $stateString
  )
  $states = $("to-dos", "active", "closed", "recycle-bin", "resolved", "UAT")
  [string[]] $arr = $stateString.Split(" ")

  if (!($arr.Count -match 2)) {
    return @{"isStringValid" = $false; "message" = "Error! You did not entered 2 options" }
  }
  elseif (!($arr[0] -match "^\d+$")) {
    return @{"isStringValid" = $false; "message" = "Error! You entered an invalid option. Is not a number" }
  }
  elseif (([int]$arr[0] -gt 7) -or ([int]$arr[0] -le 0)) {
    return @{"isStringValid" = $false; "message" = "Error! You entered an invalid option. There's no '$($arr[0])' option" }
  }
  elseif (!($null -ne ($states | Where-Object { $arr[1] -match $_ }))) {
    return @{"isStringValid" = $false; "message" = "Error! Tag doesn't have one of the listed options" }
  }

  return @{"isStringValid" = $true; }
}

function Invoke-AppCommands {
  param (
    $command,
    $appDir
  )

  if ($command -eq $appCommandEnums.QUIT) {
    Clear-Host
    Write-Host "Bye-bye"
    Start-Sleep 1
    Clear-Host
    exit
  }
  elseif ($command -eq $appCommandEnums.GO_BACK -and $appDir -eq $appDirEnums.SUB_MENU) {
    break
  }
}

do {
  Write-Host "What do you want to do?"
  Write-Host "`n1. Change work item/markdown state"
  Write-Host "2. Change 'user-stories' for 'work-items'"
  $op = Read-Host "Enter option"
  Invoke-AppCommands $op $appDirEnums.MAIN_MENU
  Clear-Host

  switch ($op) {
    1 {
      $states = $("to-dos", "active", "closed", "recycle-bin", "resolved", "UAT")
      while ($true) {
        for ($i = 0; $i -lt $states.Count; $i++) {
          Write-Host "$($i + 1). $($states[$i])"
        }
        Write-Host "Enter an option from above followed by the tag to replace it with the selected option`n(e.g. 1 hi/uoh/active/7352)"
        $usStr = Read-Host "Press '$($appCommandEnums.GO_BACK)' to go back to previous menu"

        Invoke-AppCommands $usStr $appDirEnums.SUB_MENU

        $validationObj = Approve-StateString $usStr

        if ($validationObj.isStringValid) {
          # Clear-Host
          $data = @{ "option" = ([int]$usStr.Split(" ")[0]) - 1; "tag" = $usStr.Split(" ")[1] }
          $stringToReplace = $states | Where-Object { $data.tag -match $_ }
          if ($stringToReplace.GetType().Name -eq "Object[]") {
            $stringToReplace = $stringToReplace[0]
          }

          $data.tag = $data.tag.Replace($stringToReplace, $states[$data.option])
          Set-Clipboard $data.tag

          Write-Host "`"$($data.tag)`" has been stored on clipboard" -ForegroundColor Green
          Start-Sleep -Seconds 1
        }
        else {
          Write-Host "$($validationObj.message)" -BackgroundColor Red -ForegroundColor Black
          Start-Sleep -Seconds 1
          Clear-Host
        }
      }
    }
    2 {
      while ($true) {
        Write-Host "Enter tag to replace (e.g. hi/user-stories/hey/)"
        $usStr = Read-Host "Press '$($appCommandEnums.GO_BACK)' to go back to previous menu"

        Invoke-AppCommands $usStr $appDirEnums.SUB_MENU

        if (($usStr -match "work-items")) {
          Write-Host "Input already has 'work-items' in it" -BackgroundColor Red -ForegroundColor Black
        }
        elseif (!($usStr -match "user-stories")) {
          Write-Host "Input doesn't have 'user-stories' in it" -BackgroundColor Red -ForegroundColor Black
        }
        else {
          $usStr = $usStr.Replace("user-stories", "work-items")
          Set-Clipboard $usStr

          Write-Host "`"$($usStr)`" has been stored on clipboard" -ForegroundColor Green
        }
  
        Write-Host `n
      }
    }
    Default {
      Write-Host "No such option`nGoing back to menu" 
      Start-Sleep -Seconds 2
    }
  }

  Clear-Host
} while ($true)