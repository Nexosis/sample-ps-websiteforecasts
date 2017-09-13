Function Invoke-NexosisGraphDataSetAndSession {
    # Prompt which dataset to graph
    $dataSet = Invoke-NexosisDataSetChooser -noData
    
    # For the given dataSet, prompt which session to graph
    $session = Invoke-NexosisSessionChooser -dataSourceName $dataSet.DataSetname 
   
    if ($session.status -eq 'completed') {
        "Retrieving historical observations..." | Write-Host
        # Retrieve all data for dataset to graph
        $dataSetObservations = Get-NexosisAllDataSetData -dataSetName $dataSet.DataSetname 
        # calculate how much data we want to show in the graph
        if ($session.resultInterval -eq 'hour') {
            # hourly show, a couple weeks
            $numObservations = (24*14)
        } elseif ($session.resultInterval -eq 'day') {
            # if it's day, show two years
            $numObservations = (365*2)
        } elseif ($session.resultInterval -eq 'month') {
            # if it's month, show 20 years
            $numObservations = (12*20)
        }  elseif ($session.resultInterval -eq 'year') {
            # if it's year, show last 100 years
            $numObservations = (100)
        }
        # Make a pretty graph
        Invoke-NexosisGraphDataSets -historicalObservations $dataSetObservations.data `
                            -sessionResults $session.data `
                            -chartHeight 600 `
                            -chartWidth 1600 `
                            -chartName 'Session forecast' `
                            -sessionResultInterval $session.resultInterval `
                            -targetColumnName 'Sessions' `
                            -maxObservationsToGraph $numObservations
    } else {
        "Session $($session.sessionId) not complete. Last session status was '$($session.status)'" | Write-Host
    }
}