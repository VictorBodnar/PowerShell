param(
    [Parameter(Mandatory=$true)]
    [string]$event
)
$key = "hNoX61DStAObpjckostomaJqKdwWWSvyhYL-Yugfq0c" # get yours from IFTTT.com

Invoke-WebRequest -URI "https://maker.ifttt.com/trigger/$event/with/key/$key"
