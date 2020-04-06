[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $debugOnly = $Env:INPUT_DEBUGONLY

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: listSystemInfo.ps1"
    Write-Output "##vso[task.debug]  debugOnly: $debugOnly"
}

if ($debugOnly -ne "true" -or ($debugOnly -eq "true" -and $Env:SYSTEM_DEBUG -eq "true")) {
    $timeZoneInfo = [TimeZoneInfo]::Local
    $computer = Get-CimInstance "Win32_ComputerSystem"
    $os = Get-CimInstance "Win32_OperatingSystem"

    @(
        " "
        "COMPUTER"
        "--------"
        "Domain\Name                   {0}\{1}" -f $computer.Domain, $computer.Name
        "Manufacturer                  {0}" -f $computer.Manufacturer
        "Model                         {0}" -f $computer.Model
        "Family                        {0}" -f $computer.SystemFamily
        "Type                          {0}" -f $computer.SystemType
        "# Processors                  {0}" -f $computer.NumberOfProcessors
        "# Logical Processors          {0}" -f $computer.NumberOfLogicalProcessors
        "Hypervisor                    {0}" -f $computer.HypervisorPresent
        "User Name                     {0}" -f $computer.UserName

        " "
        "OPERATING SYSTEM"
        "----------------"
        "Name                          {0}" -f $os.Caption
        "Manufacturer                  {0}" -f $os.Manufacturer
        "Architecture                  {0}" -f $os.OSArchitecture
        "Version (SP)                  {0} ({1}.{2})" -f $os.Version, $os.ServicePackMajorVersion, $os.ServicePackMinorVersion
        "OS Install Date               {0}" -f $os.InstallDate
        "Last Bootup Time              {0}" -f $os.LastBootUpTime
        "Local Date Time               {0}" -f $os.LocalDateTime
        "Up Time                       {0}" -f ($os.LocalDateTime - $os.LastBootUpTime)
        "MUI Languages                 {0}" -f $os.MUILanguages
        "Language / Locale             {0} / {1}" -f $os.OSLanguage, $os.Locale
        "Windows Directory             {0}" -f $os.WindowsDirectory
        "System Directory              {0}" -f $os.SystemDirectory

        " "
        "TIME ZONE INFORMATION"
        "---------------------"
        "Id                            {0}" -f $timeZoneInfo.Id
        "DisplayName                   {0}" -f $timeZoneInfo.DisplayName
        "StandardName                  {0}" -f $timeZoneInfo.StandardName
        "DaylightName                  {0}" -f $timeZoneInfo.DaylightName
        "BaseUtcOffset                 {0}" -f $timeZoneInfo.BaseUtcOffset
        "Supports Daylight Saving Time {0}" -f $timeZoneInfo.SupportsDaylightSavingTime

        " "
        "SYSTEM MEMORY"
        "-------------"
        "Total Physical Memory         {0:N1}GB" -f ($computer.TotalPhysicalMemory / 1073741824)
        "Total Visible Memory          {0:N1}GB" -f ($os.TotalVisibleMemorySize / 1048576)
        "Total Virtual Memory          {0:N1}GB" -f ($os.TotalVirtualMemorySize / 1048576)
        "Free Physical Memory          {0:N1}GB" -f ($os.FreePhysicalMemory / 1048576)
        "Free Virtual Memory           {0:N1}GB" -f ($os.FreeVirtualMemory / 1048576)
        "Free Space In Paging Files    {0:N1}GB" -f ($os.FreeSpaceInPagingFiles / 1048576)
        "Stored In Paging Files        {0:N1}GB" -f ($os.SizeStoredInPagingFiles / 1048576)

        " "
        "ROOT     VOLUME                   FREE (GB)     TOTAL (GB)"
        "----     ------                   ---------     ----------"
    ) | Write-Output


    Get-PSDrive -PSProvider "FileSystem" `
    | ForEach-Object {
        "{0,-4}     {1,-20}     {2,9:N1}      {3,9:N1}" -f $_.Name, $_.Description, ($_.Free / 1073741824), (($_.Free + $_.Used) / 1073741824)
    } | Write-Output
}
