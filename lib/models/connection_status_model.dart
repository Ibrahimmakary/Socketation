/// Enum representing different WebSocket connection states
///
/// Used to track and display the current connection status in the UI
enum ConnectionStatus {
  /// Not connected to any WebSocket server
  disconnected,

  /// Currently attempting to establish connection
  connecting,

  /// Successfully connected to WebSocket server
  connected,

  /// Connection failed or encountered an error
  error,

  /// Connection was lost after being established
  reconnecting,
}

/// Extension to provide human-readable descriptions for connection status
extension ConnectionStatusExtension on ConnectionStatus {
  /// Returns a user-friendly string representation of the connection status
  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
    }
  }

  /// Returns appropriate color for UI display based on status
  /// Used for status indicators and text coloring
  String get colorHex {
    switch (this) {
      case ConnectionStatus.disconnected:
        return '#757575'; // Grey
      case ConnectionStatus.connecting:
        return '#FF9800'; // Orange
      case ConnectionStatus.connected:
        return '#4CAF50'; // Green
      case ConnectionStatus.error:
        return '#F44336'; // Red
      case ConnectionStatus.reconnecting:
        return '#2196F3'; // Blue
    }
  }
}
