
# Provides a way to visually choose a dataset. Returns a dataSetData object containing all the
# data in the dataset
Function Invoke-NexosisDataSetChooser {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        $partialName,
        [switch]$noData
    )
    $dataSets = (Get-NexosisDataSet -partialName $partialName) 
    # build a table of dataSets to choose from
    $script:rowCount=0;
    $dataSets `
        | Select-Object @{
                    name='#';
                        expression={
                            $script:rowCount;$script:rowCount++
                            }
                        },
                        dataSetName `
        | Format-Table `
        | Out-String `
        | ForEach-Object { Write-Host $_ }
    
   if ($dataSets.Count -eq 0) {
        "No datasets were found." | Write-Host
        return $null
   }
   do {
        $result = Read-Host 'Which dataset would you like to return? (ctrl-c to exit)'

         if ($result -ge ($dataSets.Count - 1)) {
            break;
         }

    } while (-not ($result -match '\d{1,}'))

    if ($noData) {
        $dataSets[$result]
    } else {
        Get-NexosisAllDataSetData -dataSetName  $dataSets[$result].dataSetName
    }
}