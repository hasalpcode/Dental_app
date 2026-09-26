import 'package:dental_app/core/features/auth/data/auth_repository_impl.dart';
import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/auth/usecases/login_user.dart';
import 'package:dental_app/core/features/auth/usecases/signup_user.dart';
import 'package:dental_app/core/usecases/splash_screen.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/usecases/add_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/delete_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_cubit.dart';
import 'package:dental_app/core/features/payments/data/payment_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/usecases/add_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/delete_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/payments/domain/usecases/update_payment.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/payments_cubit.dart';
import 'package:dental_app/core/features/retrait/data/retrait_remote_data_source.dart';
import 'package:dental_app/core/features/retrait/data/retrait_repository_impl.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/add_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/delete_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/get_retraits.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/update_retrait.dart';
import 'package:dental_app/core/features/retrait/presentation/bloc/retrait_cubit.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'dart:io';

/// Ignore les certificats invalides — utile en dev contre un backend en
/// HTTPS auto-signé (ngrok, etc). Jamais active en release.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  final client = ApiClient.instance;

  final authRepository = AuthRepositoryImpl(AuthRemoteDataSource(client));

  final memberRepo = MemberRepositoryImpl(MemberRemoteDataSource(client));
  final getMembers = GetMembers(memberRepo);

  final paymentRepo = PaymentRepositoryImpl(PaymentRemoteDataSource(client));
  final retraitRepo = RetraitRepositoryImpl(RetraitRemoteDataSource(client));

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MembersCubit>(
          create: (_) => MembersCubit(
            getMembers,
            AddMember(memberRepo),
            UpdateMember(memberRepo),
            DeleteMember(memberRepo),
          ),
        ),
        BlocProvider<PaymentsCubit>(
          create: (_) => PaymentsCubit(
            GetPayments(paymentRepo),
            getMembers,
            AddPayment(paymentRepo),
            UpdatePayment(paymentRepo),
            DeletePayment(paymentRepo),
          ),
        ),
        BlocProvider<RetraitCubit>(
          create: (_) => RetraitCubit(
            GetRetraits(retraitRepo),
            getMembers,
            AddRetrait(retraitRepo),
            UpdateRetrait(retraitRepo),
            DeleteRetrait(retraitRepo),
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              authRepository,
              LoginUser(authRepository),
              SignupUser(authRepository),
            ),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Association Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const SplashScreen(),
    );
  }
}
