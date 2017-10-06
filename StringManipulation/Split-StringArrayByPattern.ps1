function Split-ArrayByPattern
{
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline )]
        [string[]] $InputObject,
        [string] $Pattern
    )

    process {
        # Split the input object on pattern, and save the output.
        $Split  = $InputObject | Select-String -Pattern $Pattern

        # Prepare the output hash table.
        $Output = @{}

        for ($i = 0; $i -lt $Split.Count; $i ++) {
            # The InputObject array is 0 indexed, but the LineNumber property of 
            # the $Split variable is 1 indexed. Subtract 1 from LineNumber to get
            # the $Start.
            # 2 is subtracted from the next $Split array index number to account 
            # for manage-bde -status tendency to have extra whitespace at the end
            # of each drive's status.
            $Start = $Split[$i].LineNumber - 1
            $Stop  = $Split[$i + 1].LineNumber - 2
            
            # If $Stop loops around past the end of the array, set it to the end
            # of the array.
            if ($Stop -le 0) {
                $Stop = $InputObject.Count - 1
            }

            # Remove non-word characters to make a valid key for the output hash.
            $Key   = $InputObject[$Start] -replace '\W',''
            $Output.Add($Key, $InputObject[$Start..$Stop])
        }
        Write-Output $Output
    }
}