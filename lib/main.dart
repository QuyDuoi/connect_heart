import 'package:connect_heart/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/router_provider.dart';
import 'providers/token_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nếu bạn có khởi tạo async nào (ví dụ load token từ SharedPreferences) thì xử lý ở đây
  await AuthService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}
