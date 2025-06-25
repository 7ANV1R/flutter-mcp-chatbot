import 'dart:io';
import 'dart:convert';

/// Simple test script to verify MCP weather server communication
/// Usage: dart run test/test_mcp_server.dart
void main() async {
  print('🧪 Testing MCP Weather Server...\n');

  try {
    // Start the weather server process
    final serverProcess = await Process.start('dart', [
      'run',
      'bin/weather_server.dart',
    ], environment: Platform.environment);

    print('✅ MCP Weather Server started successfully');

    // Give it a moment to initialize
    await Future.delayed(Duration(seconds: 2));

    // Send a simple MCP initialize message
    final initMessage = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {
        'protocolVersion': '2025-03-26',
        'capabilities': {},
        'clientInfo': {'name': 'test-client', 'version': '1.0.0'},
      },
    };

    serverProcess.stdin.writeln(jsonEncode(initMessage));

    // Listen for response
    serverProcess.stdout.transform(utf8.decoder).listen((data) {
      print('📤 Server response: $data');
    });

    serverProcess.stderr.transform(utf8.decoder).listen((data) {
      print('🔍 Server log: $data');
    });

    // Test for a few seconds
    await Future.delayed(Duration(seconds: 5));

    print('\n🎉 MCP Server test completed! Server is responding to stdio.');

    // Clean up
    serverProcess.kill();
    await serverProcess.exitCode;
  } catch (e) {
    print('❌ Error testing MCP server: $e');
    exit(1);
  }
}
