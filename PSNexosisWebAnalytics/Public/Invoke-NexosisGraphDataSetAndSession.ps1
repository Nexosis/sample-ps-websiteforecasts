Function Invoke-NexosisGraphDataSetAndSession {
    # Prompt which dataset to graph
    $dataSet = Invoke-NexosisDataSetChooser -noData
    
    # For the given dataSet, prompt which session to graph
    $session = Invoke-NexosisSessionChooser -dataSourceName $dataSet.DataSetname 
   
    if ($session.status -eq 'completed') {
        "Retrieving historical observations..." | Write-Host
        # Retrieve all data for dataset to graph
        $dataSetObservations = Get-NexosisAllDataSetData -dataSetName $dataSet.DataSetname 

        # Make a pretty graph
        Invoke-NexosisGraphDataSets -historicalObservations $dataSetObservations.data `
                            -sessionResults $session.data `
                            -chartHeight 600 `
                            -chartWidth 1600 `
                            -chartName 'Session forecast' `
                            -sessionResultInterval $session.resultInterval `
                            -targetColumnName 'Sessions'
    } else {
        "Session $($session.sessionId) not complete. Last session status was '$($session.status)'" | Write-Host
    }
}