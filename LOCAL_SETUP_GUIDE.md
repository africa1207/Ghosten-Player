# Android本地开发环境配置指南

## 1. 安装Java Development Kit (JDK)

### Windows:
1. 下载 [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) 或 [OpenJDK 17](https://adoptium.net/)
2. 运行安装程序，按默认设置安装
3. 设置环境变量：
   - 右键"此电脑" → "属性" → "高级系统设置" → "环境变量"
   - 新建系统变量 `JAVA_HOME`，值为JDK安装路径（如：`C:\Program Files\Java\jdk-17`）
   - 在 `Path` 变量中添加 `%JAVA_HOME%\bin`

### macOS:
```bash
# 使用Homebrew安装
brew install openjdk@17

# 设置环境变量（添加到 ~/.zshrc 或 ~/.bash_profile）
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH=$JAVA_HOME/bin:$PATH
```

### Linux:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-17-jdk

# 设置环境变量（添加到 ~/.bashrc）
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

## 2. 安装Android Studio

1. 下载 [Android Studio](https://developer.android.com/studio)
2. 运行安装程序，选择"Standard"安装类型
3. 首次启动时会自动下载Android SDK

### 配置Android SDK:
1. 打开Android Studio
2. 点击 "More Actions" → "SDK Manager"
3. 确保安装以下组件：
   - Android SDK Platform 34 (API Level 34)
   - Android SDK Build-Tools 34.0.0
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
   - Android Emulator

## 3. 安装Flutter

### Windows:
1. 下载 [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. 解压到 `C:\flutter`
3. 将 `C:\flutter\bin` 添加到系统PATH环境变量

### macOS:
```bash
# 使用Homebrew安装
brew install flutter

# 或手动安装
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

### Linux:
```bash
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

## 4. 验证安装

运行以下命令检查环境：
```bash
flutter doctor
```

应该看到类似输出：
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.3)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Android Studio (version 2023.3)
[✓] Connected device (1 available)
[✓] Network resources
```

## 5. 设置Android设备调试

### 使用真实设备:
1. 在手机上启用"开发者选项"：
   - 设置 → 关于手机 → 连续点击"版本号"7次
2. 启用"USB调试"：
   - 设置 → 开发者选项 → USB调试
3. 用USB线连接手机到电脑
4. 手机上允许USB调试授权

### 使用模拟器:
1. 打开Android Studio
2. 点击 "More Actions" → "Virtual Device Manager"
3. 点击 "Create Device"
4. 选择设备型号（推荐Pixel 6）
5. 选择系统镜像（推荐API 34）
6. 完成创建并启动模拟器

## 6. 构建和调试项目

### 克隆项目:
```bash
git clone https://github.com/your-username/Ghosten-Player.git
cd Ghosten-Player
```

### 安装依赖:
```bash
flutter pub get
```

### 检查连接的设备:
```bash
flutter devices
```

### 运行调试版本:
```bash
# 运行到连接的设备
flutter run

# 运行到特定设备
flutter run -d <device-id>

# 热重载：在运行时按 'r' 键
# 热重启：在运行时按 'R' 键
# 退出：按 'q' 键
```

### 构建APK:
```bash
# Debug版本
flutter build apk --debug

# Release版本
flutter build apk --release

# 分架构构建（减小文件大小）
flutter build apk --split-per-abi
```

构建的APK文件位置：
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

## 7. 常用调试命令

```bash
# 查看日志
flutter logs

# 清理构建缓存
flutter clean

# 检查Flutter环境
flutter doctor -v

# 查看连接的设备
adb devices

# 安装APK到设备
adb install build/app/outputs/flutter-apk/app-debug.apk

# 查看应用日志
adb logcat | grep flutter
```

## 8. 故障排除

### 常见问题:

1. **"Unable to locate Android SDK"**
   - 确保Android Studio已安装并配置了SDK
   - 运行 `flutter config --android-sdk <path-to-sdk>`

2. **"Android license status unknown"**
   ```bash
   flutter doctor --android-licenses
   ```

3. **"Gradle build failed"**
   - 检查网络连接
   - 清理项目：`flutter clean`
   - 重新获取依赖：`flutter pub get`

4. **设备未识别**
   - 确保USB调试已启用
   - 尝试不同的USB线或端口
   - 重启adb：`adb kill-server && adb start-server`

## 9. IDE推荐

### Visual Studio Code:
1. 安装Flutter和Dart插件
2. 打开项目文件夹
3. 按F5开始调试

### Android Studio:
1. 打开项目文件夹
2. 等待Gradle同步完成
3. 点击运行按钮开始调试

## 10. 性能调试

```bash
# 性能分析
flutter run --profile

# 检查应用大小
flutter build apk --analyze-size

# 生成性能报告
flutter build apk --tree-shake-icons
```
