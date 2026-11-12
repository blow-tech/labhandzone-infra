$ErrorActionPreference='Stop'
$scriptPath=Join-Path $PSScriptRoot 'storage-preflight.fixture.ps1'
$e=$null;$t=$null;$null=[Management.Automation.Language.Parser]::ParseFile($scriptPath,[ref]$t,[ref]$e)
if($e.Count){throw ($e|Out-String)}
$Ansible=@{Changed=$false}
$global:FixtureBoot=$false
function Get-Disk {
 [pscustomobject]@{UniqueId='approved-a';Number=1;Size=100;IsBoot=$global:FixtureBoot;IsSystem=$false;PartitionStyle='GPT';IsOffline=$false;IsReadOnly=$false}
 [pscustomobject]@{UniqueId='approved-b';Number=2;Size=200;IsBoot=$false;IsSystem=$false;PartitionStyle='GPT';IsOffline=$false;IsReadOnly=$false}
 [pscustomobject]@{UniqueId='unrelated';Number=3;Size=200;IsBoot=$false;IsSystem=$false;PartitionStyle='RAW';IsOffline=$true;IsReadOnly=$false}
}
function Get-Partition {param($DriveLetter) [pscustomobject]@{DiskNumber=$(if($DriveLetter -eq 'Q'){1}else{2})}}
function Get-Volume {[pscustomobject]@{FileSystem='NTFS';HealthStatus='Healthy'}}
function Initialize-Disk {throw 'Mutation must never be called'}
function Format-Volume {throw 'Mutation must never be called'}
$valid='[{"UniqueId":"approved-a","SizeBytes":100,"DriveLetter":"Q"},{"UniqueId":"approved-b","SizeBytes":200,"DriveLetter":"S"}]'
& $scriptPath -ManifestJson $valid
if($Ansible.Changed){throw 'Read-only preflight marked change'}
foreach($bad in @('[]',$valid.Replace('approved-b','unrelated'),$valid.Replace('approved-b','approved-a'),$valid.Replace('200','201'))){
 $failed=$false;try{& $scriptPath -ManifestJson $bad}catch{$failed=$true}
 if(-not $failed){throw 'Invalid storage manifest was accepted'}
}
$global:FixtureBoot=$true;$failed=$false;try{& $scriptPath -ManifestJson $valid}catch{$failed=$true}
if(-not $failed){throw 'Boot disk was accepted'}
Write-Output 'PASS exact disk identity, unrelated RAW disk, duplicate/size/empty manifest and boot-disk rejection.'
