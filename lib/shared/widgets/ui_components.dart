import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

// MARK: - Buttons

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        minimumSize: const Size(0, 48),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppConstants.paddingSmall),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? colorScheme.primary,
        side: BorderSide(
          color: borderColor ?? colorScheme.primary,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        minimumSize: const Size(0, 48),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? colorScheme.primary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppConstants.paddingSmall),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor ?? colorScheme.primary,
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: AppConstants.errorColor,
      textColor: Colors.white,
    );
  }
}

// MARK: - Cards

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Card(
      color: backgroundColor ?? theme.cardTheme.color,
      elevation: elevation ?? theme.cardTheme.elevation,
      margin: margin ?? const EdgeInsets.all(AppConstants.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: card,
      );
    }

    return card;
  }
}

// MARK: - Progress Indicators

class AppProgressBar extends StatelessWidget {
  final double progress;
  final double? height;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? label;
  final bool showPercentage;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height,
    this.backgroundColor,
    this.progressColor,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: height ?? 8,
                  decoration: BoxDecoration(
                    color:
                        backgroundColor ?? colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
                AnimatedContainer(
                  duration: AppConstants.animationMedium,
                  height: height ?? 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: progressColor ?? colorScheme.primary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
              ],
            );
          },
        ),
        if (showPercentage) ...[
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// MARK: - Icons

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double? padding;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (backgroundColor != null) {
      return Container(
        padding: EdgeInsets.all(padding ?? AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          size: size,
          color: color ?? colorScheme.onSurface,
        ),
      );
    }

    return Icon(
      icon,
      size: size,
      color: color ?? colorScheme.onSurface,
    );
  }
}

// MARK: - Text Styles

class AppText {
  static TextStyle get headline => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      );

  static TextStyle get subheadline => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      );

  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFF64748B),
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF94A3B8),
      );

  static TextStyle get button => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}

// MARK: - Spacing

class AppSpacing {
  static const SizedBox xs = SizedBox(height: 4, width: 4);
  static const SizedBox sm = SizedBox(height: 8, width: 8);
  static const SizedBox md = SizedBox(height: 16, width: 16);
  static const SizedBox lg = SizedBox(height: 24, width: 24);
  static const SizedBox xl = SizedBox(height: 32, width: 32);
}

// MARK: - Utility Widgets

class AppDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const AppDivider({
    super.key,
    this.height = 1,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      margin: margin ??
          const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      color: color ?? theme.dividerColor,
    );
  }
}

class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor ?? colorScheme.onPrimaryContainer,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
