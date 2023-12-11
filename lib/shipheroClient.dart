import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getShipHeroAccessToken(String username, String password) async {
  final String url = 'https://public-api.shiphero.com/auth/token';
  final Map<String, String> headers = {'Content-type': 'application/json'};
  final Map<String, String> authData = {
    'username': username,
    'password': password
  };

  try {
    final http.Response response = await http.post(Uri.parse(url),
        body: jsonEncode(authData), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['access_token'];
    } else {
      print('Failed to obtain access token');
      return null;
    }
  } catch (e) {
    print('Error obtaining access token: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getShipHeroOrderById(
  String accessToken,
  String orderId,
) async {
  final String url = 'https://public-api.shiphero.com/graphql';

  final String query = """
    query(\$orderId: String!) {
      order(id: \$orderId) {
        request_id
        complexity
        data {
          id
          order_number
          shop_name
          order_date
          shipments {
            id
            address {
              name
              address1
              address2
              city
            }
            created_date
          }
          returns {
            id
            reason
            status
            shipping_method
            created_at
            total_items_expected
            total_items_received
            total_items_restocked
          }
          rma_labels {
            rma_id
            status
            delivered
          }
        }
      }
    }
  """;

  final Map<String, dynamic> variables = {
    "orderId": orderId,
  };

  final Map<String, String> headers = {
    'Authorization': "Bearer $accessToken",
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'query': query, 'variables': variables}),
      headers: headers,
    );

    if (response.statusCode == 200 &&
        response.headers['content-type'] == 'application/json') {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['order'] != null) {
        return data['data']['order']['data'];
      } else {
        print('No order found with ID: $orderId');
        return null;
      }
    } else {
      print('Failed to get order. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Failed to get ShipHero order. Error: $e');
    return null;
  }
}
