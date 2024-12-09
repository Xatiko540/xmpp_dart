import 'dart:async';
import 'package:xmpp_client_web/src/logger/Log.dart';
import 'package:xmpp_client_web/xmpp_stone.dart' as xmpp;

final String TAG = 'example';

void main(List<String> arguments) async {
  Log.logLevel = LogLevel.DEBUG;
  Log.logXmpp = false;

  Log.d(TAG, 'Setting up XMPP connection...');
  var userAtDomain = 'nemanja@127.0.0.1';
  var password = '1';
  var jid = xmpp.Jid.fromFullJid(userAtDomain);
  var account = xmpp.XmppAccountSettings(
      userAtDomain, jid.local, jid.domain, password, 5222,
      resource: 'xmppstone');

  var connection = xmpp.Connection(account);

  // Регистрация слушателей
  connection.connectionStateStream.listen((state) {
    Log.d(TAG, 'Connection state: $state');
    if (state == xmpp.XmppConnectionState.ForcefullyClosed) {
      Log.d(TAG, 'Connection lost. Attempting to reconnect...');
      reconnect(connection);
    }
  });

  var messagesListener = ExampleMessagesListener();
  ExampleConnectionStateChangedListener(connection, messagesListener);

  var presenceManager = xmpp.PresenceManager.getInstance(connection);
  presenceManager.subscriptionStream.listen((streamEvent) {
    if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
      Log.d(TAG, 'Accepting presence request');
      presenceManager.acceptSubscription(streamEvent.jid);
    }
  });

  var receiver = 'nemanja2@test';
  var receiverJid = xmpp.Jid.fromFullJid(receiver);
  var messageHandler = xmpp.MessageHandler.getInstance(connection);

  // Ожидание подключения
  await waitForConnectionReady(connection);

  // Отправка сообщения
  sendMessageSafely(messageHandler, receiverJid, 'Hello from xmpp_stone!');

  // Подключение
  connection.connect();
}

// Ожидание готовности подключения
Future<void> waitForConnectionReady(xmpp.Connection connection) async {
  while (connection.state != xmpp.XmppConnectionState.Ready) {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Переподключение
void reconnect(xmpp.Connection connection) async {
  Log.d(TAG, 'Attempting to reconnect...');
  await Future.delayed(const Duration(seconds: 2));
  connection.connect();
}

// Безопасная отправка сообщений
void sendMessageSafely(xmpp.MessageHandler handler, xmpp.Jid receiverJid, String message) {
  try {
    handler.sendMessage(receiverJid, message);
    Log.d(TAG, 'Message sent: $message');
  } catch (e) {
    Log.d(TAG, 'Failed to send message: $e');
  }
}

class ExampleConnectionStateChangedListener
    implements xmpp.ConnectionStateChangedListener {
  late xmpp.Connection _connection;
  late xmpp.MessagesListener _messagesListener;

  ExampleConnectionStateChangedListener(
      xmpp.Connection connection, xmpp.MessagesListener messagesListener) {
    _connection = connection;
    _messagesListener = messagesListener;
    _connection.connectionStateStream.listen(onConnectionStateChanged);
  }

  @override
  void onConnectionStateChanged(xmpp.XmppConnectionState state) {
    if (state == xmpp.XmppConnectionState.Ready) {
      Log.d(TAG, 'Connected');
      setupXMPPFeatures();
    }
  }

  Future<void> setupXMPPFeatures() async {
    var vCardManager = xmpp.VCardManager(_connection);
    var messageHandler = xmpp.MessageHandler.getInstance(_connection);
    var rosterManager = xmpp.RosterManager.getInstance(_connection);

    // Получение собственной VCard
    var vCard = await vCardManager.getSelfVCard();
    Log.d(TAG, 'Your info: ${vCard.buildXmlString()}');

    // Добавление контакта в ростер
    var receiver = 'nemanja2@test';
    var receiverJid = xmpp.Jid.fromFullJid(receiver);
    var addResult = await rosterManager.addRosterItem(xmpp.Buddy(receiverJid));
    if (addResult.description != null) {
      Log.d(TAG, 'Roster added: ${addResult.description}');
    }

    // Получение VCard контакта
    var receiverVCard = await vCardManager.getVCardFor(receiverJid);
    Log.d(TAG, 'Receiver info: ${receiverVCard.buildXmlString()}');

    // Подключение слушателя присутствия
    var presenceManager = xmpp.PresenceManager.getInstance(_connection);
    presenceManager.presenceStream.listen(onPresence);

    // Слушатель сообщений
    messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
  }

  void onPresence(xmpp.PresenceData event) {
    Log.d(TAG, 'Presence event from ${event.jid!.fullJid!}: ${event.showElement}');
  }
}

class ExampleMessagesListener implements xmpp.MessagesListener {
  @override
  void onNewMessage(xmpp.MessageStanza? message) {
    if (message?.body != null) {
      Log.d(TAG, 'New Message from ${message!.fromJid!.userAtDomain}: ${message.body}');
    }
  }
}