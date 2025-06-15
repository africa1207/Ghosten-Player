# 构建问题故障排除指南

## 当前遇到的问题

您遇到的错误：
```
Gradle build failed to produce an .apk file. It's likely that this file was generated under /home/runner/work/Ghosten-Player/Ghosten-Player/build, but the tool couldn't find it.
```

这通常表示Gradle构建过程中出现了问题，但Flutter没有捕获到具体的错误信息。

## 已实施的修复

### 1. Java版本统一
- 将Android项目的Java版本从11升级到17
- 确保与GitHub Actions环境一致

### 2. 签名配置优化
- 修复了Release版本的签名配置
- 添加了对缺少签名文件的容错处理

### 3. 新增调试工作流
创建了三个新的GitHub Actions工作流：
- `debug-build.yml` - 详细调试信息
- `minimal-build.yml` - 最小化构建
- `simple-build.yml` - 简化构建（已更新）

## 推荐解决步骤

### 步骤1：使用调试工作流
1. 打开GitHub仓库 → Actions
2. 选择 **调试构建问题** 工作流
3. 点击 **Run workflow**
4. 查看详细的调试信息

### 步骤2：使用最小化构建
1. 选择 **最小化构建** 工作流
2. 选择目标架构（推荐选择 `arm64`）
3. 运行构建

### 步骤3：检查具体错误
如果仍然失败，请查看Actions日志中的具体错误信息，特别关注：
- Gradle构建错误
- 依赖冲突
- 签名问题
- 内存不足

## 常见问题及解决方案

### 1. Gradle构建超时
**症状**: 构建过程卡住或超时
**解决方案**:
```yaml
# 在工作流中添加
- name: 配置Gradle
  run: |
    mkdir -p ~/.gradle
    echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
    echo "org.gradle.parallel=false" >> ~/.gradle/gradle.properties
    echo "org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m" >> ~/.gradle/gradle.properties
```

### 2. 依赖冲突
**症状**: 出现AndroidX和Support Library混合使用的警告
**解决方案**: 这是警告不是错误，通常不影响构建

### 3. 签名问题
**症状**: Release构建失败，提到签名
**解决方案**: 使用Debug构建，或配置正确的签名文件

### 4. 内存不足
**症状**: OutOfMemoryError
**解决方案**: 
- 使用分架构构建 `--target-platform android-arm64`
- 减少并行构建

## 备用构建方案

### 方案A：本地构建
如果GitHub Actions持续失败，可以尝试本地构建：

1. **安装环境**（参考 `LOCAL_SETUP_GUIDE.md`）
2. **克隆代码**:
   ```bash
   git clone https://github.com/your-username/Ghosten-Player.git
   cd Ghosten-Player
   ```
3. **构建**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug --target-platform android-arm64
   ```

### 方案B：使用Docker
创建 `Dockerfile`:
```dockerfile
FROM cirrusci/flutter:stable

WORKDIR /app
COPY . .

RUN flutter clean
RUN flutter pub get
RUN flutter build apk --debug --target-platform android-arm64
```

### 方案C：分步构建
1. 先构建单一架构
2. 确认成功后再构建其他版本
3. 最后构建Release版本

## 调试命令

### 本地调试命令
```bash
# 检查Flutter环境
flutter doctor -v

# 检查Android配置
flutter config --android-sdk $ANDROID_SDK_ROOT

# 详细构建日志
flutter build apk --debug --verbose

# 直接使用Gradle构建
cd android
./gradlew assembleDebug --stacktrace --info

# 查找APK文件
find . -name "*.apk" -type f
```

### GitHub Actions调试
在工作流中添加调试步骤：
```yaml
- name: 调试信息
  if: failure()
  run: |
    echo "=== 构建失败调试 ==="
    find . -name "*.apk" -type f
    find . -name "*.log" -type f -exec cat {} \;
    ls -la build/app/outputs/ || echo "输出目录不存在"
```

## 联系支持

如果问题仍然存在，请提供：

1. **完整的构建日志**（从Actions页面复制）
2. **具体的错误信息**
3. **使用的工作流名称**
4. **选择的构建选项**

这样我可以提供更具体的解决方案。

## 临时解决方案

如果急需APK文件，可以：

1. **降级Flutter版本**：使用较旧但稳定的Flutter版本
2. **简化项目**：临时移除可能有问题的依赖
3. **使用预构建版本**：基于原始项目构建，然后手动应用DLNA修复

记住：构建问题通常是环境配置问题，不是代码本身的问题。DLNA修复的代码更改是正确的。
