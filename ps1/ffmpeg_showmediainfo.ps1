function Get-MediaFileInfo {
    param (
        [string]$FilePath
    )

    # 检查文件是否存在
    if (-not (Test-Path $FilePath)) {
        Write-Host "文件不存在: $FilePath"
        return $null
    }

    # 调用 ffprobe 获取媒体文件信息，并将输出转换为字符串
    $ffprobe_output = & "ffprobe" -v error -select_streams a:0 -show_entries "stream=codec_name,codec_long_name,codec_type,bit_rate,channels,sample_rate,codec_tag_string : format=duration,format_name,format_long_name,bit_rate,size" -of json $FilePath | Out-String

    # 解析 JSON 格式的输出
    $media_info = $ffprobe_output | ConvertFrom-Json

    return $media_info
}


$info = Get-MediaFileInfo($args[0])
Write-Host ($info.streams | Format-List | Out-String)
Write-Host ($info.format | Format-List | Out-String)