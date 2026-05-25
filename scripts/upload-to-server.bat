@echo off
chcp 65001 >nul
REM ========================================
REM AI-Seckill-Hybrid 代码上传脚本
REM 将项目从Windows上传到腾讯云服务器
REM ========================================

echo.
echo =========================================
echo   AI-Seckill-Hybrid 代码上传工具
echo   目标服务器: 182.254.244.202
echo =========================================
echo.

set SERVER_IP=182.254.244.202
set SERVER_USER=root
set PROJECT_DIR=c:\Users\dell\Desktop\ai-seckill-hybrid

echo [1/4] 检查必要工具...
where scp >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ SCP未安装，请安装Git for Windows
    pause
    exit /b 1
)
echo ✓ SCP已就绪
echo.

echo [2/4] 压缩项目文件...
cd %PROJECT_DIR%

REM 创建临时压缩文件
echo 正在压缩项目（排除node_modules、target等）...

REM 使用PowerShell进行压缩（排除指定目录）
powershell -Command ^
"$exclude = @('node_modules', 'target', '.git', '__pycache__', 'venv', '.venv', 'dist'); ^
$source = '%PROJECT_DIR%'; ^
$tempZip = [System.IO.Path]::GetTempFileName() + '.zip'; ^
Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
$zip = [System.IO.Compression.ZipFile]::Open($tempZip, 'Create'); ^
Get-ChildItem $source -Recurse | Where-Object { ^
    $excludeNotMatch = $true; ^
    foreach ($ex in $exclude) { ^
        if ($_.FullName -like "*\$ex\*" -or $_.FullName -like "*\$ex") { ^
            $excludeNotMatch = $false; ^
            break; ^
        } ^
    }; ^
    $excludeNotMatch -and !$_.PSIsContainer ^
} | ForEach-Object { ^
    $entryName = $_.FullName.Substring($source.Length + 1); ^
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entryName); ^
}; ^
$zip.Dispose(); ^
Write-Output $tempZip" > temp_zip.txt

set /p TEMP_ZIP=<temp_zip.txt
del temp_zip.txt

echo ✓ 压缩完成: %TEMP_ZIP%
echo.

echo [3/4] 上传到服务器...
echo 正在上传到 %SERVER_USER%@%SERVER_IP%:/opt/ ...
scp "%TEMP_ZIP%" %SERVER_USER%@%SERVER_IP%:/opt/ai-seckill-upload.zip

if %errorlevel% neq 0 (
    echo ✗ 上传失败，请检查：
    echo    1. 服务器IP是否正确
    echo    2. SSH密码是否正确
    echo    3. 网络连接是否正常
    del "%TEMP_ZIP%"
    pause
    exit /b 1
)

echo ✓ 上传成功
echo.

echo [4/4] 清理临时文件...
del "%TEMP_ZIP%"
echo ✓ 清理完成
echo.

echo =========================================
echo   上传完成！
echo =========================================
echo.
echo 下一步操作：
echo 1. SSH登录服务器: ssh root@%SERVER_IP%
echo 2. 解压文件: cd /opt/ai-seckill ^&^& unzip /opt/ai-seckill-upload.zip
echo 3. 执行部署: chmod +x scripts/deploy-lightweight.sh ^&^& ./scripts/deploy-lightweight.sh
echo.
pause
