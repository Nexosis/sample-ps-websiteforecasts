
# Using System.Windows.Forms and System.Windows.Forms.DataVisualization in .NET 3.5 
# to display a graph of the data
Function Invoke-NexosisGraphDataSets {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $historicalObservations,
        [Parameter(Mandatory=$true)]
        $sessionResults,
        [Parameter(Mandatory=$false)]
        [int]$chartHeight=600,
        [Parameter(Mandatory=$false)]
        [int]$chartWidth=1600,
        [string]$chartName,
        [string]$sessionResultInterval='day',
        [string]$timeStampColumnName='timestamp',
        [Parameter(Mandatory=$true)]
        [string]$targetColumnName,
        [Parameter(Mandatory=$false)]
        [int]$maxHistoricalObservationsToGraph=2000
    )
 
    $historicalData = (Get-NexosisFormatDataForGraphing -interval $sessionResultInterval `
                                                        -observations $historicalObservations `
                                                        -timeStampColumnName $timeStampColumnName `
                                                        -targetColumnName $targetColumnName ) `
                       | Select-Object -last $maxHistoricalObservationsToGraph

    # Convert Nexosis API Data to graphable dataset (dates converted to OADates)
    $predictedData = Get-NexosisFormatDataForGraphing -interval 'none' `
                                                      -observations $sessionResults `
                                                      -timeStampColumnName $timeStampColumnName `
                                                      -targetColumnName $targetColumnName

    # Create a chart and Chart Area
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea

    # Create two series
    $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $Series2 = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    # Enun ref's
    $ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]
    $ChartValueType = [System.Windows.Forms.DataVisualization.Charting.ChartValueType]
    $DateTimeIntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]

    $Series.ChartType = $ChartTypes::Line
    $Series.XValueType = $ChartValueType::Time
    $Series.YValueType = $ChartValueType::Int32


    $Series2.ChartType = $ChartTypes::Line
    $Series2.XValueType = $ChartValueType::Time
    $Series2.YValueType = $ChartValueType::Int32

    $ChartArea.AxisX.LabelStyle.Format = "yyyy-MM-dd"
    $ChartArea.AxisX.Interval = 1
    $ChartArea.AxisX.IntervalType = $DateTimeIntervalType::Months

    $Chart.Series.Add($Series)
    $Chart.Series.Add($Series2)
    $Chart.ChartAreas.Add($ChartArea)

    $Chart.Series['Series1'].Points.DataBindXY([double[]]$historicalData."$timeStampColumnName", [int[]]$historicalData."$targetColumnName")
    $Chart.Series['Series2'].Points.DataBindXY([double[]]$predictedData."$timeStampColumnName", [int[]]$predictedData."$targetColumnName")

    $Chart.Width = 1600
    $Chart.Height = 600
    $Chart.Left = 10
    $Chart.Top = 10
    $Chart.BackColor = [System.Drawing.Color]::White
    $Chart.BorderColor = 'Black'
    $Chart.BorderDashStyle = 'Solid'

    $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    $ChartTitle.Text = $chartName
    $Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
    $ChartTitle.Font =$Font
    $Chart.Titles.Add($ChartTitle)

    #region Windows Form to Display Chart
    $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
    [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
    $Form = New-Object Windows.Forms.Form
    $Form.Width = $Chart.Width + 50
    $Form.Height = $Chart.Height + 150
    $Form.controls.add($Chart)
    $Chart.Anchor = $AnchorAll
 
    # add a save button
    $SaveButton = New-Object Windows.Forms.Button
    $SaveButton.Text = "Save"
    $SaveButton.Top = $Chart.Height + 20
    $SaveButton.Left = 600
    $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    # [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $SaveButton.add_click({
    $Result = Invoke-SaveDialog
    If ($Result) {
        $Chart.SaveImage($Result.FileName, $Result.Extension)
    }
    })
 
    $Form.controls.add($SaveButton)
    $Form.Add_Shown({$Form.Activate()})
    [void]$Form.ShowDialog()
}