import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fl_contacts;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String? email;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory Contact.fromFlutterContact(
    fl_contacts.Contact contact,
    int phoneIndex,
  ) {
    final phone =
        contact.phones.isNotEmpty && phoneIndex < contact.phones.length
        ? contact.phones[phoneIndex].number
        : '';
    final email = contact.emails.isNotEmpty
        ? contact.emails.first.address
        : null;

    return Contact(
      id: '${contact.id}_$phoneIndex',
      name: contact.displayName,
      phone: phone,
      email: email,
    );
  }
}

// Model class for Duplicate Group
class DuplicateGroup {
  final String key;
  final List<Contact> contacts;
  final Set<String> selectedIds;

  DuplicateGroup({
    required this.key,
    required this.contacts,
    Set<String>? selectedIds,
  }) : selectedIds = selectedIds ?? {};

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get allSelected => selectedIds.length == contacts.length;
}

// Provider class
class DuplicateContactsProvider extends ChangeNotifier {
  List<DuplicateGroup> _duplicateGroups = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 🔹 New variable for total size (in KB)
  double _totalSizeKB = 0.0;

  List<DuplicateGroup> get duplicateGroups => _duplicateGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter for formatted size
  String get formattedSize {
    if (_totalSizeKB >= 1024) {
      return "${(_totalSizeKB / 1024).toStringAsFixed(2)} MB";
    } else {
      return "${_totalSizeKB.toStringAsFixed(2)} KB";
    }
  }

  int get totalSelected {
    return _duplicateGroups.fold(
      0,
      (sum, group) => sum + group.selectedIds.length,
    );
  }

  bool get hasAnySelection => totalSelected > 0;

  // Normalize phone number for comparison
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Normalize name for comparison
  String _normalizeName(String name) {
    return name.toLowerCase().trim();
  }

  // Check and request contacts permission
  Future<bool> _requestContactsPermission() async {
    final status = await Permission.contacts.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.contacts.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  // 🔹 Helper method to calculate approximate size
  double _estimateContactSize(List<Contact> contacts) {
    // Rough estimate: 200 bytes for name + phone + email
    // Convert to KB (1 KB = 1024 bytes)
    double totalBytes = 0;
    for (var c in contacts) {
      totalBytes +=
          (c.name.length + c.phone.length + (c.email?.length ?? 0)) * 100;
    }
    return totalBytes / 1024;
  }

  // 🔹 Update total size
  void _updateTotalSize() {
    final allContacts = _duplicateGroups.expand((g) => g.contacts).toList();
    _totalSizeKB = _estimateContactSize(allContacts);
    notifyListeners();
  }

  bool _hasPermission = false;
  bool get permissionStatus => _hasPermission;
  // Find duplicate contacts from device
  Future<void> findDuplicates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hasPermission = await _requestContactsPermission();

      if (!_hasPermission) {
        _errorMessage = 'Contacts permission is required to find duplicates';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final flutterContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      List<Contact> allContacts = [];
      for (var flutterContact in flutterContacts) {
        if (flutterContact.phones.isNotEmpty) {
          for (int i = 0; i < flutterContact.phones.length; i++) {
            allContacts.add(Contact.fromFlutterContact(flutterContact, i));
          }
        }
      }

      Map<String, List<Contact>> groupedByName = {};
      for (var contact in allContacts) {
        if (contact.name.isNotEmpty) {
          final normalizedName = _normalizeName(contact.name);
          groupedByName.putIfAbsent(normalizedName, () => []).add(contact);
        }
      }

      Map<String, List<Contact>> groupedByPhone = {};
      for (var contact in allContacts) {
        if (contact.phone.isNotEmpty) {
          final normalizedPhone = _normalizePhone(contact.phone);
          if (normalizedPhone.length >= 7) {
            groupedByPhone.putIfAbsent(normalizedPhone, () => []).add(contact);
          }
        }
      }

      Set<String> processedIds = {};
      List<DuplicateGroup> duplicates = [];

      groupedByPhone.forEach((phone, contacts) {
        if (contacts.length > 1) {
          final uniqueContacts = contacts
              .where((c) => !processedIds.contains(c.id))
              .toList();
          if (uniqueContacts.length > 1) {
            duplicates.add(
              DuplicateGroup(
                key: contacts.first.name.isNotEmpty
                    ? contacts.first.name
                    : 'Unknown ($phone)',
                contacts: uniqueContacts,
              ),
            );
            processedIds.addAll(uniqueContacts.map((c) => c.id));
          }
        }
      });

      groupedByName.forEach((name, contacts) {
        if (contacts.length > 1) {
          final uniqueContacts = contacts
              .where((c) => !processedIds.contains(c.id))
              .toList();
          if (uniqueContacts.length > 1) {
            duplicates.add(
              DuplicateGroup(
                key: contacts.first.name,
                contacts: uniqueContacts,
              ),
            );
            processedIds.addAll(uniqueContacts.map((c) => c.id));
          }
        }
      });

      _duplicateGroups = duplicates;

      // 🔹 Update total size after scan
      _updateTotalSize();
    } catch (e) {
      _errorMessage = 'Error finding duplicates: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleContact(String groupKey, String contactId) {
    final groupIndex = _duplicateGroups.indexWhere((g) => g.key == groupKey);
    if (groupIndex != -1) {
      final group = _duplicateGroups[groupIndex];
      if (group.selectedIds.contains(contactId)) {
        group.selectedIds.remove(contactId);
      } else {
        group.selectedIds.add(contactId);
      }
      notifyListeners();
    }
  }

  void selectAllInGroup(String groupKey) {
    final groupIndex = _duplicateGroups.indexWhere((g) => g.key == groupKey);
    if (groupIndex != -1) {
      final group = _duplicateGroups[groupIndex];
      group.selectedIds.clear();
      group.selectedIds.addAll(group.contacts.map((c) => c.id));
      notifyListeners();
    }
  }

  void deselectAllInGroup(String groupKey) {
    final groupIndex = _duplicateGroups.indexWhere((g) => g.key == groupKey);
    if (groupIndex != -1) {
      _duplicateGroups[groupIndex].selectedIds.clear();
      notifyListeners();
    }
  }

  void selectAllDuplicates() {
    for (var group in _duplicateGroups) {
      group.selectedIds.clear();
      group.selectedIds.addAll(group.contacts.map((c) => c.id));
    }
    notifyListeners();
  }

  void deselectAll() {
    for (var group in _duplicateGroups) {
      group.selectedIds.clear();
    }
    notifyListeners();
  }

  // 🔹 Delete selected contacts & update size
  Future<void> deleteSelected() async {
    if (!hasAnySelection) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<String> idsToDelete = [];
      for (var group in _duplicateGroups) {
        idsToDelete.addAll(group.selectedIds);
      }

      for (String id in idsToDelete) {
        try {
          final originalId = id.split('_').first;
          final contact = await FlutterContacts.getContact(originalId);
          if (contact != null) {
            await FlutterContacts.deleteContact(contact);
          }
        } catch (e) {
          print('Error deleting contact $id: $e');
        }
      }

      for (var group in _duplicateGroups) {
        group.contacts.removeWhere((c) => group.selectedIds.contains(c.id));
        group.selectedIds.clear();
      }

      _duplicateGroups.removeWhere((group) => group.contacts.length < 2);

      // 🔹 Update total size after deletion
      _updateTotalSize();
    } catch (e) {
      _errorMessage = 'Error deleting contacts: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
