
# Monitor a Session until it finishes.
Function Invoke-NexosisMonitorSession {
    Param(
        $sessionId
    )
    
    # Is the session complete (not running or in a cancled or error state?
    "Monitoring session $sessionid" | Write-Host
    $sessionStatus = Get-NexosisSessionStatus -SessionId $sessionID

    # Loop / Sleep while we wait for model and predictions to be generated
    while ($sessionStatus -eq 'Started' -or $sessionStatus -eq "Requested") {
        Write-Progress -Activity "Waiting for session to complete..." `
                       -CurrentOperation "Polling..." `
                       -Status $sessionStatus
        Start-Sleep -Seconds 10
        $sessionStatus = (Get-NexosisSessionStatus -SessionId $sessionID)
    }

    Write-Progress -Activity "Session completed." `
                   -CurrentOperation "Done" `
                   -Status $sessionStatus
    "Session is done. Final status is '$($sessionStatus)'" | Write-Output
}
