import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Rekognition {
  Future<bool> test(File nova, String login) async {
    Map<String, String> data = {
      'login': login,
      'nova': base64.encode(nova.readAsBytesSync()),
    };
    String url = 'https://trabalhoia.herokuapp.com/detect';
    try {
      print('Fazendo requisicao');
      var response = await http.post(url,
          body: json.encode(data),
          headers: {"Content-Type": 'application/json'});
      return json.decode(response.body)['result'].toString().toLowerCase() ==
          'true';
    } catch (e) {
      print(e);
      return false;
    }
  }
}
