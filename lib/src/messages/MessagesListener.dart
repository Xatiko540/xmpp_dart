import 'package:xmpp_client_web/src/elements/stanzas/MessageStanza.dart';

abstract class MessagesListener {
  void onNewMessage(MessageStanza? message);
}
