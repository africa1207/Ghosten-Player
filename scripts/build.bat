@echo off
setlocal enabledelayedexpansion

:: Ghosten Player Windows 构建脚本
:: 用法: build.bat [debug|release|both]

set "BUILD_TYPE=%~1"
if "%BUILD_TYPE%"=="" set "BUILD_TYPE=both"

echo.
echo ========================================
echo    Ghosten Player 构建脚本
echo ========================================
echo.

:: 检查Flutter环境
:check_flutter
echo [INFO] 检查Flutter环境...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter未安装或未添加到PATH
    echo 请先安装Flutter: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

flutter doctor
echo.

:: 处理命令行参数
if /i "%BUILD_TYPE%"=="help" goto show_help
if /i "%BUILD_TYPE%"=="-h" goto show_help
if /i "%BUILD_TYPE%"=="--help" goto show_help
if /i "%BUILD_TYPE%"=="clean" goto clean_only
if /i "%BUILD_TYPE%"=="deps" goto deps_only

:: 清理项目
:clean_project
echo [INFO] 清理项目...
flutter clean
if errorlevel 1 (
    echo [ERROR] 项目清理失败
    pause
    exit /b 1
)
echo [SUCCESS] 项目清理完成
echo.

:: 获取依赖
:get_dependencies
echo [INFO] 获取Flutter依赖...
flutter pub get
if errorlevel 1 (
    echo [ERROR] 依赖获取失败
    pause
    exit /b 1
)

:: 获取子包依赖
for /d %%i in (packages\*) do (
    if exist "%%i\pubspec.yaml" (
        echo [INFO] 获取 %%i 依赖...
        pushd "%%i"
        flutter pub get
        popd
    )
)

echo [SUCCESS] 依赖获取完成
echo.

:: 根据构建类型执行相应操作
if /i "%BUILD_TYPE%"=="debug" goto build_debug
if /i "%BUILD_TYPE%"=="release" goto build_release
if /i "%BUILD_TYPE%"=="both" goto build_both

echo [ERROR] 未知构建类型: %BUILD_TYPE%
goto show_help

:: 构建Debug版本
:build_debug
echo [INFO] 构建Debug版本...
flutter build apk --debug
if errorlevel 1 (
    echo [ERROR] Debug版本构建失败
    pause
    exit /b 1
)

flutter build apk --debug --split-per-abi
echo [SUCCESS] Debug版本构建完成
echo.
goto organize_apks

:: 构建Release版本
:build_release
echo [INFO] 构建Release版本...
flutter build apk --release
if errorlevel 1 (
    echo [ERROR] Release版本构建失败
    pause
    exit /b 1
)

flutter build apk --release --split-per-abi
echo [SUCCESS] Release版本构建完成
echo.
goto organize_apks

:: 构建两个版本
:build_both
call :build_debug
call :build_release
goto organize_apks

:: 整理APK文件
:organize_apks
echo [INFO] 整理APK文件...

:: 创建输出目录
set "OUTPUT_DIR=build\outputs"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: 获取时间戳
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"

:: APK源目录
set "APK_DIR=build\app\outputs\flutter-apk"

:: 复制APK文件
if exist "%APK_DIR%\app-debug.apk" (
    copy "%APK_DIR%\app-debug.apk" "%OUTPUT_DIR%\ghosten-player-debug-%TIMESTAMP%.apk" >nul
    echo [SUCCESS] Debug APK: %OUTPUT_DIR%\ghosten-player-debug-%TIMESTAMP%.apk
)

if exist "%APK_DIR%\app-release.apk" (
    copy "%APK_DIR%\app-release.apk" "%OUTPUT_DIR%\ghosten-player-release-%TIMESTAMP%.apk" >nul
    echo [SUCCESS] Release APK: %OUTPUT_DIR%\ghosten-player-release-%TIMESTAMP%.apk
)

:: 复制分架构版本
for %%arch in (arm64-v8a armeabi-v7a x86_64) do (
    if exist "%APK_DIR%\app-%%arch-debug.apk" (
        copy "%APK_DIR%\app-%%arch-debug.apk" "%OUTPUT_DIR%\ghosten-player-%%arch-debug-%TIMESTAMP%.apk" >nul
    )
    
    if exist "%APK_DIR%\app-%%arch-release.apk" (
        copy "%APK_DIR%\app-%%arch-release.apk" "%OUTPUT_DIR%\ghosten-player-%%arch-release-%TIMESTAMP%.apk" >nul
    )
)

echo.
echo [INFO] APK文件列表:
dir "%OUTPUT_DIR%\*.apk" /b 2>nul
if errorlevel 1 echo [WARNING] 没有找到APK文件

echo.
echo [SUCCESS] 构建完成！
echo [INFO] APK文件位置: %OUTPUT_DIR%\
echo.
pause
exit /b 0

:: 仅清理
:clean_only
call :clean_project
pause
exit /b 0

:: 仅获取依赖
:deps_only
call :get_dependencies
pause
exit /b 0

:: 显示帮助
:show_help
echo Ghosten Player Windows 构建脚本
echo.
echo 用法: %~nx0 [选项]
echo.
echo 选项:
echo   debug    构建Debug版本
echo   release  构建Release版本
echo   both     构建Debug和Release版本 (默认)
echo   clean    仅清理项目
echo   deps     仅获取依赖
echo   help     显示此帮助信息
echo.
echo 示例:
echo   %~nx0 debug          # 构建Debug版本
echo   %~nx0 release        # 构建Release版本
echo   %~nx0 both           # 构建两个版本
echo   %~nx0 clean          # 清理项目
echo.
pause
exit /b 0
