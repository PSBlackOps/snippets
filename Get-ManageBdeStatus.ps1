function Get-ManageBDEStatus
{
    <#
    .SYNOPSIS
    Returns the output of manage-bde -status as a collection of objects.
    
    .DESCRIPTION
    Runs manage-bde.exe -status on a local computer and returns the BitLocker
    encryption status for all volumes on a host represented as a PowerShell
    custom object.

    Each member of the returned object is a hash table of status information.
    
    .EXAMPLE
    Get-ManageBDEStatus

    VolumeC                                                               VolumeD                                                               VolumeG
    -------                                                               -------                                                               -------
    {Conversion Status, Identification Field, Size, BitLocker Version...} {Conversion Status, Identification Field, Size, BitLocker Version...} {Conversion Status, Identification Field, Size, BitLocker Version...}
    
    #>

    $BdeStatus  = (manage-bde.exe -status) | Select-Object -Skip 5
    $Split      = $BdeStatus | Select-String -Pattern '^Volume'
    $Output     = [PSCustomObject] @{}

    # Loop through the split up array to split it up more
    for ($lineNo = 0; $lineNo -lt $Split.Count; $lineNo++) {
        $StartIndex = $Split[$lineNo].LineNumber 

        if (($lineNo + 1) -eq $Split.Count) {
            # Handle when index + 1 is out of range
            $StopIndex = $BdeStatus.Count - 1
        }
        else {
            $StopIndex = $Split[$lineNo + 1].LineNumber - 1
        }
                
        $Volume            = ($Split[$lineNo].Line -split ':')[0].replace(' ','')
        $VolumeInformation = $BdeStatus[$StartIndex..$StopIndex]
        $Properties        = @{}
        foreach ($Line in $VolumeInformation) {
            if (([string]::IsNullOrWhiteSpace($Line)) -or $Line -match 'Volume') {
                continue
            }
            elseif ($Line -match ':') {
                $Key,$Value = $Line -split ':'
                $Properties.Add($Key.Trim(), $Value.Trim())
            }
            
        }

        Add-Member -InputObject $Output -Name $Volume -MemberType NoteProperty -Value $Properties        
        
    }
    Write-Output $Output
}