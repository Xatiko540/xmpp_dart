import 'package:xmpp_client_web/src/elements/XmppAttribute.dart';
import 'package:xmpp_client_web/src/elements/nonzas/Nonza.dart';

class EnableNonza extends Nonza {
  static String NAME = 'enable';
  static String XMLNS = 'urn:xmpp:sm:3';

  static bool match(Nonza nonza) =>
      (nonza.name == NAME && nonza.getAttribute('xmlns')!.value == XMLNS);

  EnableNonza(bool resume) {
    name = NAME;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:sm:3'));
    if (resume) {
      addAttribute(XmppAttribute('resume', 'true'));
    }
  }
}
