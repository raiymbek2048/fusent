import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'core/di/injection_container.dart' as di;

class FucentApp extends StatelessWidget {
  const FucentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<FeedBloc>()),
      ],
      child: MaterialApp.router(
        title: 'FUCENT',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // Router
        routerConfig: AppRouter.router,
      ),
    );
  }
}
