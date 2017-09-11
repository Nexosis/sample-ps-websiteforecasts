Function Invoke-NexosisGraphDataSetAndSession {
    # Prompt which dataset to graph
    $dataSet = Invoke-NexosisDataSetChooser

    # download all the data for the given dataSet
    $dataSetObservations = (Get-NexosisAllDataSetData -dataSetName $dataSet.dataSetName)
    
    # For the given dataSet, prompt which session to graph
    $session = Invoke-NexosisSessionChooser -dataSourceName $dataSet.DataSetname 
    
    # Make a pretty graph
    Invoke-NexosisGraphDataSets -historicalObservations $dataSetObservations `
                         -sessionResults $session.data `
                         -chartHeight 600 `
                         -chartWidth 1600 `
                         -chartName 'Session forecast' `
                         -sessionResultInterval $session.resultInterval `
                         -targetColumnName 'Sessions'

}