
Function Get-NexosisForecastDateRange {
<# 
 .Synopsis
  Given parameter `Observations` containing Nexosis DataSet Data, calculates a forecast
  range starting one interval (hour, day, month, year) after the last date in the supplied
  dataset as well as an end date - 

 .Description
  Given an object containing Nexosis observation data, returns start date one hour after the 
  final observation and the number of days to forecast after (defaults to 14 days).

  .Parameter Observations
   Object structure containing an Array of hashes that contain a `TimeStampColumnName`.

  .Parameter TimeStampColumnName
   Name of the Time Stamp column in the submitted dataset. Default is 'timestamp'

  .Parameter Interval
   Interval Unit used toto calculate the start and end forecast date times. Defaults to 'hour'

  .Parameter IntervalCount
   Number of days to forcast - added to last observation date in `Observations`. Defaults to 336 hours (14 days)
 
  .Link
   http://docs.nexosis.com/clients/powershell

  .Example
  Get-NexosisAnalyticsForecastDateRange -observations $observations -interval 'hour' -intervalCount (14*24)
  
Name                           Value
----                           -----
forecastStart                  2017-09-01T00:00:00.0000000
forecastEnd                    2017-09-12T23:00:00.0000000
#>[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $observations,
        [Parameter(Mandatory=$false)]
        [string]$timeStampColumnName='timestamp',
        [Parameter(Mandatory=$false)]
        [string]$interval='hour',
        [Parameter(Mandatory=$false)]
        $intervalCount=336
    )
    # maxDate set to last observation in the dataset.
    $maxDate = ($observations | Select-Object -last  1 @{label='timestamp';expression={$_."$timeStampColumnName" }}).timestamp.ToString("o")

    if ($interval -ne 'hour' -and $interval -ne 'day' -and $interval -ne 'month' -and $interval -ne 'year') {
        throw "Parameter 'interval' must be 'hour', 'day', 'month', or 'year"
    }

    switch ($interval.ToLower()) {
        'hour' {
            $startForecastDateTime = [DateTime]::Parse($maxDate).AddHours(1)
            # Start forecast ONE hour after end of observations
            $startForecastString = $startForecastDateTime.ToString("o")     
            # Forcast out X hours from one plus the last date in observations
            $endForecastString = $startForecastDateTime.AddHours($intervalCount).ToString("o")
          }
        'day' {
            $startForecastDateTime = [DateTime]::Parse($maxDate).AddDays(1)
            # Start forecast ONE day after end of observations
            $startForecastString = $startForecastDateTime.ToString("o")     
            # Forcast out X days from one plus the last date in observations
            $endForecastString = $startForecastDateTime.AddDays($intervalCount).ToString("o")
        }
        'month' {
            $startForecastDateTime = [DateTime]::Parse($maxDate).AddMonths(1)
            # Start forecast ONE month after end of observations
            $startForecastString = $startForecastDateTime.ToString("o")     
            # Forcast out X months from one plus the last date in observations
            $endForecastString = $startForecastDateTime.AddMonths($intervalCount).ToString("o")           
        }
        'year' {
            $startForecastDateTime = [DateTime]::Parse($maxDate).AddYears(1)
            # Start forecast ONE year after end of observations
            $startForecastString = $startForecastDateTime.ToString("o")     
            # Forcast out X years from one plus the last date in observations
            $endForecastString = $startForecastDateTime.AddYears($intervalCount).ToString("o")           
        }
    }

    return @{
                forecastStart = $startForecastString
                forecastEnd = $endForecastString
            }
}