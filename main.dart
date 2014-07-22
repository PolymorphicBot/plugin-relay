import 'dart:isolate';
import 'package:plugins/plugin.dart';

Receiver recv;

void main(List<String> args, SendPort port) {
  print("[Relay] Loading");
  recv = new Receiver(port);

  recv.listen((data) {
    switch (data['event']) {
      case "command":
        handle_command(data);
        break;
      case "message":
        handle_message(data);
        break;
    }
  });
}

void handle_command(data) {
  void reply(String message) {
    recv.send({
      "network": data["network"],
      "target": data["target"],
      "command": "message",
      "message": message
    });
  }

  switch (data["command"]) {
  }
}

void handle_message(Map<String, dynamic> data) {
  var message = "[${data['network']}] <-${data['from']}> ${data['message']}";

  recv.get("networks", {}).then((response) {
    var send_to = copy(response["networks"]);
    send_to.remove(data['network']);
    send_to.forEach((net) {
      var msg = {
        "network": net,
        "target": data['target'],
        "message": message,
        "command": "message"
      };
      recv.send(msg);
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