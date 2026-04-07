import 'package:crm_app/Model/state_model.dart';
import 'package:dio/dio.dart';

class StateService {
  final Dio _dio;

  StateService(this._dio);

  Future<List<StateModel>> fetchStates() async {
    try {
      print("Fetching states...{$_dio}");
      final response = await _dio.get('/get_states');

      final result = StatesResponse.fromJson(response.data);

      if (result.status) {
        return result.data;
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      throw Exception("Failed to fetch states: $e");
    }
  }
}
