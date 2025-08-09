import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/websocket_message_model.dart';
import '../models/websocket_event_listener_model.dart';
import '../models/connection_status_model.dart';
import '../services/websocket_services.dart';

/// GetX controller managing WebSocket testing functionality
///
/// Handles all state management, user interactions, and WebSocket operations
class WebsocketController extends GetxController {
  /// WebSocket service instance
  final WebsocketServices _websocketServices = WebsocketServices();

  // Reactive variables for UI state management

  /// Current connection status
  final Rx<ConnectionStatus> connectionStatus =
      ConnectionStatus.disconnected.obs;

  /// WebSocket server URL input
  final RxString websocketUrl = 'ws://localhost:3000'.obs;

  /// List of all messages (sent and received)
  final RxList<WebsocketMessageModel> messages = <WebsocketMessageModel>[].obs;

  /// List of custom event listeners
  final RxList<WebsocketEventListenerModel> eventListeners =
      <WebsocketEventListenerModel>[].obs;

  /// Current message to send
  final RxString currentMessage = ''.obs;

  /// Current event name for sending messages
  final RxString currentEventName = 'message'.obs;

  /// Error message to display
  final RxString errorMessage = ''.obs;

  /// Loading state for connection operations
  final RxBool isLoading = false.obs;

  // Text controllers for input fields
  final TextEditingController urlController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController newEventListenerController =
      TextEditingController();

  /// Scroll controller for messages list
  final ScrollController messagesScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupDefaultEventListeners();
  }

  @override
  void onClose() {
    _websocketServices.dispose();
    urlController.dispose();
    messageController.dispose();
    eventNameController.dispose();
    newEventListenerController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }

  /// Initializes text controllers with default values
  void _initializeControllers() {
    urlController.text = websocketUrl.value;
    eventNameController.text = currentEventName.value;
  }

  /// Sets up default event listeners for common Socket.IO events
  void _setupDefaultEventListeners() {
    final defaultEvents = [
      'connect',
      'disconnect',
      'error',
      'message',
      'notification',
    ];

    for (String eventName in defaultEvents) {
      final listener = WebsocketEventListenerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + eventName,
        eventName: eventName,
        isActive: true,
        createdAt: DateTime.now(),
        description: 'Default Socket.IO event',
      );
      eventListeners.add(listener);
    }
  }

  /// Connects to the WebSocket server
  ///
  /// Validates URL and establishes connection using WebSocket services
  Future<void> connectToWebSocket() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = urlController.text.trim();
      if (url.isEmpty) {
        errorMessage.value = 'Please enter a WebSocket URL';
        return;
      }

      // Validate URL format
      if (!_isValidUrl(url)) {
        errorMessage.value =
            'Please enter a valid URL (e.g., http://localhost:3000)';
        return;
      }

      connectionStatus.value = ConnectionStatus.connecting;
      websocketUrl.value = url;

      // Setup service callbacks to route messages to UI
      _websocketServices.setMessageCallback((message) {
        _addSystemMessage(message);
      });

      _websocketServices.setStatusChangeCallback((status) {
        connectionStatus.value = status;
      });

      // Attempt connection
      final success = await _websocketServices.connect(url);

      if (success) {
        _setupActiveEventListeners();
        // Note: Success message will come from service callback
      } else {
        connectionStatus.value = ConnectionStatus.error;
        errorMessage.value = 'Failed to connect to WebSocket server';
        _addSystemMessage('Failed to connect to $url');
      }
    } catch (e) {
      connectionStatus.value = ConnectionStatus.error;
      errorMessage.value = 'Connection error: $e';
      _addSystemMessage('Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Disconnects from the WebSocket server
  Future<void> disconnectFromWebSocket() async {
    try {
      isLoading.value = true;
      await _websocketServices.disconnect();
      connectionStatus.value = ConnectionStatus.disconnected;
      _addSystemMessage('Disconnected from WebSocket server');
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Disconnection error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends a message to the WebSocket server
  ///
  /// Uses current event name and message content
  Future<void> sendMessage() async {
    try {
      final eventName = eventNameController.text.trim();
      final messageContent = messageController.text.trim();

      if (eventName.isEmpty) {
        errorMessage.value = 'Please enter an event name';
        return;
      }

      if (messageContent.isEmpty) {
        errorMessage.value = 'Please enter a message';
        return;
      }

      if (connectionStatus.value != ConnectionStatus.connected) {
        errorMessage.value = 'Not connected to WebSocket server';
        return;
      }

      // Try to parse message as JSON, fallback to string
      dynamic messageData;
      try {
        messageData = jsonDecode(messageContent);
      } catch (e) {
        messageData = messageContent;
      }

      // Send message through service
      final success = await _websocketServices.sendMessage(
        eventName,
        messageData,
      );

      if (success) {
        // Add sent message to list
        final sentMessage = WebsocketMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          event: eventName,
          data: messageData,
          timestamp: DateTime.now(),
          isOutgoing: true,
        );

        messages.add(sentMessage);
        messageController.clear();
        errorMessage.value = '';
        _scrollToBottom();
      } else {
        errorMessage.value = 'Failed to send message';
      }
    } catch (e) {
      errorMessage.value = 'Error sending message: $e';
    }
  }

  /// Adds a new custom event listener
  ///
  /// [eventName] - Name of the event to listen for
  void addEventListener(String eventName) {
    try {
      if (eventName.trim().isEmpty) {
        errorMessage.value = 'Please enter an event name';
        return;
      }

      // Check if listener already exists
      final existingListener = eventListeners.firstWhereOrNull(
        (listener) => listener.eventName == eventName.trim(),
      );

      if (existingListener != null) {
        errorMessage.value = 'Event listener for "$eventName" already exists';
        return;
      }

      // Create new event listener
      final listener = WebsocketEventListenerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventName: eventName.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        description: 'Custom event listener',
      );

      eventListeners.add(listener);

      // Setup the actual Socket.IO listener if connected
      if (connectionStatus.value == ConnectionStatus.connected) {
        _setupEventListener(listener);
      }

      newEventListenerController.clear();
      errorMessage.value = '';
      _addSystemMessage('Added event listener for: $eventName');
    } catch (e) {
      errorMessage.value = 'Error adding event listener: $e';
    }
  }

  /// Removes an event listener
  ///
  /// [listenerId] - ID of the listener to remove
  void removeEventListener(String listenerId) {
    try {
      final listener = eventListeners.firstWhereOrNull(
        (listener) => listener.id == listenerId,
      );

      if (listener != null) {
        // Remove from Socket.IO if connected
        if (connectionStatus.value == ConnectionStatus.connected) {
          _websocketServices.removeEventListener(listener.eventName);
        }

        eventListeners.removeWhere((listener) => listener.id == listenerId);
        _addSystemMessage('Removed event listener for: ${listener.eventName}');
      }
    } catch (e) {
      errorMessage.value = 'Error removing event listener: $e';
    }
  }

  /// Toggles an event listener on/off
  ///
  /// [listenerId] - ID of the listener to toggle
  void toggleEventListener(String listenerId) {
    try {
      final index = eventListeners.indexWhere(
        (listener) => listener.id == listenerId,
      );

      if (index != -1) {
        final listener = eventListeners[index];
        final updatedListener = listener.copyWith(isActive: !listener.isActive);
        eventListeners[index] = updatedListener;

        if (connectionStatus.value == ConnectionStatus.connected) {
          if (updatedListener.isActive) {
            _setupEventListener(updatedListener);
          } else {
            _websocketServices.removeEventListener(updatedListener.eventName);
          }
        }

        final status = updatedListener.isActive ? 'enabled' : 'disabled';
        _addSystemMessage(
          'Event listener "${updatedListener.eventName}" $status',
        );
      }
    } catch (e) {
      errorMessage.value = 'Error toggling event listener: $e';
    }
  }

  /// Clears all messages from the history
  void clearMessages() {
    messages.clear();
    _addSystemMessage('Message history cleared');
  }

  /// Sets up all active event listeners with Socket.IO
  void _setupActiveEventListeners() {
    for (final listener in eventListeners) {
      if (listener.isActive) {
        _setupEventListener(listener);
      }
    }
  }

  /// Sets up a single event listener with Socket.IO
  ///
  /// [listener] - The event listener model to setup
  void _setupEventListener(WebsocketEventListenerModel listener) {
    _websocketServices.addEventListener(listener.eventName, (data) {
      final receivedMessage = WebsocketMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        event: listener.eventName,
        data: data,
        timestamp: DateTime.now(),
        isOutgoing: false,
      );

      messages.add(receivedMessage);
      _scrollToBottom();
    });
  }

  /// Adds a system message to the message list
  ///
  /// [content] - The system message content
  void _addSystemMessage(String content) {
    final systemMessage = WebsocketMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      event: 'system',
      data: content,
      timestamp: DateTime.now(),
      isOutgoing: false,
    );

    messages.add(systemMessage);
    _scrollToBottom();
  }

  /// Scrolls to the bottom of the messages list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messagesScrollController.hasClients) {
        messagesScrollController.animateTo(
          messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Validates if a URL is properly formatted
  ///
  /// [url] - URL string to validate
  /// Returns true if valid, false otherwise
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Updates the WebSocket URL
  ///
  /// [url] - New URL to set
  void updateWebSocketUrl(String url) {
    websocketUrl.value = url;
  }

  /// Updates the current event name for sending messages
  ///
  /// [eventName] - New event name to set
  void updateCurrentEventName(String eventName) {
    currentEventName.value = eventName;
  }

  /// Updates the current message content
  ///
  /// [message] - New message content to set
  void updateCurrentMessage(String message) {
    currentMessage.value = message;
  }
}
