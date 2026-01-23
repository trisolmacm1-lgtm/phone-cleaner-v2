// Main Screen
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/duplicate_contacts_screen/provider.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../core/widgets/delete_dialog.dart';
import '../../l10n/generated/app_localizations.dart';
import 'contact_tile.dart';

class DuplicateContactsScreen extends StatefulWidget {
  const DuplicateContactsScreen({super.key});

  @override
  _DuplicateContactsScreenState createState() =>
      _DuplicateContactsScreenState();
}

class _DuplicateContactsScreenState extends State<DuplicateContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DuplicateContactsProvider>().findDuplicates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.contacts,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.bgColor,
        foregroundColor: AppColors.bgColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset("assets/svg/ic_back.svg", color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Consumer<DuplicateContactsProvider>(
          //   builder: (context, provider, child) {
          //     if (provider.duplicateGroups.isEmpty) return SizedBox.shrink();

          //     return PopupMenuButton<String>(
          //       color: Colors.black,
          //       icon: Icon(Icons.more_vert, color: Colors.white),
          //       onSelected: (value) {
          //         if (value == 'select_all') {
          //           provider.selectAllDuplicates();
          //         } else if (value == 'deselect_all') {
          //           provider.deselectAll();
          //         }
          //       },
          //       itemBuilder: (context) => [
          //         PopupMenuItem(
          //           value: 'select_all',
          //           child: Text(
          //             localizations.selectAll,
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         ),
          //         PopupMenuItem(
          //           value: 'deselect_all',
          //           child: Text(
          //             localizations.deselectAll,
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ],
      ),

      body: Consumer<DuplicateContactsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.duplicateGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(localizations.scanningDuplicates),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.findDuplicates(),
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.duplicateGroups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    localizations.noDuplicateContacts,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => provider.findDuplicates(),
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      localizations.tryAgain,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // if (provider.hasAnySelection)
              // Container(
              //   padding: EdgeInsets.all(12),
              //   color: AppColors.bgSecondry,
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.info_outline,
              //         color: Theme.of(context).primaryColor,
              //       ),
              //       SizedBox(width: 8),
              //       Text(
              //         '${provider.totalSelected} contact(s) selected',
              //         style: TextStyle(
              //           fontWeight: FontWeight.w500,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: provider.duplicateGroups.length,
                  itemBuilder: (context, index) {
                    final group = provider.duplicateGroups[index];
                    return DuplicateGroupCard(group: group);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<DuplicateContactsProvider>(
        builder: (context, provider, child) {
          if (!provider.hasAnySelection) return SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GradientButton(
              text:
                  '${AppLocalizations.of(context)!.delete} (${provider.totalSelected})',
              onPressed: () =>
                  _showDeleteConfirmation(context, provider, localizations),
            ),
          );

          // FloatingActionButton.extended(
          //   onPressed: () =>
          //       _showDeleteConfirmation(context, provider, localizations),
          //   backgroundColor: AppColors.secondoryColor,
          //   icon: Icon(Icons.delete, color: Colors.white),
          //   label: Text(
          //     'Delete (${provider.totalSelected})',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DuplicateContactsProvider provider,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomActionDialog(
          buttonText: localizations.delete,
          iconPath: 'assets/svg/ic_delete.svg',
          title: localizations.deleteContacts,
          subtitle: localizations.deleteConfirmContacts(provider.totalSelected),
          onPressed: () {
            Navigator.pop(context);
            provider.deleteSelected();
          },
        );
      },
    );
  }
}
