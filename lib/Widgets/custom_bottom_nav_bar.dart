import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Constants/assets.dart';
import '../Constants/constants.dart';
import '../Navigation/Navigate.dart';
import '../Repository/repository.dart';
import '../Router/routes.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  /// Static helper method for main screens to ensure their navigation index is set correctly
  static void ensureCorrectIndex(BuildContext context, String routeName) {
    final repository = Provider.of<Repository>(context, listen: false);
    final expectedIndex = _staticGetIndexForRoute(routeName);

    if (expectedIndex != -1 && repository.currentIndex != expectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        repository.updateIndex(expectedIndex);
      });
    }
  }

  static int _staticGetIndexForRoute(String routeName) {
    switch (routeName) {
      case Routes.homeScreen:
        return 0;
      case Routes.searchScreen:
        return 1;
      case Routes.premiumScreen:
        return 2;
      case Routes.rentScreen:
        return 3;
      case Routes.accountScreen:
        return 4;
      default:
        return -1; // Not a main navigation route
    }
  }

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _currentRoute;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Get initial route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexBasedOnCurrentRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexBasedOnCurrentRoute();
  }

  void _updateIndexBasedOnCurrentRoute() {
    final modalRoute = ModalRoute.of(context);
    if (modalRoute?.settings.name != null) {
      final currentRoute = modalRoute!.settings.name!;
      if (_currentRoute != currentRoute) {
        _currentRoute = currentRoute;
        final expectedIndex = _getIndexForRoute(currentRoute);

        if (expectedIndex != -1) {
          final repository = Provider.of<Repository>(context, listen: false);
          if (repository.currentIndex != expectedIndex) {
            repository.updateIndex(expectedIndex);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(
      builder: (context, repository, child) {
        // Ensure current route index is synced every build
        _updateIndexBasedOnCurrentRoute();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.95),
                const Color(0xFF0D0D0D),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: "Home",
                    isSelected: repository.currentIndex == 0,
                    onTap: () => _onNavTap(0, repository),
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.search_rounded,
                    label: "Search",
                    isSelected: repository.currentIndex == 1,
                    onTap: () => _onNavTap(1, repository),
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.trending_up_rounded,
                    label: "Trending",
                    isSelected: repository.currentIndex == 2,
                    onTap: () => _onNavTap(2, repository),
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.movie_filter_rounded,
                    label: "Rent",
                    isSelected: repository.currentIndex == 3,
                    onTap: () => _onNavTap(3, repository),
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.person_rounded,
                    label: "Account",
                    isSelected: repository.currentIndex == 4,
                    onTap: () => _onNavTap(4, repository),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with background
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Constants.thirdColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Constants.thirdColor.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          icon,
                          key: ValueKey('$index-$isSelected'),
                          size: isSelected ? 24 : 22,
                          color: isSelected
                              ? Constants.thirdColor
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 1),

                    // Label
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: isSelected
                            ? Constants.thirdColor
                            : Colors.white.withOpacity(0.6),
                        fontSize: isSelected ? 10 : 9,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Active indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      margin: const EdgeInsets.only(top: 1),
                      height: 2,
                      width: isSelected ? 16 : 0,
                      decoration: BoxDecoration(
                        color: Constants.thirdColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onNavTap(int index, Repository repository) {
    // Only navigate if not already on the selected tab
    if (repository.currentIndex != index) {
      // Update index immediately for better UX
      repository.updateIndex(index);

      // Navigate to appropriate route
      switch (index) {
        case 0:
          Navigation.instance.navigate(Routes.homeScreen);
          break;
        case 1:
          Navigation.instance.navigate(Routes.searchScreen, args: "");
          break;
        case 2:
          Navigation.instance.navigate(Routes.premiumScreen);
          break;
        case 3:
          Navigation.instance.navigate(Routes.rentScreen);
          break;
        case 4:
          Navigation.instance.navigate(Routes.accountScreen);
          break;
      }
    }
  }

  int _getIndexForRoute(String routeName) {
    switch (routeName) {
      case Routes.homeScreen:
        return 0;
      case Routes.searchScreen:
        return 1;
      case Routes.premiumScreen:
        return 2;
      case Routes.rentScreen:
        return 3;
      case Routes.accountScreen:
        return 4;
      default:
        return -1; // Not a main navigation route
    }
  }
}
