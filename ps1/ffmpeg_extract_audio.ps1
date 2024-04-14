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

#$info = Get-MediaFileInfo($args[0])
#Write-Host ($info.streams | Format-List | Out-String)
#Write-Host ($info.format | Format-List | Out-String)

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
Get-ChildItem -Path $target_folder -Recurse -Include *.mp3, *.mp4, *.mkv, *.avi, *.mov, *.wmv, *.flv, *.webm | ForEach-Object {
	$input_filepath = $_.FullName
	$input_filename = $_.Name
	$file_basename = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
	#$file_extension = [System.IO.Path]::GetExtension($_.Name)
	
	$file_info = Get-MediaFileInfo ( $input_filepath )
	$steam = $file_info.streams[0]
	$is_mp3 = $steam.codec_name -eq "mp3"
	$file_extension = If ($is_mp3) { ".mp3" } Else { ".m4a" }
	$temp_filepath = Join-Path (Split-Path $input_filepath) ($file_basename + "_tmp" + $file_extension)

	$output_filename = $file_basename + "_shana" + $file_extension
	$output_filepath = Join-Path (Split-Path $input_filepath) $output_filename
	
	# 检查文件基本名是否以 "_shana" 结尾，如果是则跳过处理
	if ($file_basename -match "_shana") {
		Write-Host "忽略文件: $input_filepath"
		return
	}
	
	# 检查目标文件是否存在
	if (Test-Path $output_filepath) {
		# Remove-Item -Path $output_filepath -Force
		Write-Host "文件已存在: $output_filepath"
		return
	}
	
	Write-Host "处理文件: $input_filename"
	Write-Host ($steam | Format-List | Out-String)

	# 提取音频
	ffmpeg -y -v error -hide_banner -i $input_filepath -vn -acodec copy $temp_filepath

	if ($LASTEXITCODE -eq 0) {

		# 检查目标文件是否存在
		if (Test-Path $output_filepath) {
			# 如果目标文件存在，先移除它
			Remove-Item -Path $output_filepath -Force
		}
		Rename-Item $temp_filepath $output_filepath -Force
		Write-Host "提取成功: $output_filepath"
	}
	else {
		Write-Host "提取失败，删除临时文件"
		Remove-Item $temp_filepath -Force
	}

}
