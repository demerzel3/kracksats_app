import 'dart:convert';

import 'package:http/http.dart' as http;

class Order {}

Future<Order> newOrder(String otp) async {
  final response = await http.post('https://kracksats-api.demerzel3.dev/orders',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'otp': otp}));

  if (response.statusCode == 200) {
    return new Order();
  } else {
    Map<String, dynamic> errorContent;
    try {
      errorContent = jsonDecode(response.body);
    } catch (e) {
      errorContent = {'message': 'Could not create order'};
    }

    throw errorContent['message'];
  }
}
