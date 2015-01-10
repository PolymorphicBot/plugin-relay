import 'package:polymorphic_bot/api.dart';

BotConnector bot;
Plugin plugin;
bool enabled;

void main(List<String> args, Plugin myPlugin) {
  plugin = myPlugin;
  print("[Relay] Loading Plugin");
  bot = plugin.getBot();
  
  enabled = true;
  
  bot.getConfig().then((config) {
    if (config.containsKey("relay")) {
      var relay = config["relay"];
      enabled = relay.containsKey("enabled") ? relay["enabled"] : true;
    }
  });
  
  plugin.addRemoteMethod("isEnabled", (request) {
    request.reply(enabled);
  });
  
  bot.onMessage(handleMessage);
  bot.onJoin(handleJoin);
  bot.onPart(handlePart);
}

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
