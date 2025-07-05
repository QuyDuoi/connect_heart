import 'package:connect_heart/data/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:connect_heart/data/models/certificate.dart';

final Dio dio = AuthService.dioInstance;

Future<List<Certificate>> fetchCertificates() async {
  try {
    final response = await dio.get(
      'http://98.84.150.185:8000/api/connect-heart/client/list-certificate',
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data['response']?['certificates'] != null) {
        return (data['response']['certificates'] as List)
            .map((e) => Certificate.fromJson(e))
            .toList();
      } else {
        throw Exception('Không tìm thấy dữ liệu chứng chỉ.');
      }
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  } catch (e) {
    print('Lỗi fetchCertificates: $e');
    throw Exception('Lỗi fetchCertificates: $e');
  }
}
