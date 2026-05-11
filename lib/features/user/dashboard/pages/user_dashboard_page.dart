import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/pages/tabs/browse_tab.dart';
import 'package:study_hub/features/user/dashboard/pages/tabs/my_resources_tab.dart';
import 'package:study_hub/features/user/dashboard/pages/tabs/upload_tab.dart';
import 'package:study_hub/features/user/dashboard/pages/tabs/profile_tab.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/navbar.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';
import 'package:study_hub/features/user/dashboard/pages/tabs/global_resources_tab.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final DashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc()..add(DashboardStarted());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Scaffold(
              backgroundColor: AppColors.darkBg,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final t = UserTheme(state.isDarkMode);

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: t.bg,
              drawer: MobileDrawer(
                t: t,
                currentIndex: _currentIndex,
                onNavTap: (i) {
                  setState(() => _currentIndex = i);
                  _scaffoldKey.currentState?.closeDrawer();
                },
              ),
              body: Column(
                children: [
                  DashboardNavbar(
                    t: t,
                    currentIndex: _currentIndex,
                    onNavTap: (i) => setState(() => _currentIndex = i),
                    onLogoTap: () => setState(() => _currentIndex = 0),
                    scaffoldKey: _scaffoldKey,
                  ),
                  Expanded(
                    child: AnimatedPageSwitcher(
                      index: _currentIndex,
                      pages: [
                        BrowseTab(state: state, t: t),
                        GlobalResourcesTab(state: state, t: t),
                        MyResourcesTab(state: state, t: t),
                        UploadTab(state: state, t: t),
                        ProfileTab(state: state, t: t),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(DashboardStarted()),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
