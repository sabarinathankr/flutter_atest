import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? tabController;
  final List<Tab> tabs;

  const CustomAppBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Size get preferredSize => const Size.fromHeight(200); // enough buffer

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade700,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
      child: SafeArea(
        bottom: false, // 👈 important
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 critical fix
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context).translate('app_name'),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 🔹 SUBTITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context).translate('location'),
                  softWrap: true,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 14),

              // 🔹 TAB BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey,
                    tabs: tabs,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

