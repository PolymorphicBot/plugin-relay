import 'package:polymorphic_bot/api.dart';

APIConnector bot;

void main(List<String> args, port) {
  print("[Relay] Loading");
  bot = new APIConnector(port);
  
  var enabled = true;
  
  bot.config.then((response) {
    var config = response["config"];
    if (config.containsKey("relay")) {
      var relay = config["relay"];
      enabled = relay.containsKey("enabled") && !relay["enabled"];
    }
  });
  
  /* Expose External API */
  bot.conn.listenRequest((request) {
    switch (request.command) {
      case "enabled":
        request.reply({"enabled": enabled});
        break;
    }
  });
  
  bot.conn.listen((data) {
    switch (data['event']) {
      case "command":
        handle_command(data);
        break;
      case "message":
        if (!enabled) {
          break;
        }
        handle_message(data);
        break;
    }
  });
}

void handle_command(data) {
  switch (data["command"]) {
  }
}

void handle_message(Map<String, dynamic> data) {
  var message = "[${data['network']}] <-${data['from']}> ${data['message']}";

  bot.get("networks").then((response) {
    var send_to = copy(response["networks"]);
    send_to.remove(data['network']);
    send_to.forEach((net) {
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