$ErrorActionPreference = "Stop"
try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.DisplayAlerts = "ppAlertsNone"
    
    $presentation = $ppt.Presentations.Open("C:\MyProjects\Dastra v1\test.pptx", $true, $false, $false)
    $presentation.SaveAs("C:\MyProjects\Dastra v1\test_ppt.pdf", 32)
    $presentation.Close()
    
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($presentation) | Out-Null
} catch {
    Write-Error $_
    exit 1
} finally {
    if ($ppt) {
        $ppt.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
