import 'package:flutter/material.dart';
import 'package:memo_clip/models/bottom_nav_bar_item.dart';

// ignore: must_be_immutable
class BottomNavigationSection extends StatefulWidget {
  BottomNavigationSection({
    super.key,
    this.onTap,
    required this.currentIndex,
    required this.children,
  });

  final List<BottomNavBarItem> children;
  final void Function(int)? onTap;
  int currentIndex;

  @override
  State<BottomNavigationSection> createState() =>
      _BottomNavigationSectionState();
}

class _BottomNavigationSectionState extends State<BottomNavigationSection> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      // margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,

        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.children.length,
          (index) => NavBarItem(
            item: widget.children[index],
            isSelected: widget.currentIndex == index,
            index: index,
            onTap: () {
              setState(() {
                widget.currentIndex = index;
                widget.onTap!(widget.currentIndex);
              });
            },
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final BottomNavBarItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final int index;

  const NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    this.onTap,
    required this.index,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        // width: widget.isSelected ? 100 : 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.item.icon,
              color: widget.isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withAlpha(180),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.title,
              style: TextStyle(
                fontSize: 12,
                color: widget.isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(180),
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
