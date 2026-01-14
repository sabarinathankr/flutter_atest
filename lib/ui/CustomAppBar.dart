import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? tabController;
  final List<Tab> tabs;

  const CustomAppBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TOP ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 👈 important
              children: [
                // ✅ Multi-line, wrap-content text
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
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
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // 🔹 SUBTITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context).translate('location'),
              softWrap: true,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 TAB BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
        ],
      ),
    );
  }

}
