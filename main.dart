import 'package:polymorphic_bot/api.dart';

main(List<String> args, port) => polymorphic(args, port);

@BotInstance()
BotConnector bot;
@PluginInstance()
Plugin plugin;
bool enabled = true;

@Start()
start() => print("[Relay] Loading Plugin");

@RemoteMethod()
void isEnabled(RemoteCall call) => call.reply(enabled);

@OnJoin()
void handleJoin(JoinEvent event) {
  if (!enabled) {
    return;
  }
  
  String user = event.user;
  String network = event.network;
  String channel = event.channel;
  
  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    sendTo.remove(network);
    sendTo.forEach((net) {
      bot.sendMessage(net, channel, "[${network}] ${user} joined");
    });
  });
}

@OnPart()
void handlePart(PartEvent event) {
  if (!enabled) {
    return;
  }
  
  String user = event.user;
  String network = event.network;
  String channel = event.channel;
  
  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    sendTo.remove(network);
    sendTo.forEach((net) {
      bot.sendMessage(net, channel, "[${network}] ${user} left");
    });
  });
}

@OnMessage()
void handleMessage(MessageEvent event) {
  if (!enabled) {
    return;
  }
  
  var message = "[${event.network}] <-${event.from}> ${event.message}";

  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    
    sendTo.remove(event.network);
    sendTo.forEach((network) {
      bot.sendMessage(network, event.target, message);
    });
  });
}

dynamic copy(dynamic input) {
  if (input is List) {
    return new List.from(input);
  } else if (input is Map) {
    return new Map.from(input);
  } else {
    throw new Exception("data type not able to be copied");
  }
}
