import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_dialogs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// category_widgets.dart
//
// Widgets:
//   CategoriesGrid     — responsive wrap of all category cards + add button
//   CategoryCard       — single category tile with select/deselect
//   AddCategoryCard    — dashed "+" card that opens the add modal
// ─────────────────────────────────────────────────────────────────────────────

class CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final UserTheme t;
  const CategoriesGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 900
            ? 4
            : w > 600
            ? 3
            : 2;
        final cardW = (w - (10 * (cols - 1))) / cols;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...categories.map(
              (cat) => CategoryCard(
                category: cat,
                width: cardW,
                isSelected: selectedCategoryId == cat.id,
                t: t,
                onTap: () =>
                    context.read<DashboardBloc>().add(CategorySelected(cat.id)),
              ),
            ),
            AddCategoryCard(width: cardW, t: t),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final double width;
  final bool isSelected;
  final UserTheme t;
  final VoidCallback onTap;
  const CategoryCard({
    super.key,
    required this.category,
    required this.width,
    required this.isSelected,
    required this.t,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? (widget.t.isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFEEEEEE))
                : _hover
                ? (widget.t.isDark
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFEBEBEB))
                : widget.t.surface,
            border: Border.all(
              color: selected
                  ? (widget.t.isDark ? Colors.white54 : Colors.black38)
                  : _hover
                  ? widget.t.border2
                  : widget.t.border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.t.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.category.description,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.t.textSub,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.category.resourceCount} resources',
                style: TextStyle(fontSize: 11, color: widget.t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AddCategoryCard extends StatefulWidget {
  final double width;
  final UserTheme t;
  const AddCategoryCard({super.key, required this.width, required this.t});

  @override
  State<AddCategoryCard> createState() => _AddCategoryCardState();
}

class _AddCategoryCardState extends State<AddCategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => showAddCategoryModal(context, widget.t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: _hover ? widget.t.hover : Colors.transparent,
            border: Border.all(
              color: _hover ? widget.t.border2 : widget.t.border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 24, color: widget.t.textMuted),
              const SizedBox(height: 6),
              Text(
                'Add Category',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.t.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
