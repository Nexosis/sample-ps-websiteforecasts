Function Get-NexosisFormatDataForGraphing {
<# 
 .Synopsis
    This function assumes data is at hourly intervals and will aggrate it up to daily, monthly or yearly data.
    Additionally it converts the provided timestamp column to a OADate for graphing.

 .Description
    This function assumes data is at hourly intervals and will aggrate it up to daily, monthly or yearly data.
    Additionally it converts the provided timestamp column to a OADate  for graphing.

  .Parameter Interval
   Parameter 'interval' must be 'hour', 'day', 'month', 'year', or 'none'. If set to none or hour, the data
   isn not aggragated but the timestamp column is converted to OADate.

  .Parameter Observations
   A dataset containing the observations to format for graphing.

  .Parameter TimeStampColumnName
   The name of the TimeStamp column in the dataset. Defaults to 'timestamp'. Data will be group accordingly based on
   interval.
  
  .Parameter TargetColumnName
   The name of target column in the dataset that will be graphed. These values are aggraged based on interval.  
 
  .Link
   http://docs.nexosis.com/clients/powershell

  .Example

#>[CmdletBinding()]
    Param(
      [Parameter(Mandatory=$true)]
      [string]$interval,
      [Parameter(Mandatory=$true)]
      $observations,
      [Parameter(Mandatory=$false)]
      $timeStampColumnName='timestamp',
      [Parameter(Mandatory=$true)]
      $targetColumnName
    )
     
    if ($interval -ne 'hour' -and $interval -ne 'day' -and $interval -ne 'month' -and $interval -ne 'year' -and $interval -ne 'none') {
        throw "Parameter 'interval' must be 'hour', 'day', 'month', 'year', or 'none'"
    }
  
    switch ($interval.ToLower()) {
        "hour" {
            $observations | Select-Object @{label="$timeStampColumnName"; `
                                            expression = { [DateTime]::Parse($_."$timeStampColumnName").ToOADate() }`
                                           }, `
                                           @{label="$targetColumnName"; `
                                            expression = { [int]$_."$targetColumnName" } `
                                           } `
        }
        # Group hourly data into chunks using the date part, then sum those and convert dates to OADate.
        "day" {
            $observations | Select-Object @{Name="$timeStampColumnName"; `
                                          expression={([DateTime]$_."$timeStampColumnName").Date}
                                          }, `
                                          @{ `
                                          name="$targetColumnName"; `
                                          expression={$_."$targetColumnName"} `
                                      } `
                              | Group-Object "$timeStampColumnName" `
                              | ForEach-Object { `
                                    New-Object psobject -Property @{ `
                                                                      $timeStampColumnName = ([DateTime]$_.Name).ToOADate(); `
                                                                      $targetColumnName = ($_.Group | Measure-Object $targetColumnName -Sum).Sum `
                                                                  } `
                              }
        }
        "month" {
            $observations | Select-Object @{Name="$timeStampColumnName"; `
                                        expression={(([DateTime]$_."$timeStampColumnName").ToString("yyyy-MM-01"))}
                                        }, `
                                        @{ `
                                        name="$targetColumnName"; `
                                        expression={$_."$targetColumnName"} `
                                    } `
                                | Group-Object "$timeStampColumnName" `
                                | ForEach-Object { `
                                    New-Object psobject -Property @{ `
                                                                    $timeStampColumnName = ([DateTime]$_.Name).ToOADate(); `
                                                                    $targetColumnName = ($_.Group | Measure-Object $targetColumnName -Sum).Sum `
                                                                } `
                                }
      }
      "year" {
        $observations | Select-Object @{Name="$timeStampColumnName"; `
                                        expression={(([DateTime]$_."$timeStampColumnName").ToString("yyyy-01-01"))}
                                        }, `
                                        @{ `
                                        name="$targetColumnName"; `
                                        expression={$_."$targetColumnName"} `
                                    } `
                                | Group-Object "$timeStampColumnName" `
                                | ForEach-Object { `
                                    New-Object psobject -Property @{ `
                                                                    $timeStampColumnName = ([DateTime]$_.Name).ToOADate(); `
                                                                    $targetColumnName = ($_.Group | Measure-Object $targetColumnName -Sum).Sum `
                                                                } `
                                }
      }
      default 
      { 
          $observations | Select-Object @{label="$timeStampColumnName"; `
                                            expression = { [DateTime]::Parse($_."$timeStampColumnName").ToOADate() }`
                                        }, `
                                        @{label="$targetColumnName"; `
                                            expression = {[int]$_."$targetColumnName"} `
                                        } 
      }
    }
}