enum MediaType {
    Unspecified = 0
    HDD         = 3
    SSD         = 4
    SCM         = 5
}

enum BusType {
    Unknown           = 0
    SCSI              = 1
    ATAPI             = 2
    ATA               = 3
    IEEE1394          = 4
    SSA               = 5
    FibreChannel      = 6
    USB               = 7
    RAID              = 8
    iSCSI             = 9
    SAS               = 10
    SATA              = 11
    SD                = 12
    MMC               = 13
    MAX               = 14
    FileBackedVirtual = 15
    StorageSpaces     = 16
    NVMe              = 17
    MicrosoftReserved = 18
}

enum HealthStatus {
    Healthy   = 0
    Warning   = 1
    Unhealthy = 2
    Unknown   = 5
}

$result = @(
    @{
        Name       = "Computer"
        ClassName  = "Win32_ComputerSystem"
        Format     = "List"
        Properties = @(
            "Model"                     | New-Property -Name "Computer"
            "Manufacturer"
            "SystemType"                | New-Property -Name "Type"
            "Name"
            "Domain"
            "PartOfDomain"              | New-Property -Name "Part of Domain"
            "PrimaryOwnerName"          | New-Property -Name "Primary Owner"
            "UserName"                  | New-Property -Name "User"
            "NumberOfProcessors"        | New-Property -Name "Physical Processors"
            "NumberOfLogicalProcessors" | New-Property -Name "Logical Processors"
            "TotalPhysicalMemory"       | New-Property -Name "Physical Memory" | ConvertTo-Unit GB
            "DaylightInEffect"          | New-Property -Name "Daylight in Effect"
            "HypervisorPresent"         | New-Property -Name "Hypervisor Present"
        )
        Extra      = "TotalPhysicalMemory"
    }
    @{
        Name       = "Processors"
        ClassName  = "Win32_Processor"
        Sort       = "DeviceID"
        Format     = "Table"
        Properties = @(
            "DeviceID"                      | New-Property -Name "Id"
            "Name"                          | New-Property -Name "Processor"
            "NumberOfCores"                 | New-Property -Name "Cores"
            "NumberOfLogicalProcessors"     | New-Property -Name "Threads"
            "VirtualizationFirmwareEnabled" | New-Property -Name "Virtualization"
            "VMMonitorModeExtensions"       | New-Property -Name "VM Monitor"
        )
    }
    @{
        Name       = "Memory"
        ClassName  = "Win32_PhysicalMemory"
        Sort       = "DeviceLocator"
        Format     = "Table"
        Properties = @(
            "DeviceLocator"      | New-Property -Name "Id"
            "PartNumber"         | New-Property -Name "Memory"
            "Capacity"           | ConvertTo-Unit GB
            "Speed"
            "InterleavePosition" | New-Property -Name "Interleave Position"
        )
        Extra      = "Capacity"
    }
    @{
        Name       = "Disks"
        ClassName  = "MSFT_PhysicalDisk"
        Namespace  = "ROOT/Microsoft/Windows/Storage"
        Sort       = "DeviceId"
        Format     = "Table"
        Properties = @(
            "DeviceId"      | New-Property -Name "Id"
            "Model"         | New-Property -Name "Disk"
            "MediaType"     | New-Property -Name "Type" | ConvertTo-Enum ([MediaType])
            "SpindleSpeed"  | New-Property -Name "RPM"
            "BusType"       | New-Property -Name "Bus" | ConvertTo-Enum ([BusType])
            "Size"          | ConvertTo-Unit GB
            "AllocatedSize" | New-Property -Name "Allocated" | ConvertTo-Unit GB
            "HealthStatus"  | New-Property -Name "Status" | ConvertTo-Enum ([HealthStatus])
        )
        Extra      = "Size", "AllocatedSize"
    }
    @{
        Name       = "Video Controllers"
        ClassName  = "Win32_VideoController"
        Sort       = "DeviceID"
        Format     = "Table"
        Properties = @(
            "DeviceID"            | New-Property -Name "Id"
            "Name"                | New-Property -Name "Video Controller"
            "AdapterRAM"          | New-Property -Name "RAM" | ConvertTo-Unit GB
            New-Property { "{0} x {1}" -f $_.CurrentHorizontalResolution, $_.CurrentVerticalResolution } -Name "Resolution" -Alignment Right
            "CurrentBitsPerPixel" | New-Property -Name "Color Depth"
            "CurrentRefreshRate"  | New-Property -Name "Refresh Rate"
        )
        Extra      = "CurrentHorizontalResolution", "CurrentVerticalResolution"
    }
    @{
        Name       = "Monitors"
        ClassName  = "Win32_DesktopMonitor"
        Sort       = "DeviceID"
        Format     = "Table"
        Properties = @(
            "DeviceID"    | New-Property -Name "Id"
            "Name"        | New-Property -Name "Monitor"
            "MonitorType" | New-Property -Name "Type"
            New-Property { "{0} x {1}" -f $_.ScreenWidth, $_.ScreenHeight } -Name "Resolution" -Alignment Right
            "Bandwidth"
            New-Property { "{0} x {1}" -f $_.PixelsPerXLogicalInch, $_.PixelsPerYLogicalInch } -Name "Pixels/Logical Inch" -Alignment Right
        )
        Extra      = "ScreenWidth", "ScreenHeight", "PixelsPerXLogicalInch", "PixelsPerYLogicalInch"
    }
    @{
        Name       = "Monitor Sizes"
        ClassName  = "WmiMonitorBasicDisplayParams"
        Namespace  = "root/wmi"
        Sort       = "InstanceName"
        Format     = "Table"
        Properties = @(
            "InstanceName" | New-Property -Name "Id"
            New-Property { "{0} x {1}" -f $_.MaxHorizontalImageSize, $_.MaxVerticalImageSize } -Name "Monitor Size (cm)" -Alignment Right
        )
        Extra      = "MaxHorizontalImageSize", "MaxVerticalImageSize"
    }
    @{
        Name       = "Network Adapters Configuration"
        ClassName  = "Win32_NetworkAdapterConfiguration"
        Hashtable  = "Network"
        Key        = "SettingID"
        Extra      = "DHCPEnabled", "DNSServerSearchOrder", "DefaultIPGateway", "IPAddress", "IPSubnet"
    }
    @{
        Name       = "Network Adapters"
        ClassName  = "Win32_NetworkAdapter"
        Filter     = "PhysicalAdapter=True"
        Sort       = "DeviceID"
        Format     = "Table"
        Properties = @(
            "DeviceID" | New-Property -Name "Id"
            "Name"     | New-Property -Name "Network Adapter"
            New-Property { $_.Speed / 1E6 } -Name "Speed (Mbps)" -Format "N0"
            New-Property { $network[$_.GUID].DHCPEnabled } -Name "DHCP"
            New-Property { $network[$_.GUID].DNSServerSearchOrder -join "`n" } -Name "DNS Servers"
            New-Property { $network[$_.GUID].DefaultIPGateway -join "`n" } -Name "Default Gateway"
            New-Property { $network[$_.GUID].IPAddress -join "`n" } -Name "IP Addresses"
            New-Property { $network[$_.GUID].IPSubnet -join "`n" } -Name "IP Subnets"
        )
        Extra      = "Speed", "GUID"
    }
    @{
        Name       = "Operating System"
        ClassName  = "Win32_OperatingSystem"
        Format     = "List"
        Properties = @(
            "Caption"                | New-Property -Name "Operating System"
            "Version"
            "CSDVersion"             | New-Property -Name "Service Pack"
            "OSArchitecture"         | New-Property -Name "Architecture"
            "RegisteredUser"         | New-Property -Name "Registered User"
            New-Property { $_.MUILanguages -join ", " } -Name "Languages"
            "CodeSet"                | New-Property -Name "Code Page"
            "InstallDate"            | New-Property -Name "Install Date"
            "LastBootUpTime"         | New-Property -Name "Boot Up Time"
            "LocalDateTime"          | New-Property -Name "Local Date Time"
            New-Property { $_.LocalDateTime - $_.LastBootUpTime } -Name "Up Time"
            "TotalVisibleMemorySize" | New-Property -Name "Total Physical Memory" | ConvertTo-Unit GB -From KB
            "FreePhysicalMemory"     | New-Property -Name "Free Physical Memory" | ConvertTo-Unit GB -From KB
            "TotalVirtualMemorySize" | New-Property -Name "Total Virtual Memory" | ConvertTo-Unit GB -From KB
            "FreeVirtualMemory"      | New-Property -Name "Free Virtual Memory" | ConvertTo-Unit GB -From KB
            New-Property { $_.SizeStoredInPagingFiles + $_.FreeSpaceInPagingFiles } -Name "Total in Paging Files" | ConvertTo-Unit GB -From KB
            "FreeSpaceInPagingFiles" | New-Property -Name "Free in Paging Files" | ConvertTo-Unit GB -From KB
        )
        Extra      = "MUILanguages", "LocalDateTime", "LastBootUpTime", "SizeStoredInPagingFiles", "FreeSpaceInPagingFiles"
    }
    @{
        Name       = "Hot Fixes"
        ClassName  = "Win32_QuickFixEngineering"
        Sort       = "HotFixID"
        Descending = $true
        Format     = "Table"
        Properties = @(
            "HotFixID"    | New-Property -Name "Hot Fix"
            "Description" | New-Property -Name "Type"
        )
    }
    @{
        Name       = "Time Zone"
        ClassName  = "Win32_TimeZone"
        Format     = "List"
        Properties = @(
            "Caption"      | New-Property -Name "Time Zone"
            "Bias"
            "StandardBias" | New-Property -Name "Standard Bias"
            "DaylightBias" | New-Property -Name "Daylight Bias"
        )
    }
    @{
        Name       = "Volumes"
        ClassName  = "Win32_LogicalDisk"
        Sort       = "Name"
        Format     = "Table"
        Properties = @(
            "Name"
            "VolumeName" | New-Property -Name "Volume"
            "FileSystem" | New-Property -Name "File System"
            "Compressed"
            "Size"       | ConvertTo-Unit GB
            "FreeSpace"  | New-Property -Name "Free" | ConvertTo-Unit GB
        )
    }
)

$result
