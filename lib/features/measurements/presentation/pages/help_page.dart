import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
import 'package:mta/core/utils/constants.dart';

class HelpPage extends StatefulWidget {
  final bool isFirstTime;
  const HelpPage({super.key, this.isFirstTime = false});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpTitle),
        automaticallyImplyLeading: !widget.isFirstTime,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _HelpSlide(
                  title: l10n.helpSectionTomaTitle,
                  icon: Icons.accessibility_new,
                  content: l10n.helpSectionTomaContent,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _HelpSlide(
                  title: l10n.helpSectionColorsTitle,
                  icon: Icons.palette,
                  content: l10n.helpSectionColorsContent,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _HelpSlide(
                  title: l10n.helpSectionSchedulesTitle,
                  icon: Icons.notifications_active,
                  content: l10n.helpSectionSchedulesContent,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _HelpSlide(
                  title: l10n.helpSectionDataTitle,
                  icon: Icons.backup,
                  content: l10n.helpSectionDataContent,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9575CD), Color(0xFF5E35B1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
          ),
          _buildPageIndicator(),
          _buildActionButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_numPages, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AppLocalizations l10n) {
    if (!widget.isFirstTime) {
      return const SizedBox(height: AppSpacing.md);
    }

    if (_currentPage != _numPages - 1) {
      return const SizedBox(height: 80); // Espacio reservado
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(Routes.userForm),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
            child: Text(
              l10n.resume,
              style: AppTypography.h2.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpSlide extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final Gradient gradient;

  const _HelpSlide({
    required this.title,
    required this.icon,
    required this.content,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 80),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Text(
              content,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
