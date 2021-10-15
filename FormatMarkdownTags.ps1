$appDirEnums = @{"MAIN_MENU" = "mainmenu"; "SUB_MENU" = "submenu" }
$appCommandEnums = @{"GO_BACK" = ":gb"; "QUIT" = ":q" }
$modules = $(
  "Change work item/markdown state",
  "Change 'user-stories' for 'work-items'",
  "Create tag for work item",
  "Modify tag template"
)
$states = $("to-dos", "active", "closed", "recycle-bin", "resolved", "UAT")
$tagTemplate = "welk/ol2.0/work-items/{state}/{workitemnumber}"

function Get-ErrorMessage {
  param (
    $message
  )
  Write-Host "$($message)" -BackgroundColor Red -ForegroundColor Black
  Start-Sleep -Seconds 1
  Clear-Host
}

function Get-OptionMenu {
  param (
    $options
  )

  for ($i = 0; $i -lt $options.Count; $i++) {
    Write-Host "$($i + 1). $($options[$i])"
  }
}

function Set-ComingSoonMessage {
  Write-Host "Nothing here :) Feature is coming soon"
  Start-Sleep 1
}
function Approve-StateString {
  param (
    $stateString
  )
  [string[]] $arr = $stateString.Split(" ")

  if (!($arr.Count -match 2)) {
    return @{"isValid" = $false; "message" = "Error! You did not entered 2 options" }
  }
  elseif (!($null -ne ($states | Where-Object { $arr[1] -match $_ }))) {
    return @{"isValid" = $false; "message" = "Error! Tag doesn't have one of the listed options" }
  }
  elseif (!($selectedOption -match "^\d+$")) {
    return @{"isValid" = $false; "message" = "Error! You entered an invalid option. Is not a number" }
  }
  elseif (([int]$selectedOption -gt ($optionCount + 1)) -or ([int]$selectedOption -le 0)) {
    return @{"isValid" = $false; "message" = "Error! You entered an invalid option. There's no '$($arr[0])' option" }
  }

  return @{"isValid" = $true; }
}

function Approve-SelectedOption {
  param (
    $selectedOption,
    $optionCount
  )
  
  if (!($selectedOption -match "^\d+$")) {
    return @{"isValid" = $false; "message" = "Error! You entered an invalid option. Is not a number" }
  }
  elseif (([int]$selectedOption -gt ($optionCount + 1)) -or ([int]$selectedOption -le 0)) {
    return @{"isValid" = $false; "message" = "Error! You entered an invalid option. There's no '$($arr[0])' option" }
  }

  return @{"isValid" = $true; }
}

function Approve-NumberValidation {
  param (
    $value
  )
  if (!($value -match "^\d+$")) {
    return @{"isValid" = $false; "message" = "Error! You entered an invalid option. Is not a number" }
  }

  return @{"isValid" = $true; }
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
  Write-Host "What do you want to do?`n"
  Get-OptionMenu $modules
  $op = Read-Host "Enter option"

  Invoke-AppCommands $op $appDirEnums.MAIN_MENU
  Clear-Host

  switch ($op) {
    1 {
      while ($true) {
        Get-OptionMenu $states
        Write-Host "Enter an option from above followed by the tag to replace it with the selected option`n(e.g. 1 hi/uoh/active/7352)"
        $usStr = Read-Host "Press '$($appCommandEnums.GO_BACK)' to go back to previous menu"

        Invoke-AppCommands $usStr $appDirEnums.SUB_MENU

        $validationObj = Approve-StateString $usStr
        if ($validationObj.isValid) {
          Clear-Host

          $data = @{ "option" = ([int]$usStr.Split(" ")[0]) - 1; "tag" = $usStr.Split(" ")[1] }
          $stringToReplace = $states | Where-Object { $data.tag -match $_ }
          if ($stringToReplace.GetType().Name -eq "Object[]") {
            $stringToReplace = $stringToReplace[0]
          }

          Write-Host "Old tag: $($data.tag)" -BackgroundColor Yellow -ForegroundColor Black

          $data.tag = $data.tag.Replace($stringToReplace, $states[$data.option])
          Set-Clipboard $data.tag

          Write-Host "`"$($data.tag)`" has been stored on clipboard" -ForegroundColor Green
          Start-Sleep -Seconds 1
        }
        else {
          Get-ErrorMessage $validationObj.message
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
    3 {
      while ($true) {
        $workItemNumber = Read-Host "Write the work item number"
        Invoke-AppCommands $workItemNumber $appDirEnums.SUB_MENU
        $validationObj3 = Approve-NumberValidation $workItemNumber
        if ($validationObj3.isValid) {
          Get-OptionMenu $states
          $tagState = Read-Host "Select an option to insert it to the tag"

          Invoke-AppCommands $workItemNumber $appDirEnums.SUB_MENU

          $validationObjTagState = Approve-SelectedOption $tagState $states.Count

          if ($validationObjTagState.isValid) {
            $newTag = $tagTemplate.Replace("{state}", $states[[int]$tagState - 1])
            $newTag = $newTag.Replace("{workitemnumber}", $workItemNumber)
            Set-Clipboard $newTag

            Write-Host "`"$($newTag)`" has been stored on clipboard" -ForegroundColor Green
          }
          else {
            Get-ErrorMessage $validationObjTagState.message
          }
        }
        else {
          Get-ErrorMessage $validationObj3.message
        }
      }

      
    }
    4 {
      Set-ComingSoonMessage
    }
    Default {
      Write-Host "No such option`nGoing back to menu" 
      Start-Sleep -Seconds 2
    }
  }

  Clear-Host
} while ($true)
