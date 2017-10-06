Function Get-BdeHDCfgDriveInfo
{
    <#
    .SYNOPSIS
        Gets and returns driveinfo from BdeHdCfg.exe
    .DESCRIPTION
        This one-trick-pony runs BdeHdCfg.exe -driveinfo and formats
        the results into either $null (the drive is ready), or into
        objects with information about each drive.

        If an object is returned it will have these properties:
            Target    
            SizeMB
            Command
            MaxShrink
            ExitCode

        TARGET is the string that will need to provided to BdeHDcfg as the
        value of the -target argument
        BdeHdCfg -target [default] [unallocated] [DriveLetter shrink] [DriveLetter merge]
        
        SIZEMB is the size of the partition in MB

        COMMAND is the command to be run on the TARGET, and will generally
        be 'shrink' or 'merge'

        MAXSHRINK is the maximum amount (in MB) that a drive can be shrunk 
        using BdeHdCfg to create a BitLocker partition
        BdeHdCfg -target [default] [unallocated] [DriveLetter shrink] -size [SizeinMegabytes]

        EXITCODE The return code from BdeHdCfg. This will be an Int32,
        and can be converted to HEX in by: '{0:x}' -f $Obj.ExitCode
    .LINK
        https://technet.microsoft.com/en-us/library/ee732026(v=ws.10).aspx
    #>
    # Gather drive info
    $CommandOutput = Invoke-Expression 'bdehdcfg.exe -driveinfo'
    
    # If the last command exited with [int32] -1063256062, the drive is ready
    # for BitLocker
    if ($LASTEXITCODE -eq [int32]-1063256062) {
       Write-Output $LASTEXITCODE
    }
    # The drive isn't ready. Take the output of the -driveinfo command and
    # convert it to objects for consumption later
    else { 
       $CommandOutput = $CommandOutput | Where-Object { $PSItem.Length -gt 1 }
       foreach ($line in $CommandOutput) {
           if ($line.Length -eq 0) { continue }
           if (($line -match 'merge|shrink') -and (!$line.StartsWith('VALID'))) { 
               $Pieces = $line -split ' ' | Where-Object { $PSItem.Length -gt 0 }
               if ($Pieces) { 
                  $Return = [PSCustomObject] @{
                              'Target'    = $Pieces[0]
                              'SizeMB'    = [math]::Truncate($Pieces[1] / 1MB)
                              'Command'   = $Pieces[2]
                              'MaxShrink' = if($Pieces[3] -eq '---') { $null } else { $Pieces[3] }
                              'ExitCode'  = $LASTEXITCODE
                            }
                  Write-Output $Return
               }
           }
       }
    }
}