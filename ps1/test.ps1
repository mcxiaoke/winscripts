# /*
# * Project: ps1
# * Created: 2024-04-18 20:50:57
# * Modified: 2024-04-18 20:50:57
# * Author: mcxiaoke (github@mcxiaoke.com)
# * License: Apache License 2.0
# */

$OUTPUT_PREFIX = "[SHANA] "

# 定义原始字符串
$originalString = "[SHANA] Hello, world!"

# 使用 -replace 进行替换，并将结果存储到新变量中
$newString = $originalString -replace $OUTPUT_PREFIX, "<TEST>"

# 输出原始字符串和替换后的新字符串
Write-Host "Original String: $originalString"
Write-Host "New String: $newString"