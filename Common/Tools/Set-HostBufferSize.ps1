function Set-HostBufferSize {
    [CmdletBinding(PositionalBinding=$false)]
    [OutputType([void])]
    param (
        [int] $Width,
        [int] $Height
    )
    try {
        $psHost = Get-Host
        $bufferSize = $psHost.UI.RawUI.BufferSize
        "Current buffer size: {0}x{1}" -f $bufferSize.Width, $bufferSize.Height | Write-Verbose
        $windowSize = $psHost.UI.RawUI.WindowSize
        if ($Width -and $Width -ge $windowSize.Width) {
            $bufferSize.Width = $Width
        }
        if ($Height -and $Height -ge $windowSize.Height) {
            $bufferSize.Height = $Height
        }
        "New buffer size: {0}x{1}" -f $bufferSize.Width, $bufferSize.Height | Write-Verbose
        $psHost.UI.RawUI.BufferSize = $bufferSize
    } catch {
        Write-Warning "Unable to set host buffer size: $_"
    }
}

Export-ModuleMember -Function @(
    "Set-HostBufferSize"
)
