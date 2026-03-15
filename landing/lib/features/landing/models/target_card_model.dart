import 'package:flutter/material.dart';

class TargetCardModel {
  const TargetCardModel({
    required this.role,
    required this.pain,
    required this.solution,
    required this.icon,
  });

  final String role;
  final String pain;
  final String solution;
  final IconData icon;
}
