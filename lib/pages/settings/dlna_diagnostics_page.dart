import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/dlna_diagnostics.dart';
import '../../l10n/app_localizations.dart';

class DlnaDiagnosticsPage extends StatefulWidget {
  const DlnaDiagnosticsPage({super.key});

  @override
  State<DlnaDiagnosticsPage> createState() => _DlnaDiagnosticsPageState();
}

class _DlnaDiagnosticsPageState extends State<DlnaDiagnosticsPage> {
  bool _isRunning = false;
  String _report = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _report = '';
    });

    try {
      final report = await DlnaDiagnostics.generateDiagnosticReport();
      setState(() {
        _report = report;
      });
    } catch (e) {
      setState(() {
        _report = '诊断过程中发生错误: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _copyReport() {
    Clipboard.setData(ClipboardData(text: _report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('诊断报告已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DLNA网络诊断'),
        actions: [
          IconButton(
            onPressed: _runDiagnostics,
            icon: const Icon(Icons.refresh),
            tooltip: '重新诊断',
          ),
          if (_report.isNotEmpty)
            IconButton(
              onPressed: _copyReport,
              icon: const Icon(Icons.copy),
              tooltip: '复制报告',
            ),
        ],
      ),
      body: _isRunning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在进行网络诊断...'),
                  SizedBox(height: 8),
                  Text(
                    '这可能需要几秒钟时间',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _report.isEmpty
              ? const Center(child: Text('暂无诊断结果'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline),
                                  const SizedBox(width: 8),
                                  Text(
                                    '诊断说明',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '此诊断工具会检查您的设备网络配置，帮助排查DLNA投屏无法发现设备的问题。'
                                '诊断包括网络连接状态、多播支持和SSDP设备发现测试。',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.assignment),
                                  const SizedBox(width: 8),
                                  Text(
                                    '诊断报告',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  _report,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.help_outline),
                                  const SizedBox(width: 8),
                                  Text(
                                    '常见问题解决方案',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _TroubleshootingTips(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _TroubleshootingTips extends StatelessWidget {
  const _TroubleshootingTips();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTip(
          '1. 网络连接问题',
          '• 确保手机和DLNA设备连接到同一WiFi网络\n'
          '• 检查WiFi网络是否正常工作\n'
          '• 尝试重启WiFi连接',
        ),
        const SizedBox(height: 12),
        _buildTip(
          '2. DLNA设备设置',
          '• 确保DLNA设备的媒体共享功能已开启\n'
          '• 检查设备是否支持DLNA/UPnP协议\n'
          '• 查看设备说明书了解DLNA设置方法',
        ),
        const SizedBox(height: 12),
        _buildTip(
          '3. 路由器配置',
          '• 确保路由器支持多播(Multicast)\n'
          '• 检查路由器防火墙设置\n'
          '• 尝试重启路由器',
        ),
        const SizedBox(height: 12),
        _buildTip(
          '4. 应用权限',
          '• 确保应用有网络访问权限\n'
          '• 检查是否被安全软件阻止\n'
          '• 尝试重启应用',
        ),
      ],
    );
  }

  Widget _buildTip(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
