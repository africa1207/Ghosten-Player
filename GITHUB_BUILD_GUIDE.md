# GitHub Actions 构建指南

## 问题解决

您遇到的错误是因为项目要求的Dart SDK版本（3.7.2+）比GitHub Actions中Flutter自带的Dart版本更新。我已经修复了这个问题。

## 修复内容

### 1. 降低Dart SDK版本要求
我将以下文件中的Dart SDK版本要求从 `^3.7.2` 或 `^3.8.0` 降低到 `^3.5.0`：
- `pubspec.yaml`
- `packages/api/pubspec.yaml`
- `packages/bluetooth/pubspec.yaml`
- `packages/file_picker/pubspec.yaml`
- `packages/video_player/pubspec.yaml`

### 2. 优化GitHub Actions工作流
- 使用最新的stable Flutter版本
- 添加了详细的版本信息显示
- 改进了依赖安装流程

## 使用方法

### 方案1：使用简单构建工作流（推荐）

1. **提交修复后的代码**：
   ```bash
   git add .
   git commit -m "修复DLNA问题并调整Dart SDK版本"
   git push origin main
   ```

2. **触发构建**：
   - 打开GitHub仓库页面
   - 点击 **Actions** 标签
   - 选择 **简单构建APK** 工作流
   - 点击 **Run workflow**
   - 填写构建描述（可选）
   - 点击绿色的 **Run workflow** 按钮

3. **等待构建完成**（约5-10分钟）

4. **下载APK**：
   - 构建完成后，点击进入构建详情页面
   - 在页面底部找到 **Artifacts** 部分
   - 下载 `ghosten-player-dlna-fix-xxx` 文件
   - 解压后获得APK文件

### 方案2：使用手动构建工作流

如果简单构建工作流仍有问题，可以使用 **手动构建APK** 工作流，步骤相同。

## 构建产物说明

构建成功后会生成两个APK文件：
- `ghosten-player-debug-YYYYMMDD_HHMMSS.apk` - Debug版本（用于测试）
- `ghosten-player-release-YYYYMMDD_HHMMSS.apk` - Release版本（推荐安装）

## 安装和测试

1. **下载Release版本APK**到您的Android设备
2. **启用未知来源安装**：
   - 设置 → 安全 → 未知来源（或应用安装）
   - 允许从此来源安装应用
3. **安装APK**
4. **测试DLNA功能**：
   - 打开应用
   - 进入 设置 → DLNA网络诊断
   - 查看诊断结果
   - 尝试播放视频并使用投屏功能

## 故障排除

### 如果构建仍然失败：

1. **检查错误日志**：
   - 在Actions页面点击失败的构建
   - 查看具体的错误信息

2. **常见问题**：
   - **网络问题**：重新运行工作流
   - **依赖冲突**：检查pubspec.yaml文件
   - **Flutter版本问题**：工作流会自动使用最新stable版本

3. **手动调试**：
   如果GitHub Actions持续失败，可以尝试本地构建：
   ```bash
   # 克隆仓库
   git clone https://github.com/your-username/Ghosten-Player.git
   cd Ghosten-Player
   
   # 安装依赖
   flutter pub get
   
   # 构建APK
   flutter build apk --release
   ```

## 版本兼容性说明

- **当前设置**：Dart SDK ^3.5.0
- **兼容性**：支持Flutter 3.24+
- **未来升级**：当Dart 3.7正式发布后，可以恢复更高的版本要求

## 联系支持

如果仍有问题，请提供：
1. 构建失败的完整日志
2. 您的GitHub仓库链接
3. 具体的错误信息

这样我可以进一步协助您解决问题。
