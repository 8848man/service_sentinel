import 'package:flutter/material.dart';

class DownloadButtonModel {
  const DownloadButtonModel({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.url,
    this.isComingSoon = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final String? url;
  final bool isComingSoon;
}
