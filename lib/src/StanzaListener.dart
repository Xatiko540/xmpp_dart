import 'package:xmpp_client_web/src/elements/stanzas/AbstractStanza.dart';

abstract class StanzaProcessor {
  void processStanza(AbstractStanza stanza);
}
