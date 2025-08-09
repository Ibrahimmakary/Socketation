import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/websocket_message_model.dart';
import '../models/connection_status_model.dart';

/// Service class handling all Socket.IO WebSocket operations
///
/// Manages connection, disconnection, event listening, and message sending
class WebsocketServices {
  /// Socket.IO client instance
  io.Socket? _socket;

  /// Current WebSocket server URL
  String? _currentUrl;

  /// Map to store active event listeners
  final Map<String, Function> _eventListeners = {};

  /// Callback for sending messages to the UI
  Function(String)? _onMessage;

  /// Callback for connection status changes
  Function(ConnectionStatus)? _onStatusChange;

  /// Gets the current socket instance
  io.Socket? get socket => _socket;

  /// Gets the current connection URL
  String? get currentUrl => _currentUrl;

  /// Checks if currently connected to a WebSocket server
  bool get isConnected => _socket?.connected ?? false;

  /// Sets the message callback for UI updates
  ///
  /// [callback] - Function to call when service needs to send a message to UI
  void setMessageCallback(Function(String) callback) {
    _onMessage = callback;
  }

  /// Sets the status change callback
  ///
  /// [callback] - Function to call when connection status changes
  void setStatusChangeCallback(Function(ConnectionStatus) callback) {
    _onStatusChange = callback;
  }

  /// Sends a message to the UI instead of printing to console
  ///
  /// [message] - The message to send to the UI
  void _sendMessage(String message) {
    if (_onMessage != null) {
      _onMessage!(message);
    }
  }

  /// Updates connection status and notifies UI
  ///
  /// [status] - The new connection status
  void _updateStatus(ConnectionStatus status) {
    if (_onStatusChange != null) {
      _onStatusChange!(status);
    }
  }

  /// Connects to a WebSocket server using Socket.IO
  ///
  /// [url] - The WebSocket server URL (e.g., 'http://localhost:3000')
  /// [options] - Optional connection configuration
  ///
  /// Returns Future<bool> indicating success/failure
  Future<bool> connect(String url, {Map<String, dynamic>? options}) async {
    try {
      // Disconnect existing connection if any
      await disconnect();

      _currentUrl = url;
      _sendMessage('Attempting to connect to: $url');

      // Create Socket.IO client with options
      _socket = io.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'timeout': 20000,
        'forceNew': true,
        ...?options,
      });

      // Set up default event listeners
      _setupDefaultListeners();

      // Connect to server
      _socket!.connect();

      return true;
    } catch (e) {
      _sendMessage('WebSocket connection error: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    }
  }

  /// Disconnects from the current WebSocket server
  ///
  /// Cleans up all listeners and socket instance
  Future<void> disconnect() async {
    try {
      if (_socket != null) {
        _sendMessage('Disconnecting from WebSocket server...');
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
      _eventListeners.clear();
      _currentUrl = null;
      _updateStatus(ConnectionStatus.disconnected);
    } catch (e) {
      _sendMessage('WebSocket disconnection error: $e');
    }
  }

  /// Sends a message to the WebSocket server
  ///
  /// [event] - The event name/type
  /// [data] - The message payload (can be String, Map, List, etc.)
  ///
  /// Returns Future<bool> indicating if message was sent successfully
  Future<bool> sendMessage(String event, dynamic data) async {
    try {
      if (_socket == null || !_socket!.connected) {
        _sendMessage('Cannot send message: Not connected to WebSocket server');
        return false;
      }

      // Send the message with event and data
      _socket!.emit(event, data);
      _sendMessage('Message sent successfully: $event');
      return true;
    } catch (e) {
      _sendMessage('Error sending WebSocket message: $e');
      return false;
    }
  }

  /// Adds a custom event listener
  ///
  /// [eventName] - Name of the event to listen for
  /// [callback] - Function to call when event is received
  void addEventListener(String eventName, void Function(dynamic) callback) {
    try {
      if (_socket == null) {
        _sendMessage('Cannot add event listener: Socket not initialized');
        return;
      }

      // Remove existing listener if any
      removeEventListener(eventName);

      // Add new listener
      _socket!.on(eventName, callback);
      _eventListeners[eventName] = callback;

      _sendMessage('Added event listener for: $eventName');
    } catch (e) {
      _sendMessage('Error adding event listener for $eventName: $e');
    }
  }

  /// Removes a custom event listener
  ///
  /// [eventName] - Name of the event listener to remove
  void removeEventListener(String eventName) {
    try {
      if (_socket != null && _eventListeners.containsKey(eventName)) {
        _socket!.off(eventName);
        _eventListeners.remove(eventName);
        _sendMessage('Removed event listener for: $eventName');
      }
    } catch (e) {
      _sendMessage('Error removing event listener for $eventName: $e');
    }
  }

  /// Gets list of currently active event listener names
  List<String> getActiveEventListeners() {
    return _eventListeners.keys.toList();
  }

  /// Sets up default Socket.IO event listeners
  ///
  /// Handles connection, disconnection, and error events
  void _setupDefaultListeners() {
    if (_socket == null) return;

    // Connection established
    _socket!.on('connect', (data) {
      _sendMessage('WebSocket connected successfully');
      _updateStatus(ConnectionStatus.connected);
    });

    // Connection error - DO NOT auto-disconnect
    _socket!.on('connect_error', (error) {
      _sendMessage('WebSocket connection error: $error');
      _updateStatus(ConnectionStatus.error);
      // Note: We don't auto-disconnect here to allow manual retry
    });

    // Disconnection
    _socket!.on('disconnect', (reason) {
      _sendMessage('WebSocket disconnected: $reason');
      _updateStatus(ConnectionStatus.disconnected);
    });

    // Generic error handling - DO NOT auto-disconnect
    _socket!.on('error', (error) {
      _sendMessage('WebSocket error: $error');
      // Note: We don't change status to error here to maintain current connection state
    });

    // Reconnection attempt
    _socket!.on('reconnect', (attemptNumber) {
      _sendMessage('WebSocket reconnected after $attemptNumber attempts');
      _updateStatus(ConnectionStatus.connected);
    });

    // Reconnection error
    _socket!.on('reconnect_error', (error) {
      _sendMessage('WebSocket reconnection error: $error');
      _updateStatus(ConnectionStatus.reconnecting);
    });

    // Reconnecting status
    _socket!.on('reconnecting', (attemptNumber) {
      _sendMessage('WebSocket reconnecting... Attempt: $attemptNumber');
      _updateStatus(ConnectionStatus.reconnecting);
    });
  }

  /// Registers a callback for connection status changes
  ///
  /// [onStatusChange] - Callback function that receives ConnectionStatus
  void onConnectionStatusChange(Function(ConnectionStatus) onStatusChange) {
    _onStatusChange = onStatusChange;
  }

  /// Registers a callback for receiving messages
  ///
  /// [onMessageReceived] - Callback function that receives WebsocketMessageModel
  void onMessageReceived(Function(WebsocketMessageModel) onMessageReceived) {
    // This would be called by custom event listeners
    // The controller will handle specific event listeners and create message models
  }

  /// Cleans up all resources
  ///
  /// Should be called when the service is no longer needed
  void dispose() {
    disconnect();
  }
}
