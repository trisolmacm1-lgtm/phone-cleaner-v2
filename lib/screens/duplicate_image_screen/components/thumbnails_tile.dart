import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../provider/duplicate_selection_provider.dart';

class DuplicateThumbnailTile extends StatefulWidget {
  final AssetEntity asset;
  const DuplicateThumbnailTile({super.key, required this.asset});

  @override
  State<DuplicateThumbnailTile> createState() => _DuplicateThumbnailTileState();
}

class _DuplicateThumbnailTileState extends State<DuplicateThumbnailTile> {
  Uint8List? _thumbData;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  Future<void> _loadThumb() async {
    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
    );
    if (mounted) {
      setState(() => _thumbData = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DuplicateSelectionProvider, bool>(
      selector: (_, provider) => provider.isSelected(widget.asset.id),
      builder: (context, isSelected, _) {
        return GestureDetector(
          onTap: () => context
              .read<DuplicateSelectionProvider>()
              .toggleSelection(widget.asset.id),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        )
                      : null,
                  image: _thumbData != null
                      ? DecorationImage(
                          image: MemoryImage(_thumbData!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _thumbData == null
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
