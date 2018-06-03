param (
    [Parameter(Mandatory=$true)]
    [string]$event
)
$key = "hNoX61DStAObpjckostomav1pI0nWNeKFXWmop_TJNg"
(new-object net.webclient).DownloadString("https://maker.ifttt.com/trigger/$event/with/key/$key")