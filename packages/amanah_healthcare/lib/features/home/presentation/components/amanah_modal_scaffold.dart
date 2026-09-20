import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

Future<T?> showAmanahBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: AmanahThemeTokens.scrim(context),
    builder: builder,
  );
}

class AmanahBottomSheetScaffold extends StatelessWidget {
  const AmanahBottomSheetScaffold({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.trailing,
    this.footer,
    this.maxHeightFactor = 0.88,
    this.minHeight,
    this.fixedHeightFactor,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.headerPadding = const EdgeInsets.fromLTRB(24, 8, 16, 12),
    this.showHeaderDivider = true,
    this.extendBodyBehindHeader = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget body;
  final Widget? footer;
  final double maxHeightFactor;
  final double? minHeight;
  final double? fixedHeightFactor;
  final EdgeInsetsGeometry bodyPadding;
  final EdgeInsetsGeometry headerPadding;
  final bool showHeaderDivider;
  final bool extendBodyBehindHeader;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final Color sheetBackgroundColor = dark
        ? AmanahThemeTokens.canvas(context)
        : AmanahThemeTokens.elevatedSurface(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isKeyboardOpen = keyboardInset > 0;
        // Determine whether an ancestor (e.g. Flutter's route or outer padding)
        // has already accounted for keyboardInset.
        final bool alreadyPadded = isKeyboardOpen &&
            (constraints.maxHeight < screenSize.height - (keyboardInset * 0.75));

        final double effectiveKeyboardInset =
            alreadyPadded ? 0.0 : keyboardInset;
        final double usableHeight = (constraints.maxHeight - effectiveKeyboardInset)
            .clamp(0.0, constraints.maxHeight);

        final double calculatedMaxHeight = usableHeight * maxHeightFactor;
        final double? calculatedFixedHeight = fixedHeightFactor == null
            ? null
            : usableHeight * fixedHeightFactor!.clamp(0.0, 1.0);

        final double effectiveMinHeight =
            (minHeight ?? 0.0).clamp(0.0, usableHeight);
        final double targetHeight = (calculatedFixedHeight ?? calculatedMaxHeight)
            .clamp(effectiveMinHeight, usableHeight);

        // When vertical space is severely restricted (e.g. landscape with keyboard),
        // embed footer inside the scrollable view so Column never overflows.
        final bool isTight = usableHeight < 260;

        final Widget sheetContent = ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AmanahRadius.sheet),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const _AmanahSheetHandle(),
              _AmanahSheetHeader(
                title: title,
                subtitle: subtitle,
                trailing: trailing,
                padding: headerPadding,
                showDivider: showHeaderDivider,
              ),
              if (isTight)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: bodyPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        body,
                        if (footer != null) ...<Widget>[
                          const SizedBox(height: AmanahSpacing.md),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                )
              else ...<Widget>[
                Expanded(
                  child: extendBodyBehindHeader
                      ? body
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: bodyPadding,
                          child: body,
                        ),
                ),
                if (footer != null)
                  _AmanahSheetFooter(
                    bottomInset: isKeyboardOpen ? 0 : bottomInset,
                    isKeyboardOpen: isKeyboardOpen,
                    child: footer!,
                  ),
              ],
            ],
          ),
        );

        final Widget sheet = Container(
          height: targetHeight,
          constraints: BoxConstraints(
            maxHeight: usableHeight,
            minHeight: effectiveMinHeight,
          ),
          decoration: BoxDecoration(
            color: sheetBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AmanahRadius.sheet),
            ),
            border: Border(
              top: BorderSide(color: AmanahThemeTokens.outline(context)),
            ),
            boxShadow: <BoxShadow>[AmanahElevation.sheet(dark: dark)],
          ),
          child: sheetContent,
        );

        if (effectiveKeyboardInset > 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: effectiveKeyboardInset),
            child: Align(alignment: Alignment.bottomCenter, child: sheet),
          );
        }

        return Align(alignment: Alignment.bottomCenter, child: sheet);
      },
    );
  }
}

class _AmanahSheetHandle extends StatelessWidget {
  const _AmanahSheetHandle();

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);

    return SizedBox(
      height: 28,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.25)
                : AmanahColorTokens.neutral300,
            borderRadius: BorderRadius.circular(AmanahRadius.pill),
          ),
          child: const SizedBox(width: 44, height: 5),
        ),
      ),
    );
  }
}

class _AmanahSheetHeader extends StatelessWidget {
  const _AmanahSheetHeader({
    required this.title,
    required this.padding,
    required this.showDivider,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(color: AmanahThemeTokens.outline(context)),
              )
            : null,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AmanahThemeTokens.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AmanahSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AmanahThemeTokens.textSecondary(context),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AmanahSpacing.md),
              SizedBox.square(
                dimension: AmanahComponentSize.iconButton,
                child: Center(child: trailing),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmanahSheetFooter extends StatelessWidget {
  const _AmanahSheetFooter({
    required this.child,
    required this.bottomInset,
    this.isKeyboardOpen = false,
  });

  final Widget child;
  final double bottomInset;
  final bool isKeyboardOpen;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color footerBackgroundColor = dark
        ? AmanahThemeTokens.canvas(context)
        : AmanahThemeTokens.elevatedSurface(context).withValues(alpha: 0.96);

    final double bottomPadding = isKeyboardOpen
        ? 10.0
        : (bottomInset > 0 ? bottomInset + 12 : 24.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: footerBackgroundColor,
            border: Border(
              top: BorderSide(color: AmanahThemeTokens.outline(context)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 10, 24, bottomPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

Future<bool> showAmanahConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Batal',
  bool destructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AmanahThemeTokens.elevatedSurface(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AmanahRadius.xl),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(dialogContext),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 12.5,
            color: AmanahThemeTokens.textSecondary(dialogContext),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          SizedBox(
            width: double.infinity,
            child: AmanahActionRow(
              secondary: AmanahButton.ghost(
                text: cancelLabel,
                isFullWidth: true,
                customForegroundColor: AmanahThemeTokens.textSecondary(
                  dialogContext,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              primary: destructive
                  ? AmanahButton.destructive(
                      text: confirmLabel,
                      isFullWidth: true,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    )
                  : AmanahButton.primary(
                      text: confirmLabel,
                      isFullWidth: true,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
