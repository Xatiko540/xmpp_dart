import 'package:xmpp_client_web/src/data/Jid.dart';

abstract class MessageApi {
  void sendMessage(Jid to, String text);
}
