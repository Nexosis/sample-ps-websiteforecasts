#Requires -Version 3.0
#Requires -Module 'PSNexosisClient'
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

$moduleVersion = (Test-ModuleManifest -Path $PSScriptRoot\PSNexosisWebAnalytics.psd1).Version

Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Requires .NET Framework: .NET Framework 3.5 SP1
# And 'Microsoft Chart Controls for Microsoft .NET Framework 3.5'
# https://www.microsoft.com/en-us/download/details.aspx?id=14422
# For other platforms look into OxyPlot https://github.com/oxyplot/oxyplot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# Export all public functions
Export-ModuleMember -Function $Public.Basename