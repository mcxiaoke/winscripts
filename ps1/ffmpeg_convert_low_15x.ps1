# 获取命令行参数作为目标文件夹
$target_folder = $args[0]

# 检查是否提供了目标文件夹参数
if (-not $target_folder) {
    Write-Host "请提供目标文件夹路径作为命令行参数。"
    exit
}

# 检查目标文件夹是否存在
if (-not (Test-Path $target_folder)) {
    Write-Host "提供的目标文件夹路径不存在。"
    exit
}

# 递归遍历文件夹
Get-ChildItem -Path $target_folder -Recurse -Include *.mp4, *.mkv, *.avi, *.mov, *.wmv, *.flv, *.webm | ForEach-Object {
    $input_filepath = $_.FullName
    $file_basename = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    # 检查文件基本名是否以 "_shana" 结尾，如果是则跳过处理
    if ($file_basename -match "_shana") {
        Write-Host "跳过文件: $input_filepath"
    }
    else {
        $temp_filepath = Join-Path (Split-Path $input_filepath) ($file_basename + "_tmp.mp4")
        $output_filepath = Join-Path (Split-Path $input_filepath) ($file_basename + "_shana.mp4")

        Write-Host "处理文件 $input_filepath"
        # 压缩视频文件并调整速度，保存到原文件同一目录
        ffmpeg -hide_banner -i $input_filepath -filter_complex "[0:v]setpts=PTS/1.5, scale=w=min(iw\,1080):h=min(ih\,1080)[v];[0:a]atempo=1.5[a]" -map "[v]" -map "[a]" -c:v hevc_nvenc -bufsize 2000k -maxrate 500k -cq 23 -c:a libfdk_aac -profile:a aac_he -b:a 48k -movflags +faststart$temp_filepath

        if ($LASTEXITCODE -eq 0) {
            Write-Host "转换成功 $output_filepath"
            Move-Item $temp_filepath $output_filepath -Force
        }
        else {
            Write-Host "转换失败，删除临时文件"
            Remove-Item $temp_filepath -Force
        }
    }
}
