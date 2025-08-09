/// Immutable model representing a custom WebSocket event listener
///
/// Manages user-defined event listeners for Socket.IO communication
class WebsocketEventListenerModel {
  /// Unique identifier for the event listener
  final String id;

  /// The event name to listen for
  final String eventName;

  /// Whether this listener is currently active
  final bool isActive;

  /// Timestamp when the listener was created
  final DateTime createdAt;

  /// Optional description of what this event does
  final String? description;

  /// Creates a new WebSocket event listener instance
  ///
  /// [id] - Unique identifier for the listener
  /// [eventName] - Name of the event to listen for
  /// [isActive] - Whether the listener is currently active
  /// [createdAt] - When the listener was created
  /// [description] - Optional description of the event
  const WebsocketEventListenerModel({
    required this.id,
    required this.eventName,
    required this.isActive,
    required this.createdAt,
    this.description,
  });

  /// Creates an event listener from JSON data
  ///
  /// Used for persistence or data transfer
  factory WebsocketEventListenerModel.fromJson(Map<String, dynamic> json) {
    return WebsocketEventListenerModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      eventName: json['eventName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      description: json['description'],
    );
  }

  /// Converts the event listener to JSON format
  ///
  /// Used for persistence or data transfer
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (description != null) 'description': description,
    };
  }

  /// Creates a copy of this event listener with optional parameter changes
  ///
  /// Useful for toggling active state or updating properties
  WebsocketEventListenerModel copyWith({
    String? id,
    String? eventName,
    bool? isActive,
    DateTime? createdAt,
    String? description,
  }) {
    return WebsocketEventListenerModel(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  /// Returns display name for the event listener
  ///
  /// Shows event name with status indicator
  String get displayName {
    final status = isActive ? '🟢' : '🔴';
    return '$status $eventName';
  }

  @override
  String toString() {
    return 'WebsocketEventListenerModel(id: $id, eventName: $eventName, isActive: $isActive, createdAt: $createdAt, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebsocketEventListenerModel &&
        other.id == id &&
        other.eventName == eventName &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventName.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        description.hashCode;
  }
}
