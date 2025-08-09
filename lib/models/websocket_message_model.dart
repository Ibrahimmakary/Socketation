/// Immutable model representing a WebSocket message
///
/// Handles both incoming and outgoing messages with proper serialization
class WebsocketMessageModel {
  /// Unique identifier for the message
  final String id;

  /// The event name/type for this message
  final String event;

  /// The message payload data (can be String or Map)
  final dynamic data;

  /// Timestamp when the message was created/received
  final DateTime timestamp;

  /// Whether this message was sent by the user (true) or received (false)
  final bool isOutgoing;

  /// Optional error message if the message failed to send/receive
  final String? error;

  /// Creates a new WebSocket message instance
  ///
  /// [id] - Unique identifier for the message
  /// [event] - Event name/type
  /// [data] - Message payload
  /// [timestamp] - When the message was created
  /// [isOutgoing] - True if sent by user, false if received
  /// [error] - Optional error description
  const WebsocketMessageModel({
    required this.id,
    required this.event,
    required this.data,
    required this.timestamp,
    required this.isOutgoing,
    this.error,
  });

  /// Creates a WebSocket message from JSON data
  ///
  /// Used when deserializing messages from the server
  factory WebsocketMessageModel.fromJson(Map<String, dynamic> json) {
    return WebsocketMessageModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      event: json['event'] ?? 'unknown',
      data: json['data'],
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      isOutgoing: json['isOutgoing'] ?? false,
      error: json['error'],
    );
  }

  /// Converts the message to JSON format
  ///
  /// Used when sending messages to the server or storing locally
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isOutgoing': isOutgoing,
      if (error != null) 'error': error,
    };
  }

  /// Creates a copy of this message with optional parameter changes
  ///
  /// Useful for updating message status or adding error information
  WebsocketMessageModel copyWith({
    String? id,
    String? event,
    dynamic data,
    DateTime? timestamp,
    bool? isOutgoing,
    String? error,
  }) {
    return WebsocketMessageModel(
      id: id ?? this.id,
      event: event ?? this.event,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      error: error ?? this.error,
    );
  }

  /// Returns a formatted string representation of the message data
  ///
  /// Handles different data types for display purposes
  String get formattedData {
    if (data == null) return 'null';
    if (data is String) return data;
    if (data is Map || data is List) {
      try {
        return data.toString();
      } catch (e) {
        return 'Invalid data format';
      }
    }
    return data.toString();
  }

  @override
  String toString() {
    return 'WebsocketMessageModel(id: $id, event: $event, data: $data, timestamp: $timestamp, isOutgoing: $isOutgoing, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebsocketMessageModel &&
        other.id == id &&
        other.event == event &&
        other.data == data &&
        other.timestamp == timestamp &&
        other.isOutgoing == isOutgoing &&
        other.error == error;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        event.hashCode ^
        data.hashCode ^
        timestamp.hashCode ^
        isOutgoing.hashCode ^
        error.hashCode;
  }
}
