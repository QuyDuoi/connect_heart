import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/models/certificate.dart';
import 'package:connect_heart/data/services/certificate_service.dart';
import 'package:connect_heart/presentation/screens/certificate/shimmer_certificate_loader.dart';
import 'package:connect_heart/presentation/widgets/user_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/providers/user_provider.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({super.key});

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  late Future<List<Certificate>> _futureCertificates;

  @override
  void initState() {
    super.initState();
    _futureCertificates = fetchCertificates();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 8),

              // ✅ Tiêu đề cố định
              const Center(
                child: Text(
                  'Danh sách chứng chỉ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ✅ Nội dung async
              FutureBuilder<List<Certificate>>(
                future: _futureCertificates,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerCertificateLoader();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'Chưa có chứng chỉ nào',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  } else {
                    final certs = snapshot.data!;
                    return Column(
                      children: certs
                          .map((cert) => _buildCertificateItem(cert))
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const UserGreeting(),
        const Spacer(),
      ],
    );
  }

  Widget _buildCertificateItem(Certificate cert) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sự kiện: ${cert.eventTitle}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
              'Ngày đăng ký: ${cert.registeredAt.toLocal().toString().split(' ')[0]}'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cert.certificateLink.isNotEmpty
                ? Image.network(
                    cert.certificateLink,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/certificate.png',
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/certificate.png',
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
          ),
        ],
      ),
    );
  }
}
