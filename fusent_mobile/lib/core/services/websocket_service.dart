import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';

class WebSocketService {
  StompClient? _stompClient;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  
  bool _isConnected = false;
  String? _currentUserId;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream => _readReceiptController.stream;

  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect(String userId, String token) async {
    if (_isConnected) {
      print('WebSocket already connected');
      return;
    }

    _currentUserId = userId;

    // WebSocket URL: ws://host:port/ws
    final wsUrl = ApiEndpoints.baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    final socketUrl = '$wsUrl/ws';

    print('Connecting to WebSocket: $socketUrl');

    _stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: _onConnect,
        onWebSocketError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onStompError: (frame) {
          print('STOMP error: ${frame.body}');
        },
        onDisconnect: (frame) {
          print('WebSocket disconnected');
          _isConnected = false;
        },
        beforeConnect: () async {
          print('Connecting to WebSocket...');
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket connected successfully');
    _isConnected = true;

    // Subscribe to personal message queue
    _stompClient!.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null) {
          print('Received message: ${frame.body}');
          try {
            final message = _parseJson(frame.body!);
            _messageController.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }
      },
    );

    // Subscribe to typing indicators
    _stompClient!.subscribe(
      destination: '/user/queue/typing',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final typing = _parseJson(frame.body!);
            _typingController.add(typing);
          } catch (e) {
            print('Error parsing typing indicator: $e');
          }
        }
      },
    );

    // Subscribe to read receipts
    _stompClient!.subscribe(
      destination: '/user/queue/read-receipts',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final receipt = _parseJson(frame.body!);
            _readReceiptController.add(receipt);
          } catch (e) {
            print('Error parsing read receipt: $e');
          }
        }
      },
    );

    // Subscribe to errors
    _stompClient!.subscribe(
      destination: '/user/queue/errors',
      callback: (frame) {
        if (frame.body != null) {
          print('Error from server: ${frame.body}');
        }
      },
    );
  }

  /// Send a message via WebSocket
  void sendMessage({
    required String recipientId,
    required String content,
    String? conversationId,
  }) {
    if (!_isConnected || _stompClient == null) {
      print('WebSocket not connected');
      return;
    }

    final message = {
      'recipientId': recipientId,
      'content': content,
      if (conversationId != null) 'conversationId': conversationId,
    };

    _stompClient!.send(
      destination: '/app/chat.sendMessage',
      body: _toJson(message),
    );

    print('Message sent to $recipientId');
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String recipientId,
    required String conversationId,
    required bool isTyping,
  }) {
    if (!_isConnected || _stompClient == null) return;

    final indicator = {
      'recipientId': recipientId,
      'conversationId': conversationId,
      'isTyping': isTyping,
    };

    _stompClient!.send(
      destination: '/app/chat.typing',
      body: _toJson(indicator),
    );
  }

  /// Mark message as read
  void markAsRead(String messageId) {
    if (!_isConnected || _stompClient == null) return;

    final request = {
      'messageId': messageId,
    };

    _stompClient!.send(
      destination: '/app/chat.markRead',
      body: _toJson(request),
    );
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    print('WebSocket disconnected');
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readReceiptController.close();
  }

  // Helper methods for JSON parsing
  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON: $e');
      return {};
    }
  }

  String _toJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      print('Error encoding JSON: $e');
      return '{}';
    }
  }
}
