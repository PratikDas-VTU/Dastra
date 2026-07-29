$ErrorActionPreference = "Stop"
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $doc = $word.Documents.Add()
    $doc.SaveAs([ref] "C:\MyProjects\Dastra v1\test_word.pdf", [ref] 17)
    $doc.Close([ref] 0)
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
} finally {
    if ($word) {
        $word.Quit([ref] 0)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
