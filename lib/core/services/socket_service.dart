import 'package:socket_io_client/socket_io_client.dart' as io;
import '../app_config.dart';

class SocketService {
  static io.Socket? _socket;
  
  static io.Socket? get socket => _socket;

  // 1. Initialize & Connect
  static void connect(String userToken) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(AppConfig.socketUrl,
      io.OptionBuilder()
        .setTransports(['websocket']) // Force High Performance
        .enableAutoConnect()
        .setQuery({'token': userToken}) // Pass JWT for security
        .build()
    );

    _socket?.on('connect', (_) {
      // ignore: avoid_print
      print('🟢 Live Dashboard Connected!');
    });

    _socket?.on('disconnect', (_) => 
      // ignore: avoid_print
      print('🔴 Dashboard Disconnected'));
    
    _socket?.on('error', (error) => 
      // ignore: avoid_print
      print('🟠 Socket Error: $error'));
    _socket?.on('connect_error', (error) => 
      // ignore: avoid_print
      print('🟠 Socket Connect Error: $error'));
  }

  // 2. Start Listening for YOUR WHOLE FLEET (Automatic)
  static void listenForFleet(Function(dynamic data) onUpdate) {
    // This receives every car movement for the logged-in user!
    _socket?.on('location_update', (data) {
      onUpdate(data);
    });
  }

  // 3. Start Listening for a SPECIFIC Car (Trace View)
  static void followDevice(String deviceId) {
    _socket?.emit('join_device', deviceId);
  }

  // 4. Listen for GLOBAL Updates (Superadmin only)
  static void listenForAllGlobalVehicles(Function(dynamic data) onUpdate) {
    _socket?.on('fleet_update', (data) {
      onUpdate(data);
    });
  }

  static void stopFollowingDevice(String deviceId) {
    _socket?.emit('leave_device', deviceId);
  }

  static void disconnect() {
    _socket?.destroy();
    _socket = null;
  }
}
