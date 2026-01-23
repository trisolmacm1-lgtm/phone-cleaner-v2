import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>> items;
  final Function(int) onTap;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xff1B1A1A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool isSelected = currentIndex == index;

            return Expanded(
              // 👈 Makes each tab occupy equal width
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(index),
                // splashColor: const Color(0xFF3273FD).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        child: SvgPicture.asset(
                          isSelected ? item['selectedIcon'] : item['icon'],
                          width: 26,
                          height: 26,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              // Color(0xffDFB44F)
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                          fontFamily: 'Montserrat',
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        child: Text(item['label']),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
