import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pickup_line_model.dart';

class PickupLineService {
  Future<List<PickupLineModel>> fetchPickUpLines() async {
    final url ='https://rizzapi.vercel.app';
    final uri = Uri.parse('$url/list');
    final response = await http.get(uri);

    //print('Status Code: ${response.statusCode}');
    //     print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic>  data = jsonDecode(response.body) as List;

      return data.map((json) => PickupLineModel.fromJson(json)).toList();
    }else{
     throw Exception(
        'Failed to load pickup lines'
      );
    }
  }
}

