
# Provides a way to visually choose a Session. Returns a SessionResult object containing data
# if it's completed.
Function Invoke-NexosisSessionChooser {
    Param(
        $dataSourceName
    )

    $sessionResponse = (Get-NexosisSession -dataSourceName $dataSourceName)
    # build a table of sessions to choose from
    $script:rowCount=0;
    $sessionResponse | Select-Object @{
                                        name='#';
                                            expression={
                                                $script:rowCount;$script:rowCount++
                                            }
                                      },
                                      dataSourceName,
                                      type,
                                      resultInterval, 
                                      @{
                                        name='startDate';
                                        expression={ ([DateTime]$_.startDate).Date}
                                      },
                                      @{
                                        name='endDate';
                                        expression={ ([DateTime]$_.endDate).Date}
                                      },
                                      status `
                    | Format-Table `
                    | Out-String `
                    | ForEach-Object { Write-Host $_ }

   do {
        $result = Read-Host 'Which session would you like to return? (ctrl-c to exit)'

         if ($result -ge $sessionResponse.Count)  {
            $result = $null
            continue;
         }

    } while (-not ($result -match '\d{1,}'))

    Return Get-NexosisSessionResult -SessionId $sessionResponse[$result].sessionId
}