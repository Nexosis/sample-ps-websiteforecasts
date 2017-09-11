Function Invoke-NexosisUploadAnalyticsCsv {
<# 
 .Synopsis  
  Uploads data from a google analytics CSV File to the nexosis API
  If you submit to the same dataset name, it will update the data
  using the csv.
  
 .Description
  Uploads data from a google analytics CSV File to the nexosis API
  If you submit to the same dataset name, it will update the data
  using the csv.
  
 .Parameter DataSetName
  Name of the dataset to download

 .Parameter SleepTime
  Time in milliseconds to sleep between requests. Defaults to 500ms.

 .Link
  http://docs.nexosis.com/clients/powershell

 .Example
 Get-NexosisAllAnalyticsData -dataSetName 'webSiteTraffic'
#>
    [CmdletBinding()]
    Param(
      [string]$sourceAnalyticsFile,
      [string]$dataSetName,
      [int]$numObservationsToSubmit=-1
    )
    
      # Does DataSet exist?
      if ((Get-NexosisDataSet -partialName $dataSetName).Count -eq 0) {
          "Dataset $dataSetName already exists. Updating existing dataset." | Write-Host
      }
      
      if ((Test-Path $sourceAnalyticsFile) -ne $true) {
        throw "File $sourceAnalyticsFile not found."
      }

      $fileParts = Get-ChildItem $sourceAnalyticsFile | Select-Object BaseName,Extension
      # TODO: Batch upload instead
      $preppedCsvOutputFile = ".\$($fileParts.BaseName)-TEMP$($fileParts.Extension)"
      
      # Create Regex with 6 groups to capture date parts and re-combine them in the needed format
      $regex = '^# (\d{4})(\d{2})(\d{2})-(\d{4})(\d{2})(\d{2})$'
  
      'Reading Google Analytics date range from header...' | Write-Host
      # read in the Analytics Date Range from the google analytics CSV header on line 3
      $line3 = Get-Content $sourceAnalyticsFile | Select-Object -index 3
      $minDate = $line3 -replace $regex, '$1-$2-$3'
      $maxDate = $line3 -replace $regex, '$4-$5-$6' 
      "CSV Starts on date $minDate and ends on $maxDate." | Write-Host
  
      "Processing CSV File..." | Write-Host
      # Create CSV file converting Hour Index to DateTime, discard any row that 
      # doesn't match regex '^\d+,\d+$'
      $websiteDataObservations = Get-Content $sourceAnalyticsFile `
                                      | select-string -pattern '^\d+,\d+$' `
                                      | ConvertFrom-Csv -header @('HourIndex','Sessions') `
                                      | Select-Object  @{label='timestamp'; `
                                                      expression = { ([DateTime](get-date $minDate).AddHours($_.HourIndex).ToString("o"))}`
                                                  }, `
                                                  @{label='Sessions'; `
                                                      expression = {[int]$_.Sessions}`
                                                  } 
  
      "Parsed $(($websiteDataObservations | Measure-Object).Count) records." | Write-Host
      # No, create it from source files.
      "Uploading Dateset $dataSetName..." | Write-Host
  
      if ($numObservationsToSubmit -eq -1) {
        # Create CSV to submit to Nexosis API
        Out-File -FilePath $preppedCsvOutputFile -Encoding ascii -InputObject $($websiteDataObservations | ConvertTo-Csv -NoTypeInformation)
      } else {
        # Create CSV to submit to Nexosis API
        Out-File -FilePath $preppedCsvOutputFile -Encoding ascii -InputObject $($websiteDataObservations | Select-Object -last $numObservationsToSubmit | ConvertTo-Csv -NoTypeInformation)
        #$websiteDataObservations | Select-Object -last $numObservationsToSubmit | ConvertTo-Csv -NoTypeInformation  > $preppedCsvOutputFile
      }
  
      # Import CSV to Nexosis API Dataset
      Import-NexosisDataSetFromCsv -dataSetName $dataSetName -csvFilePath $preppedCsvOutputFile
  
      "Successfully uploaded Google Analytics csv." | Write-Host
      # delete temp file
      Remove-Item $preppedCsvOutputFile
  }
  