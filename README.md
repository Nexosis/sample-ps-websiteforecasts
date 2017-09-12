# PSNexosisWebAnalytics

Nexosis API Client Sample for PowerShell showing how to use the Forecast and Impact with Google Analytics Web Site Data.

You can read more about the Nexosis API at https://developers.nexosis.com

Pull requests are welcome

## Getting Started

To get started, you'll need a Nexosis API account. Once you have an account you can [get your API Key here](https://developers.nexosis.com/developer). Next you can install the PSNexosisClient powershell module, clone this repo and Import the modules.

```powershell
PS> Install-Module -Name PSNexosisClient
PS> git clone https://github.com/Nexosis/sample-ps-websiteforecasts.git
PS> cd sample-ps-websiteforecasts
PS> Import-Module .\PSNexosisWebAnalytics
PS> $env:NEXOSIS_API_KEY = '<yourkeyhere>'
```

## Loading the Google Analytics Data from the Google Analytics CSV

Log into your Google Analytics account and Navigate to your Analytics Account for the Web Site you are interested in. Expand Audience in the Left Navigation and then choose Overview. Next, using the Date Selector in the upper right, choose a custom range using a year or two of data. More is ideally better - somewhere between one and two years is probably good enough. You can test which works better through trial and error.

Once the data range is selected, click the Export button above the Date Choser and select CSV. Save this file - we'll include sample data as well.

Here's an example of how Google Analytics stores their CSV, there's an Hour Index starting from the first date and it increments by adding one through the end of the file:

```csv
# ----------------------------------------	
# All Web Site Data	
# Audience Overview	
# 20150701-20170831	
# ----------------------------------------	
	
Hour Index, Sessions
0, 0
1, 0
2, 0
3, 0
4, 0
5, 0
6, 0
7, 0
8, 0
9, 0
10, 0
11, 0
12, 0
13, 0
...snip...
66820, 0
66821, 0
66822, 11
66823, 75
66824, 233
66825, 215
66826, 197
66827, 194
66828, 177
66829, 187
66830, 178
66831, 142
66832, 68
66833, 28
66834, 11
66835, 13
66836, 12
66837, 12
66838, 10
66839, 2
66840, 3
66841, 0
66842, 0
66843, 0
66844, 0
66845, 1
66846, 9
66847, 60
66848, 195
66849, 206
66850, 191
66851, 167
66852, 160
66853, 188
66854, 156
66855, 148
66856, 76
66857, 24
66858, 15
66859, 10
66860, 14
66861, 4
66862, 10
66863, 0
```

Once the CSV is saved, you can upload it to the API using a sample script I created called `Invoke-NexosisUploadAnalyticsCsv`:

```powershell
PS> Invoke-NexosisUploadAnalyticsCsv -dataSetName 'sampleWebSiteData' `
                                     -sourceAnalyticsFile 'path\to\AnalyticsFile.csv'
Dataset sampleWebData already exists. Updating existing dataset.
Reading Google Analytics date range from header...
CSV Starts on date 2015-07-01 and ends on 2017-08-31.
Processing CSV File...
Parsed 19032 records.
Uploading Dateset sampleWebData...

Successfully uploaded Google Analytics csv.
dataSetName   columns
-----------   -------
sampleWebData @{Sessions=; timestamp=}
```

Let's take a quick lok at the logic needed to import this CSV by taking a look at some of the code in `Invoke-NexosisUploadAnalyticsCsv.ps1`.

[Click here for the complete source of this powershell script:](https://github.com/Nexosis/sample-ps-websiteforecasts/blob/master/PSNexosisWebAnalytics/Public/Invoke-NexosisUploadAnalyticsCsv.ps1)

Here are some highlights of that command:

```powershell
# Line 3 (0 indexed) in the CSV contains the date range of hourly sessios in the file.
# (e.g. 20150701-20170831). Parse this with regular expressions and re-write then and 
# store them as 2015-07-01 and 2017-08-31 in $minDate and $maxDate. 
$line3 = Get-Content $sourceAnalyticsFile | Select-Object -index 3
# Create Regex with 6 groups to capture date parts and re-combine them in the needed format
$regex = '^# (\d{4})(\d{2})(\d{2})-(\d{4})(\d{2})(\d{2})$'
$minDate = $line3 -replace $regex, '$1-$2-$3'
$maxDate = $line3 -replace $regex, '$4-$5-$6' 
# Load the CSV file converting Hour Index to DateTime using $minDate and DateTime.AddHours()
# Discard any row that doesn't match the the regex '^\d+,\d+$'
$websiteDataObservations = Get-Content $sourceAnalyticsFile `
                                    | select-string -pattern '^\d+,\d+$' `
                                    | ConvertFrom-Csv -header @('HourIndex','Sessions') `
                                    | Select-Object  @{label='timestamp'; `
                                                    expression = { `
                                                        ([DateTime](get-date $minDate).AddHours($_.HourIndex).ToString("o"))}`
                                                }, `
                                                @{label='Sessions'; `
                                                    expression = {[int]$_.Sessions}`
                                                }

# Finally, write the file as a new CSV to submit. Limiting the number of rows
# to a limited amount. Setting $numObservationsToSubmit to ~12,000 equals 
# aprox 1.37 years of hourly observations
 Out-File -FilePath $preppedCsvOutputFile `
          -Encoding ascii `
          -InputObject $($websiteDataObservations `
                            | Select-Object -last $numObservationsToSubmit `
                            | ConvertTo-Csv -NoTypeInformation `
                        )

# Finally submit this new CSV to the Nexosis API
Import-NexosisDataSetFromCsv -dataSetName $dataSetName `
                             -csvFilePath $preppedCsvOutputFile
```

## Forecasting Web Sessions

Now that the data is in the API, we can build a forecast model. This is easily accomplished by calling `Start-NexosisForecastSession` with a forcast start and end date. I could look at the data to choose the start and end dates, but for fun, I wrote a method that will calculate a forcast range based on the data set called `Get-NexosisForecastDateRange`.

In this example, we retrieve the `sampleWebData`, pass it into our script to calculate start and end forcast dates for hourly intervals for 2 weeks (14 days * 24 hours) and then use that as the start and end dates for the forecast session:

```powershell
PS> $dataset = Get-NexosisAllDataSetData -dataSetName 'sampleWebData'
PS> $range = Get-NexosisForecastDateRange -observations $dataSet.data `
                                          -timeStampColumnName timestamp `
                                          -interval hour `
                                          -intervalCount (14*24)
PS> $range

Name                           Value
----                           -----
forecastEnd                    2017-09-15T00:00:00.0000000
forecastStart                  2017-09-01T00:00:00.0000000

PS> Start-NexosisForecastSession -dataSourceName 'sampleWebData'  `
                                 -targetColumn 'Sessions' `
                                 -startDate $range.forecastStart `
                                 -endDate $range.forecastEnd `
                                 -resultInterval Day

sessionId       : 015e766c-2430-46e5-9c22-68d6ba63c52e
type            : forecast
status          : requested
requestedDate   : 2017-09-12T14:09:12.240809+00:00
statusHistory   : {@{date=2017-09-12T14:09:12.240809+00:00; status=requested}}
extraParameters : 
messages        : {}
columns         : @{Sessions=; timestamp=}
dataSourceName  : sampleWebData
dataSetName     : sampleWebData
targetColumn    : Sessions
startDate       : 2017-09-01T00:00:00+00:00
endDate         : 2017-09-15T00:00:00+00:00
isEstimate      : False
resultInterval  : day
links           : {@{rel=results; href=https://api.uat.nexosisdev.com/v1/sessions/015e766c-2430-46e5-9c22-68d6ba63c52e/results}, @{rel=data; href=https://api.uat.nexosisdev.com/v1/data/sampleWebData}}
costEstimate    : 0.01 USD
```

## Waiting for Session To Complete

Since building a Time Series model is asynchronous, it goes off and does work and when it's done we can retrieve the results. 

Checking on the status of a Session is simple. The PSNexosisClient has a command called `Get-NexosisSessionStatus` that will return the status of the Session given a session Id - potential results are 'Started', 'Requested', 'Completed', 'Cancelled', 'Failed', and 'Estimated'.

To monitor a session, there's a sample command called `Invoke-NexosisMonitorSession` which monitors the session's status (10 second intervals) and return when the status is no longer 'Requested' or 'Started'.

```powershell
PS> Invoke-NexosisMonitorSession -sessionId 015e76da-da55-4db8-9e6b-cc480c726030
Monitoring session 015e76da-da55-4db8-9e6b-cc480c726030
Session completed. Final status is 'Completed'
```


Here's some of the internal code of `Invoke-NexosisMonitorSession` to show how to check session status. This will get current status and then poll every 10 seconds to see if it is in a state other than Requested or Started.

```powershell
$sessionStatus = Get-NexosisSessionStatus -SessionId $sessionID

# Loop / Sleep while we wait for model and predictions to be generated
while ($sessionStatus -eq 'Started' -or $sessionStatus -eq "Requested") {
    Start-Sleep -Seconds 10
    $sessionStatus = (Get-NexosisSessionStatus -SessionId $sessionID)
}
```

## Retrieve the Session Forecast Results



## Sample Module Commands 
List of all commands in this Sample Module

### Public Scripts
```powershell
Get-NexosisAllDataSetData
Get-NexosisForecastDateRange
Get-NexosisFormatDataForGraphing
Invoke-NexosisGraphDataSetAndSession
Invoke-NexosisGraphDataSets
Invoke-NexosisMonitorSession
Invoke-NexosisUploadAnalyticsCsv
```

### Private 

These are some non-exposed private scripts in the PS Module that are used to provide some PowerShell command line interface:

```powershell
Invoke-NexosisDataSetChooser
Invoke-NexosisSessionChooser
Invoke-SaveDialog
```