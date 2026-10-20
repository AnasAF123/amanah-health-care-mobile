import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Modal bottom sheet for choosing official Kemendagri regions (Provinsi, Kota, Kecamatan, Desa).
class AmanahRegionPickerSheet extends StatefulWidget {
  const AmanahRegionPickerSheet({
    required this.title,
    required this.loader,
    this.selectedId,
    super.key,
  });

  final String title;
  final Future<List<RegionItem>> Function() loader;
  final String? selectedId;

  static Future<RegionItem?> show({
    required BuildContext context,
    required String title,
    required Future<List<RegionItem>> Function() loader,
    String? selectedId,
  }) {
    return showAmanahBottomSheet<RegionItem>(
      context: context,
      isDismissible: true,
      builder: (BuildContext ctx) => AmanahRegionPickerSheet(
        title: title,
        loader: loader,
        selectedId: selectedId,
      ),
    );
  }

  @override
  State<AmanahRegionPickerSheet> createState() => _AmanahRegionPickerSheetState();
}

class _AmanahRegionPickerSheetState extends State<AmanahRegionPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<RegionItem> _items = <RegionItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<RegionItem> data = await widget.loader();
      if (!mounted) return;
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<RegionItem> get _filteredItems {
    if (_query.trim().isEmpty) return _items;
    final String q = _query.trim().toLowerCase();
    return _items.where((RegionItem item) {
      return item.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color inputBg = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
        : AmanahColorTokens.neutral50;
    final Color inputBorder = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
        : AmanahColorTokens.neutral200;

    return AmanahBottomSheetScaffold(
      title: widget.title,
      maxHeightFactor: 0.85,
      disableInternalScroll: true,
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: <Widget>[
          // Search input field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (String val) => setState(() => _query = val),
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama wilayah...',
                hintStyle: TextStyle(
                  color: subtextColor.withValues(alpha: 0.70),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: subtextColor,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AmanahColorTokens.brand,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AmanahColorTokens.brand,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AmanahThemeTokens.textTertiary(context),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AmanahThemeTokens.textSecondary(context),
                ),
              ),
              const SizedBox(height: 14),
              AmanahButton.secondary(
                text: 'Coba Lagi',
                size: AmanahButtonSize.small,
                onPressed: _fetchItems,
              ),
            ],
          ),
        ),
      );
    }

    final List<RegionItem> list = _filteredItems;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada wilayah ditemukan.',
          style: TextStyle(
            fontSize: 13,
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
      );
    }

    final Color dividerColor = AmanahThemeTokens.outline(context);
    final Color selectedBg = AmanahColorTokens.brand.withValues(alpha: 0.08);

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: dividerColor),
      itemBuilder: (BuildContext ctx, int index) {
        final RegionItem item = list[index];
        final bool isSelected = widget.selectedId != null &&
            (item.id == widget.selectedId ||
                item.displayName.toLowerCase() == widget.selectedId!.toLowerCase());

        return Material(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(item),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AmanahColorTokens.brand
                            : AmanahThemeTokens.textPrimary(context),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AmanahColorTokens.brand,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
