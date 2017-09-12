Function Get-NexosisAllDataSetData {
<# 
 .Synopsis
  Downloads all the records that have been submitted to the Nexosis API in 
  chunks of 1000, throttling requests to 2 a second.
  
 .Description
  Downloads all the records that have been submitted to the Nexosis API in 
  chunks of 1000, throttling requests to 2 a second.
  
 .Parameter DataSetName
  Name of the dataset to download

 .Parameter SleepTime
  Time in milliseconds to sleep between requests. Defaults to 500ms.

 .Link
  http://docs.nexosis.com/clients/powershell

 .Example
 Get-NexosisAllDataSetData -dataSetName 'webSiteTraffic'
#>[CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true)]
    [string]$dataSetName,
    [Parameter(Mandatory=$false)]
    [int]$sleepTimeMs=500
  )
      $currentPage = 0
      $data = $null
      # API only allows max 1000 records to be retrieved per page, so loop until retrieved all
      do {
          # fetch 1000 records at a time 
          if ($data -eq $null) {
            # First time around, populate all the top level fields and get 
            # the first page of data with up to 1000 records
            $data =  (Get-NexosisDataSetData -dataSetName $datasetName `
                                             -page $currentPage `
                                             -pageSize 1000)

            $numRecords = ($data.data | Measure-Object).Count
          } else {
            # Now just retrieve and then append the data array
            $fetchData = (Get-NexosisDataSetData -dataSetName $datasetName `
                                                 -page $currentPage `
                                                 -pageSize 1000
                         ).Data 

            # append retrieved data to master hashtable
            $data.data += $fetchData
            $numRecords = ($fetchData | Measure-Object).Count
          }

          Write-Verbose "Loaded $numRecords observations..."
          $currentPage++
          
          # spread the requests out over time to not spam requests
          Start-Sleep -Milliseconds 500
      } while ($numRecords -eq 1000)
                                           
      $numTotalRecords = ($data.data | Measure-Object).Count
      Write-Verbose "Loaded $numTotalRecords total observations."
      $data
}