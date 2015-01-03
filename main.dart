import 'package:polymorphic_bot/api.dart';

BotConnector bot;
Plugin plugin;
bool enabled;

void main(List<String> args, Plugin myPlugin) {
  plugin = myPlugin;
  print("[Relay] Loading Plugin");
  bot = plugin.getBot();
  
  enabled = true;
  
  bot.config.then((response) {
    var config = response["config"];
    if (config.containsKey("relay")) {
      var relay = config["relay"];
      enabled = relay.containsKey("enabled") && !relay["enabled"];
    }
  });
  
  plugin.addRemoteMethod("enabled", (request) {
    request.reply({
      "enabled": enabled
    });
  });
  
  plugin.on("message").listen(handleMessage);
  plugin.on("join").listen(handleJoin);
  plugin.on("part").listen(handlePart);
}

void handleJoin(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  String user = data['user'];
  String network = data['network'];
  
  plugin.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.sendMessage(net, data['channel'], "[${network}] ${user} joined");
    });
  });
}

void handlePart(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  String user = data['user'];
  String network = data['network'];
  
  plugin.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.sendMessage(net, data['channel'], "[${network}] ${user} left");
    });
  });
}

void handleMessage(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  var message = "[${data['network']}] <-${data['from']}> ${data['message']}";

  plugin.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.sendMessage(net, data['target'], message);
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