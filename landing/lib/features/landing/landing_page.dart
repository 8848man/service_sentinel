import 'package:flutter/material.dart';
import '../../design/components/ss_navbar.dart';
import 'sections/hero_section.dart';
import 'sections/target_section.dart';
import 'sections/features_section.dart';
import 'sections/preview_section.dart';
import 'sections/handy_section.dart';
import 'sections/download_section.dart';
import 'sections/cta_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _downloadKey = GlobalKey();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 20;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  void _scrollToDownload() {
    final ctx = _downloadKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                HeroSection(onStartFree: _scrollToDownload),
                const TargetSection(),
                const FeaturesSection(),
                const PreviewSection(),
                // const HandySection(),
                DownloadSection(key: _downloadKey),
                const CTASection(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SSNavBar(
              isScrolled: _isScrolled,
              onStartFree: _scrollToDownload,
            ),
          ),
        ],
      ),
    );
  }
}
