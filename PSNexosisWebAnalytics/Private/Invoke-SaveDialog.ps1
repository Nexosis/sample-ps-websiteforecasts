
# prompts a dialog so you can save an image of the generated chart
Function Invoke-SaveDialog {
    # Generate filetypes based on support export times from DataViz library
    $FileTypes = [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat') `
                                            | ForEach-Object {
        $_.Insert(0,'*.')
    }
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.DefaultExt='PNG'
    $dialog.Filter="Image Files ($($FileTypes))|$($FileTypes)|All Files (*.*)|*.*"
    $result = $dialog.ShowDialog()
    If ($result -eq 'OK') {
        [pscustomobject]@{
            FileName = $dialog.FileName
            Extension = $dialog.FileName -replace '.*\.(.*)','$1'
        }
    }
}