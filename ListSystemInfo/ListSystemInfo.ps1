[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    $debug = Get-VstsTaskVariable -Name "System.Debug" -AsBool
    if (!$debugOnly -or ($debugOnly -and $debug)) {
        Import-Module "$PSScriptRoot/ps_modules/Tools" -NoClobber

        Get-CimInstance "Win32_ComputerSystem" `
        | Format-List @(
            "Model" | New-Property -Name "Computer"
            "Manufacturer"
            "SystemType" | New-Property -Name "Type"
            "Name"
            "Domain"
            "PartOfDomain" | New-Property -Name "Part of Domain"
            "PrimaryOwnerName" | New-Property -Name "Primary Owner"
            "UserName" | New-Property -Name "User"
            "NumberOfProcessors" | New-Property -Name "Physical Processors"
            "NumberOfLogicalProcessors" | New-Property -Name "Logical Processors"
            "TotalPhysicalMemory" | New-Property -Name "Physical Memory" | ConvertTo-Unit GB
            "DaylightInEffect" | New-Property -Name "Daylight in Effect"
            "HypervisorPresent" | New-Property -Name "Hypervisor Present"
        ) | Write-Output

        Get-CimInstance "Win32_Processor" `
        | Format-Table @(
            "DeviceID" | New-Property -Name "Id"
            "Name" | New-Property -Name "Processor"
            "NumberOfCores" | New-Property -Name "Cores"
            "NumberOfLogicalProcessors" | New-Property -Name "Threads"
            "VirtualizationFirmwareEnabled" | New-Property -Name "Virtualization"
            "VMMonitorModeExtensions" | New-Property -Name "VM Monitor"
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "Win32_PhysicalMemory" `
        | Format-Table @(
            "DeviceLocator" | New-Property -Name "Id"
            "PartNumber" | New-Property -Name "Memory"
            "Capacity" | ConvertTo-Unit GB
            "Speed"
            "InterleavePosition" | New-Property -Name "Position"
        ) -AutoSize -Wrap | Write-Output

        Get-PhysicalDisk `
        | Format-Table @(
            "DeviceId" | New-Property -Name "Id"
            "Model" | New-Property -Name "Disk"
            "MediaType" | New-Property -Name "Type"
            "SpindleSpeed" | New-Property -Name "RPM"
            "BusType" | New-Property -Name "Bus"
            "Size" | ConvertTo-Unit GB
            "AllocatedSize" | New-Property -Name "Allocated" | ConvertTo-Unit GB
            "HealthStatus" | New-Property -Name "Status"
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "Win32_VideoController" `
        | Format-Table @(
            "DeviceID" | New-Property -Name "Id"
            "Name" | New-Property -Name "Video Controller"
            "AdapterRAM" | New-Property -Name "RAM" | ConvertTo-Unit GB
            New-Property { "{0} x {1}" -f $_.CurrentHorizontalResolution, $_.CurrentVerticalResolution } -Name "Resolution" -Alignment Right
            "CurrentBitsPerPixel" | New-Property -Name "Color Depth"
            "CurrentRefreshRate" | New-Property -Name "Refresh Rate"
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "Win32_DesktopMonitor" `
        | Format-Table @(
            "DeviceID" | New-Property -Name "Id"
            "Name" | New-Property -Name "Monitor"
            "MonitorType" | New-Property -Name "Type"
            "ScreenHeight" | New-Property -Name "Height"
            "ScreenWidth" | New-Property -Name "Width"
            "Bandwidth"
            New-Property { "{0} x {1}" -f $_.PixelsPerXLogicalInch, $_.PixelsPerYLogicalInch } -Name "Pixels/Logical Inch" -Alignment Right
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "WmiMonitorBasicDisplayParams" -Namespace "root/wmi" `
        | Format-Table @(
            "InstanceName" | New-Property -Name "Id"
            New-Property { "{0} x {1}" -f $_.MaxHorizontalImageSize, $_.MaxVerticalImageSize } -Name "Monitor Size (cm)" -Alignment Right
        ) -AutoSize -Wrap | Write-Output

        $network = Get-CimInstance "Win32_NetworkAdapterConfiguration" | ConvertTo-Hashtable "SettingID"
        Get-CimInstance "Win32_NetworkAdapter" -Filter "PhysicalAdapter=True" `
        | Format-Table @(
            "DeviceID" | New-Property -Name "Id"
            "Name" | New-Property -Name "Network Adapter"
            New-Property { $_.Speed / 1000000 } -Name "Speed (Mbit/s)"
            New-Property { $network[$_.GUID].DHCPEnabled } -Name "DHCP"
            New-Property { $network[$_.GUID].DNSServerSearchOrder -join "`n" } -Name "DNS Servers"
            New-Property { $network[$_.GUID].DefaultIPGateway -join "`n" } -Name "Default Gateway"
            New-Property { $network[$_.GUID].IPAddress -join "`n" } -Name "IP Addresses"
            New-Property { $network[$_.GUID].IPSubnet -join "`n" } -Name "IP Subnets"
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "Win32_OperatingSystem" `
        | Format-List @(
            "Caption" | New-Property -Name "Operating System"
            "Version"
            "CSDVersion" | New-Property -Name "Service Pack"
            "OSArchitecture" | New-Property -Name "Architecture"
            "RegisteredUser" | New-Property -Name "Registered User"
            New-Property { $_.MUILanguages -join ", " } -Name "Languages"
            "CodeSet" | New-Property -Name "Code Page"
            "InstallDate" | New-Property -Name "Install Date"
            "LastBootUpTime" | New-Property -Name "Boot Up Time"
            "LocalDateTime" | New-Property -Name "Local Date Time"
            New-Property { $_.LocalDateTime - $_.LastBootUpTime } -Name "Up Time"
            "TotalVisibleMemorySize" | New-Property -Name "Total Physical Memory" | ConvertTo-Unit GB -From KB
            "FreePhysicalMemory" | New-Property -Name "Free Physical Memory" | ConvertTo-Unit GB -From KB
            "TotalVirtualMemorySize" | New-Property -Name "Total Virtual Memory" | ConvertTo-Unit GB -From KB
            "FreeVirtualMemory" | New-Property -Name "Free Virtual Memory" | ConvertTo-Unit GB -From KB
            New-Property { $_.SizeStoredInPagingFiles + $_.FreeSpaceInPagingFiles } -Name "Total in Paging Files" | ConvertTo-Unit GB -From KB
            "FreeSpaceInPagingFiles" | New-Property -Name "Free in Paging Files" | ConvertTo-Unit GB -From KB
        ) | Write-Output

        Get-CimInstance "Win32_QuickFixEngineering" `
        | Sort-Object "InstalledOn" -Descending `
        | Format-Table @(
            "HotFixID" | New-Property -Name "Hot Fix"
            "Description" | New-Property -Name "Type"
            "InstalledOn" | New-Property -Name "Install Date"
        ) -AutoSize -Wrap | Write-Output

        Get-CimInstance "Win32_TimeZone" `
        | Format-List @(
            "Caption" | New-Property -Name "Time Zone"
            "Bias"
            "StandardBias" | New-Property -Name "Standard Bias"
            "DaylightBias" | New-Property -Name "Daylight Bias"
        ) | Write-Output

        Get-CimInstance "Win32_LogicalDisk" `
        | Format-Table @(
            "Name"
            "VolumeName" | New-Property -Name "Volume"
            "FileSystem" | New-Property -Name "File System"
            "Compressed"
            "Size" | ConvertTo-Unit GB
            "FreeSpace" | New-Property -Name "Free" | ConvertTo-Unit GB
        ) -AutoSize -Wrap | Write-Output
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
