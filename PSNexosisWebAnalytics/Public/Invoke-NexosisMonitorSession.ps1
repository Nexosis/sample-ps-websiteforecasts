
# Monitor a Session until it finishes.
Function Invoke-NexosisMonitorSession {
    Param(
        $sessionId
    )
    
    # Is the session complete (not running or in a cancled or error state?
    Write-Output "Monitoring session $sessionid"
    $sessionStatus = Get-NexosisSessionStatus -SessionId $sessionID

    # Loop / Sleep while we wait for model and predictions to be generated
    while ($sessionStatus -eq 'Started' -or $sessionStatus -eq "Requested") {
        Write-Output "Session Status is $sessionStatus. Rechecking in 10 seconds."
        Start-Sleep -Seconds 10
        $sessionStatus = (Get-NexosisSessionStatus -SessionId $sessionID)
    }

    Write-Output 'Session is complete. Checking if it was successful or in an error state.'
}
