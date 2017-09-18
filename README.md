# PSNexosisWebAnalytics

Nexosis API Client Sample for PowerShell showing how to use the Forecast and Impact with Google Analytics Web Site Data. 

[You can read more about this on our documentation site.](http://docs.nexosis.com/tutorials/websitetrafficforecasting)

You can read more about the Nexosis API at https://developers.nexosis.com

Pull requests are welcome

## Sample Module Commands 
List of all commands in this Sample Module

### Public Scripts
```powershell
Get-NexosisAllDataSetData
Invoke-NexosisGraphDataSetAndSession
Invoke-NexosisMonitorSession
Invoke-NexosisUploadAnalyticsCsv
```

### Private 

These are some non-exposed private scripts in the PS Module that are used to provide some PowerShell command line interface:

```powershell
Get-NexosisForecastDateRange
Get-NexosisFormatDataForGraphing
Invoke-NexosisDataSetChooser
Invoke-NexosisGraphDataSets
Invoke-NexosisSessionChooser
Invoke-SaveDialog
```