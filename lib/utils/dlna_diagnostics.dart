import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// DLNA网络诊断工具
class DlnaDiagnostics {
  /// 检查网络连接状态
  static Future<Map<String, dynamic>> checkNetworkStatus() async {
    final result = <String, dynamic>{};
    
    try {
      // 检查网络接口
      final interfaces = await NetworkInterface.list();
      final wifiInterfaces = interfaces.where((interface) => 
        interface.name.toLowerCase().contains('wlan') || 
        interface.name.toLowerCase().contains('wifi') ||
        interface.name.toLowerCase().contains('en0') // iOS WiFi
      ).toList();
      
      result['hasWifiInterface'] = wifiInterfaces.isNotEmpty;
      result['wifiInterfaces'] = wifiInterfaces.map((i) => {
        'name': i.name,
        'addresses': i.addresses.map((addr) => addr.address).toList(),
      }).toList();
      
      // 检查是否有局域网IP
      final localIPs = <String>[];
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            if (ip.startsWith('192.168.') || 
                ip.startsWith('10.') || 
                ip.startsWith('172.')) {
              localIPs.add(ip);
            }
          }
        }
      }
      
      result['hasLocalIP'] = localIPs.isNotEmpty;
      result['localIPs'] = localIPs;
      
    } catch (e) {
      result['error'] = e.toString();
    }
    
    return result;
  }
  
  /// 检查多播支持
  static Future<Map<String, dynamic>> checkMulticastSupport() async {
    final result = <String, dynamic>{};
    
    try {
      // 尝试创建多播socket
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      // 尝试加入SSDP多播组
      const ssdpAddress = '239.255.255.250';
      final multicastAddress = InternetAddress(ssdpAddress);
      
      socket.joinMulticast(multicastAddress);
      result['canJoinMulticast'] = true;
      
      socket.leaveMulticast(multicastAddress);
      socket.close();
      
    } catch (e) {
      result['canJoinMulticast'] = false;
      result['multicastError'] = e.toString();
    }
    
    return result;
  }
  
  /// 执行SSDP发现测试
  static Future<Map<String, dynamic>> testSsdpDiscovery() async {
    final result = <String, dynamic>{};
    
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      // SSDP M-SEARCH 消息
      const ssdpMessage = '''M-SEARCH * HTTP/1.1\r
HOST: 239.255.255.250:1900\r
MAN: "ssdp:discover"\r
ST: upnp:rootdevice\r
MX: 3\r
\r
''';
      
      final multicastAddress = InternetAddress('239.255.255.250');
      const multicastPort = 1900;
      
      // 发送SSDP搜索请求
      socket.send(ssdpMessage.codeUnits, multicastAddress, multicastPort);
      
      // 监听响应
      final responses = <String>[];
      final completer = Completer<void>();
      
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final response = String.fromCharCodes(datagram.data);
            responses.add(response);
          }
        }
      });
      
      // 等待3秒收集响应
      Timer(const Duration(seconds: 3), () {
        socket.close();
        completer.complete();
      });
      
      await completer.future;
      
      result['ssdpSent'] = true;
      result['responsesReceived'] = responses.length;
      result['responses'] = responses;
      
    } catch (e) {
      result['ssdpSent'] = false;
      result['ssdpError'] = e.toString();
    }
    
    return result;
  }
  
  /// 生成诊断报告
  static Future<String> generateDiagnosticReport() async {
    final report = StringBuffer();
    report.writeln('=== DLNA网络诊断报告 ===\n');
    
    // 网络状态检查
    report.writeln('1. 网络连接状态:');
    final networkStatus = await checkNetworkStatus();
    if (networkStatus['hasWifiInterface'] == true) {
      report.writeln('   ✓ 检测到WiFi网络接口');
      report.writeln('   WiFi接口: ${networkStatus['wifiInterfaces']}');
    } else {
      report.writeln('   ✗ 未检测到WiFi网络接口');
    }
    
    if (networkStatus['hasLocalIP'] == true) {
      report.writeln('   ✓ 检测到局域网IP地址');
      report.writeln('   局域网IP: ${networkStatus['localIPs']}');
    } else {
      report.writeln('   ✗ 未检测到局域网IP地址');
    }
    
    if (networkStatus['error'] != null) {
      report.writeln('   错误: ${networkStatus['error']}');
    }
    
    report.writeln();
    
    // 多播支持检查
    report.writeln('2. 多播支持检查:');
    final multicastStatus = await checkMulticastSupport();
    if (multicastStatus['canJoinMulticast'] == true) {
      report.writeln('   ✓ 支持多播通信');
    } else {
      report.writeln('   ✗ 不支持多播通信');
      if (multicastStatus['multicastError'] != null) {
        report.writeln('   错误: ${multicastStatus['multicastError']}');
      }
    }
    
    report.writeln();
    
    // SSDP发现测试
    report.writeln('3. SSDP设备发现测试:');
    final ssdpStatus = await testSsdpDiscovery();
    if (ssdpStatus['ssdpSent'] == true) {
      report.writeln('   ✓ SSDP搜索请求已发送');
      report.writeln('   收到响应数量: ${ssdpStatus['responsesReceived']}');
      if (ssdpStatus['responsesReceived'] > 0) {
        report.writeln('   ✓ 检测到DLNA/UPnP设备');
      } else {
        report.writeln('   ✗ 未检测到DLNA/UPnP设备响应');
      }
    } else {
      report.writeln('   ✗ SSDP搜索请求发送失败');
      if (ssdpStatus['ssdpError'] != null) {
        report.writeln('   错误: ${ssdpStatus['ssdpError']}');
      }
    }
    
    report.writeln();
    
    // 建议
    report.writeln('4. 故障排除建议:');
    if (networkStatus['hasLocalIP'] != true) {
      report.writeln('   • 请确保设备已连接到WiFi网络');
    }
    if (multicastStatus['canJoinMulticast'] != true) {
      report.writeln('   • 请检查应用是否有网络权限');
      report.writeln('   • 请检查路由器是否支持多播');
    }
    if (ssdpStatus['responsesReceived'] == 0) {
      report.writeln('   • 请确保DLNA设备已开启并连接到同一网络');
      report.writeln('   • 请检查防火墙设置是否阻止了DLNA通信');
      report.writeln('   • 请尝试重启路由器和DLNA设备');
    }
    
    return report.toString();
  }
}
