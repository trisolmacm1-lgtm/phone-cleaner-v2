// Duplicate Group Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_cleaner_2/screens/duplicate_contacts_screen/provider.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../l10n/generated/app_localizations.dart';

class DuplicateGroupCard extends StatelessWidget {
  final DuplicateGroup group;

  const DuplicateGroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DuplicateContactsProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondry,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (group.allSelected) {
                      provider.deselectAllInGroup(group.key);
                    } else {
                      provider.selectAllInGroup(group.key);
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        group.allSelected
                            ? AppLocalizations.of(context)!.deselectAll
                            : AppLocalizations.of(context)!.selectAll,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),

                      SvgPicture.asset(
                        group.allSelected
                            ? "assets/svg/check_circle.svg"
                            : "assets/svg/circle.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      // SvgPicture.asset('')
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contact List
          ...group.contacts.map((contact) {
            final isSelected = group.selectedIds.contains(contact.id);
            final initials = contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '?';

            return InkWell(
              onTap: () => provider.toggleContact(group.key, contact.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Contact info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            contact.phone,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: SvgPicture.asset(
                        isSelected
                            ? "assets/svg/check_circle.svg"
                            : "assets/svg/circle.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
