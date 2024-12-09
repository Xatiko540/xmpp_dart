import 'package:xmpp_client_web/src/roster/Buddy.dart';

abstract class RosterListener {
  void onRosterListChanged(List<Buddy> roster);
}
