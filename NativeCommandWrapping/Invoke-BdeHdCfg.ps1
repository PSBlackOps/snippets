Function Invoke-BdeHDCfg
{
    <#
    .SYNOPSIS
        Passes command strings to BdeHDCfg.exe, and returns the results.
    .DESCRIPTION
        Used for running BdeHdCfg in PowerShell scripts (duh). Wraps the
        resulting output from StdOut, as well as the exit code in an object
        for script/pipeline consumption.

        The returned object will have the following properties:
            Message
            ExitCode
            Arguments

        MESSAGE The redirected StdOut output from BdeHdCfg.
        
        EXITCODE The return code from BdeHdCfg. This will be an Int32,
        and can be converted to HEX in by: '{0:x}' -f $Obj.ExitCode
        
        ARGUMENTS The arguments that were provided to BdeHdCfg.
    .PARAMETER Command
        The command to be passed to BdeHdCfg. For command syntax, see:
        https://technet.microsoft.com/en-us/library/ee732026(v=ws.10).aspx 
    .LINK
        https://technet.microsoft.com/en-us/library/ee732026(v=ws.10).aspx
    #>
    param(
            [Parameter( Mandatory=$true )]
            [string] $Command
         )

    begin {}

    process {         
         # Create the output object
         $Output = [PSCustomObject] @{
                     'Message'    = ''
                     'ExitCode'   = ''
                     'Arguments'  = $Command
                   }
        # Run the command
        $CommandOutput = Invoke-Expression "bdehdcfg.exe $Command"
        $CommandOutput = $CommandOutput | Where-Object { $PSItem.Length -gt 1 }

        # Populate the output object
        $Output.Message  = $CommandOutput
        $Output.ExitCode = $LASTEXITCODE

        # Return the output object to the pipeline
        Write-Output $Output
    }
}