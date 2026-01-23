import 'package:flutter/material.dart';

class DuplicateSelectionProvider extends ChangeNotifier {
  final Set<String> _selectedForDeletion = {};

  Set<String> get selectedForDeletion => _selectedForDeletion;

  bool isSelected(String id) => _selectedForDeletion.contains(id);

  void toggleSelection(String id) {
    if (_selectedForDeletion.contains(id)) {
      _selectedForDeletion.remove(id);
    } else {
      _selectedForDeletion.add(id);
    }
    notifyListeners();
  }

  void selectGroup(List<String> ids) {
    _selectedForDeletion.addAll(ids);
    notifyListeners();
  }

  void deselectGroup(List<String> ids) {
    _selectedForDeletion.removeAll(ids);
    notifyListeners();
  }

  void clearAll() {
    _selectedForDeletion.clear();
    notifyListeners();
  }
}
