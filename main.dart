import 'package:polymorphic_bot/api.dart';

BotConnector bot;
bool enabled;

void main(List<String> args, Plugin plugin) {
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
  
  var requests = new RequestAdapter();
  
  requests.register("enabled", (request) {
    request.reply({
      "enabled": enabled
    });
  });
  
  bot.handleRequest(requests.handle);
  
  bot.on("message").listen(handleMessage);
  bot.on("join").listen(handleJoin);
  bot.on("part").listen(handlePart);
}

void handleJoin(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  String user = data['user'];
  String network = data['network'];
  
  bot.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.message(net, data['channel'], "[${network}] ${user} joined");
    });
  });
}

void handlePart(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  String user = data['user'];
  String network = data['network'];
  
  bot.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.message(net, data['channel'], "[${network}] ${user} left");
    });
  });
}

void handleMessage(Map<String, dynamic> data) {
  if (!enabled) {
    return;
  }
  
  var message = "[${data['network']}] <-${data['from']}> ${data['message']}";

  bot.get("networks").then((response) {
    var sendTo = copy(response["networks"]);
    sendTo.remove(data['network']);
    sendTo.forEach((net) {
      bot.message(net, data['target'], message);
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