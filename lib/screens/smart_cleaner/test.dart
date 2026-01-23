import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/provider.dart';
import 'package:provider/provider.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool showPhotos = false;
  bool showVideos = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageProvider>();
    final usedPercent = provider.total > 0
        ? (provider.used / provider.total)
        : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text("Storage Overview")),
      backgroundColor: Colors.white,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 12.0,
                    percent: usedPercent.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.used.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${provider.used.toStringAsFixed(1)} GB / ${provider.total.toStringAsFixed(1)} GB",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    linearGradient: const LinearGradient(
                      colors: [Color(0xFF586AFC), Color(0xFF31DAB2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    backgroundColor: const Color(0xFFEDEDED),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 30),
                  _buildSection(
                    title: "Photos",
                    showSection: showPhotos,
                    isCalculating: provider.isCalculatingSizes,
                    totalBytes: provider.totalPhotoBytes(),
                    onTap: () async {
                      setState(() => showPhotos = !showPhotos);

                      if (showPhotos) {
                        // 🔹 Lazy compute photo sizes on expand
                        final p = context.read<StorageProvider>();
                        if (p.photos.isNotEmpty &&
                            p.photos.first.sizeInBytes == 0 &&
                            !p.isCalculatingSizes) {
                          await p.computePhotoSizes(batchSize: 15);
                        }
                      }
                    },
                    children: provider.photos,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: "Videos",
                    showSection: showVideos,
                    isCalculating: provider.isCalculatingSizes,
                    totalBytes: provider.totalVideoBytes(),
                    onTap: () async {
                      setState(() => showVideos = !showVideos);

                      if (showVideos) {
                        // 🔹 Lazy compute video sizes on expand
                        final p = context.read<StorageProvider>();
                        if (p.videos.isNotEmpty &&
                            p.videos.first.sizeInBytes == 0 &&
                            !p.isCalculatingSizes) {
                          await p.computeVideoSizes(batchSize: 10);
                        }
                      }
                    },
                    children: provider.videos,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageInfo(StorageProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text("Storage Info", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text("Total: ${provider.total.toStringAsFixed(1)} GB"),
          Text("Used: ${provider.used.toStringAsFixed(1)} GB"),
          Text("Free: ${provider.free.toStringAsFixed(1)} GB"),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool showSection,
    required bool isCalculating,
    required int totalBytes,
    required List children,
    required VoidCallback onTap,
  }) {
    final provider = context.read<StorageProvider>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (isCalculating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (totalBytes > 0)
              Text(
                provider.formatBytes(totalBytes),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        initiallyExpanded: showSection,
        onExpansionChanged: (_) => onTap(),
        children: [
          if (showSection)
            SizedBox(
              height: 120,
              child: children.isEmpty
                  ? const Center(child: Text("No items found"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final item = children[index];
                        return FutureBuilder(
                          future: item.getThumbnail(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      snapshot.data! as Uint8List,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  if (item.sizeInBytes > 0)
                                    Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        provider.formatBytes(item.sizeInBytes),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
