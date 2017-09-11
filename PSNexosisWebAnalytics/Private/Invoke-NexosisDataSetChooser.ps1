
# Provides a way to visually choose a dataset. Returns a dataSetData object containing all the
# data in the dataset
Function Invoke-NexosisDataSetChooser {
    Param(
        $partialName
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
    

   do {
        $result = Read-Host 'Which dataset would you like to return? (ctrl-c to exit)'

         if ($result -ge $dataSets.Count)  {
            $result = $null
            continue;
         }

    } while (-not ($result -match '\d{1,}'))

    Return Get-NexosisDataSetData -dataSetName  $dataSets[$result].dataSetName
}