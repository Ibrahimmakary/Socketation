import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/websocket_controller.dart';
import '../models/connection_status_model.dart';
import '../models/websocket_message_model.dart';
import '../models/websocket_event_listener_model.dart';

/// Main view for WebSocket testing interface
///
/// Provides comprehensive UI for testing WebSocket connections with Socket.IO
class WebsocketTestingView extends StatelessWidget {
  const WebsocketTestingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller using GetX dependency injection
    final WebsocketController controller = Get.put(WebsocketController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Tester'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        children: [
          // Connection section
          _buildConnectionSection(controller),

          // Event listeners section
          _buildEventListenersSection(controller),

          // Message sending section
          _buildMessageSendingSection(controller),

          // Messages display section
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 300,
            child: _buildMessagesSection(controller),
          ),
        ],
      ),
    );
  }

  /// Builds the WebSocket connection control section
  ///
  /// Contains URL input, connection status, and connect/disconnect buttons
  Widget _buildConnectionSection(WebsocketController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WebSocket Connection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // URL input field
          TextField(
            controller: controller.urlController,
            decoration: const InputDecoration(
              labelText: 'WebSocket URL',
              hintText: 'ws://localhost:3000 or http://localhost:3000',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: controller.updateWebSocketUrl,
          ),
          const SizedBox(height: 12),

          // Connection status and controls
          Row(
            children: [
              // Connection status indicator
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(controller.connectionStatus.value),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(controller.connectionStatus.value),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.connectionStatus.value.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Connect button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.connectionStatus.value ==
                            ConnectionStatus.connected
                      ? null // Disable when already connected
                      : controller.connectToWebSocket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Connect'),
                ),
              ),

              const SizedBox(width: 8),

              // Disconnect button - always available when not disconnected
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.connectionStatus.value ==
                          ConnectionStatus.disconnected
                      ? null // Disable when already disconnected
                      : controller.disconnectFromWebSocket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Disconnect'),
                ),
              ),
            ],
          ),

          // Error message display
          Obx(
            () => controller.errorMessage.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds the event listeners management section
  ///
  /// Shows active listeners and allows adding/removing custom events
  Widget _buildEventListenersSection(WebsocketController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Listeners',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Add new event listener
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.newEventListenerController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Enter event name to listen for',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  controller.addEventListener(
                    controller.newEventListenerController.text,
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active event listeners list
          Obx(
            () => controller.eventListeners.isEmpty
                ? const Text('No event listeners added')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.eventListeners
                        .map(
                          (listener) =>
                              _buildEventListenerChip(controller, listener),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds the message sending section
  ///
  /// Contains event name input, message content input, and send button
  Widget _buildMessageSendingSection(WebsocketController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Message',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name input
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: controller.eventNameController,
                      decoration: const InputDecoration(
                        labelText: 'Event',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: controller.updateCurrentEventName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message content input
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller.messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (JSON or text)',
                        hintText: '{"key": "value"} or simple text',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: controller.updateCurrentMessage,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Send button
              ElevatedButton.icon(
                onPressed: controller.sendMessage,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the messages display section
  ///
  /// Shows real-time message history with scrollable list
  Widget _buildMessagesSection(WebsocketController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Messages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: controller.clearMessages,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Messages list
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet. Connect and start sending/receiving messages.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      controller: controller.messagesScrollController,
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        return _buildMessageItem(message);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single event listener chip
  ///
  /// Shows event name with toggle and remove functionality
  Widget _buildEventListenerChip(
    WebsocketController controller,
    WebsocketEventListenerModel listener,
  ) {
    return Chip(
      label: Text(listener.eventName),
      backgroundColor: listener.isActive ? Colors.green[100] : Colors.grey[200],
      avatar: CircleAvatar(
        backgroundColor: listener.isActive ? Colors.green : Colors.grey,
        radius: 8,
      ),
      onDeleted: () => controller.removeEventListener(listener.id),
      deleteIcon: const Icon(Icons.close, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: listener.isActive ? Colors.green[300]! : Colors.grey[400]!,
      ),
    );
  }

  /// Builds a single message item in the messages list
  ///
  /// Shows timestamp, event, direction, and message content
  Widget _buildMessageItem(WebsocketMessageModel message) {
    final isSystem = message.event == 'system';
    final isOutgoing = message.isOutgoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSystem
            ? Colors.blue[50]
            : isOutgoing
            ? Colors.green[50]
            : Colors.grey[50],
        border: Border.all(
          color: isSystem
              ? Colors.blue[200]!
              : isOutgoing
              ? Colors.green[200]!
              : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with timestamp and event
          Row(
            children: [
              Icon(
                isSystem
                    ? Icons.info
                    : isOutgoing
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: isSystem
                    ? Colors.blue[700]
                    : isOutgoing
                    ? Colors.green[700]
                    : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                message.event,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSystem
                      ? Colors.blue[700]
                      : isOutgoing
                      ? Colors.green[700]
                      : Colors.grey[700],
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Message content
          Text(message.formattedData, style: const TextStyle(fontSize: 14)),

          // Error message if any
          if (message.error != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${message.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Gets the appropriate color for connection status
  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.reconnecting:
        return Colors.blue;
    }
  }

  /// Gets the appropriate icon for connection status
  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return Icons.cloud_off;
      case ConnectionStatus.connecting:
        return Icons.cloud_sync;
      case ConnectionStatus.connected:
        return Icons.cloud_done;
      case ConnectionStatus.error:
        return Icons.error;
      case ConnectionStatus.reconnecting:
        return Icons.refresh;
    }
  }

  /// Formats timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
