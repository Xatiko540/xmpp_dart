import 'package:xmpp_client_web/src/Connection.dart';

abstract class ConnectionStateChangedListener {
  void onConnectionStateChanged(XmppConnectionState state);
}
