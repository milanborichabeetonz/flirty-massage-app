import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/pickup_line_model.dart';

class PickupLineService {
  Future<List<PickupLineModel>> fetchPickUpLines() async {
    final url = dotenv.env['BASEURL'];
    final uri = Uri.parse('$url/list');
    final response = await http.get(uri);

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
