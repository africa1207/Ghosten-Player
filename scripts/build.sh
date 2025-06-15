#!/bin/bash

# Ghosten Player 构建脚本
# 用法: ./scripts/build.sh [debug|release|both]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Flutter环境
check_flutter() {
    print_info "检查Flutter环境..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter未安装或未添加到PATH"
        exit 1
    fi
    
    flutter doctor
    if [ $? -ne 0 ]; then
        print_warning "Flutter环境检查发现问题，但继续构建..."
    fi
}

# 清理项目
clean_project() {
    print_info "清理项目..."
    flutter clean
    print_success "项目清理完成"
}

# 获取依赖
get_dependencies() {
    print_info "获取Flutter依赖..."
    flutter pub get
    
    # 获取子包依赖
    for package in packages/*/; do
        if [ -f "$package/pubspec.yaml" ]; then
            print_info "获取 $package 依赖..."
            (cd "$package" && flutter pub get)
        fi
    done
    
    print_success "依赖获取完成"
}

# 构建Debug版本
build_debug() {
    print_info "构建Debug版本..."
    
    # 构建通用版本
    flutter build apk --debug
    
    # 构建分架构版本
    flutter build apk --debug --split-per-abi
    
    print_success "Debug版本构建完成"
}

# 构建Release版本
build_release() {
    print_info "构建Release版本..."
    
    # 构建通用版本
    flutter build apk --release
    
    # 构建分架构版本
    flutter build apk --release --split-per-abi
    
    print_success "Release版本构建完成"
}

# 整理APK文件
organize_apks() {
    print_info "整理APK文件..."
    
    # 创建输出目录
    OUTPUT_DIR="build/outputs"
    mkdir -p "$OUTPUT_DIR"
    
    # 获取时间戳
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # 复制APK文件
    APK_DIR="build/app/outputs/flutter-apk"
    
    if [ -f "$APK_DIR/app-debug.apk" ]; then
        cp "$APK_DIR/app-debug.apk" "$OUTPUT_DIR/ghosten-player-debug-$TIMESTAMP.apk"
        print_success "Debug APK: $OUTPUT_DIR/ghosten-player-debug-$TIMESTAMP.apk"
    fi
    
    if [ -f "$APK_DIR/app-release.apk" ]; then
        cp "$APK_DIR/app-release.apk" "$OUTPUT_DIR/ghosten-player-release-$TIMESTAMP.apk"
        print_success "Release APK: $OUTPUT_DIR/ghosten-player-release-$TIMESTAMP.apk"
    fi
    
    # 复制分架构版本
    for arch in arm64-v8a armeabi-v7a x86_64; do
        if [ -f "$APK_DIR/app-$arch-debug.apk" ]; then
            cp "$APK_DIR/app-$arch-debug.apk" "$OUTPUT_DIR/ghosten-player-$arch-debug-$TIMESTAMP.apk"
        fi
        
        if [ -f "$APK_DIR/app-$arch-release.apk" ]; then
            cp "$APK_DIR/app-$arch-release.apk" "$OUTPUT_DIR/ghosten-player-$arch-release-$TIMESTAMP.apk"
        fi
    done
    
    print_info "APK文件列表:"
    ls -la "$OUTPUT_DIR"/*.apk 2>/dev/null || print_warning "没有找到APK文件"
}

# 显示帮助信息
show_help() {
    echo "Ghosten Player 构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  debug    构建Debug版本"
    echo "  release  构建Release版本"
    echo "  both     构建Debug和Release版本 (默认)"
    echo "  clean    仅清理项目"
    echo "  deps     仅获取依赖"
    echo "  help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 debug          # 构建Debug版本"
    echo "  $0 release        # 构建Release版本"
    echo "  $0 both           # 构建两个版本"
    echo "  $0 clean          # 清理项目"
}

# 主函数
main() {
    local build_type="${1:-both}"
    
    case "$build_type" in
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
        "clean")
            clean_project
            exit 0
            ;;
        "deps")
            get_dependencies
            exit 0
            ;;
        "debug")
            check_flutter
            clean_project
            get_dependencies
            build_debug
            organize_apks
            ;;
        "release")
            check_flutter
            clean_project
            get_dependencies
            build_release
            organize_apks
            ;;
        "both")
            check_flutter
            clean_project
            get_dependencies
            build_debug
            build_release
            organize_apks
            ;;
        *)
            print_error "未知选项: $build_type"
            show_help
            exit 1
            ;;
    esac
    
    print_success "构建完成！"
    print_info "APK文件位置: build/outputs/"
}

# 运行主函数
main "$@"
