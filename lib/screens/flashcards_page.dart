import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'flashcards_category.dart';
import '../services/flashcard_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlashcardsPage extends StatefulWidget {
  final bool isVisible;

  const FlashcardsPage({super.key, this.isVisible = false});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late final FlashcardService flashcardService;
  List<int> counts = [
    0,
    0,
    0,
    0
  ]; // Initialize with default values to avoid index errors

  String _toTitleCase(String value) {
    return value
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    flashcardService = FlashcardService(Supabase.instance.client);
    _getFlashcardsCount();
  }

  @override
  void didUpdateWidget(FlashcardsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh when the page becomes visible (wasn't visible before, but is now)
    if (!oldWidget.isVisible && widget.isVisible) {
      _getFlashcardsCount();
    }
  }

  Future<void> _getFlashcardsCount() async {
    final fetchedCounts = await flashcardService.getFlashcardsCount();
    if (mounted) {
      setState(() {
        counts = fetchedCounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Text(
                AppLocalizations.of(context)!.vocabulary,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _toTitleCase(
                      AppLocalizations.of(context)!.flashcardsVocabulary,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const FaIcon(
                    FontAwesomeIcons.thinCardsBlank,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // Three colored boxes
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTabletLayout = constraints.maxWidth >= 700;
                  final sections = <Widget>[
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/saved_purple.png',
                      title: AppLocalizations.of(context)!.saved,
                      bodyText:
                          AppLocalizations.of(context)!.yourSavedVocabulary,
                      count: counts[0],
                      icon: FontAwesomeIcons.floppyDisk,
                      categoryName: 'saved',
                      shapeColor: AppColors.primary,
                    ),
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/difficult_red.png',
                      title: AppLocalizations.of(context)!.oops,
                      bodyText:
                          AppLocalizations.of(context)!.difficultVocabulary,
                      count: counts[1],
                      icon: FontAwesomeIcons.triangleExclamation,
                      categoryName: 'difficult',
                      shapeColor: AppColors.error,
                    ),
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath:
                          'assets/images/flashcards/training_secondary.png',
                      title: AppLocalizations.of(context)!.repeat,
                      bodyText:
                          AppLocalizations.of(context)!.vocabularyForTraining,
                      count: counts[2],
                      icon: FontAwesomeIcons.dumbbell,
                      categoryName: 'training',
                      shapeColor: AppColors.secondary,
                    ),
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/achieved_green.png',
                      title: AppLocalizations.of(context)!.mastered,
                      bodyText:
                          AppLocalizations.of(context)!.vocabularyAcquired,
                      count: counts[3],
                      icon: FontAwesomeIcons.badgeCheck,
                      categoryName: 'mastered',
                      shapeColor: AppColors.success,
                    ),
                  ];

                  if (!isTabletLayout) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          for (int i = 0; i < sections.length; i++) ...[
                            sections[i],
                            if (i < sections.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    );
                  }

                  final sectionWidth = (constraints.maxWidth - 40 - 12) / 2;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: sections
                          .map((section) => SizedBox(
                                width: sectionWidth,
                                child: section,
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardBox({
    required BuildContext context,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required String imagePath,
    required String title,
    required String bodyText,
    required int count,
    required String categoryName,
    IconData? icon,
    required Color shapeColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryName == 'saved'
              ? AppColors.primary.withOpacity(0.7)
              : categoryName == 'difficult'
                  ? AppColors.error.withOpacity(0.7)
                  : categoryName == 'training'
                      ? Colors.black.withOpacity(0.3)
                      : categoryName == 'mastered'
                          ? AppColors.success.withOpacity(0.7)
                          : AppColors.primary.withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardsCategoryPage(
                  categoryName: categoryName,
                ),
              ),
            );
            // Refresh flashcards count when returning from category page
            if (result == true && mounted) {
              _getFlashcardsCount();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            // Colored curved shape on the right side
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: CustomPaint(
                painter: CurvedShapePainter(color: shapeColor),
              ),
            ),
            // Image on the right side
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 120,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Transform.rotate(
                    angle: -0.2, // Rotate approximately -11.5 degrees
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Left side - Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title and Description
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  if (icon != null) ...[
                                    Icon(
                                      icon,
                                      size: 20,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                  Flexible(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bodyText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: textColor.withOpacity(0.9),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Count indicator badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: shapeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.items,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// Custom painter for the curved colored shape
class CurvedShapePainter extends CustomPainter {
  final Color color;

  CurvedShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderRadius = 12.0; // Match the container's border radius

    final path = Path();

    // Start from top-left with a curve
    path.moveTo(0, 0);

    // Create a smooth curved edge on the left side
    // The curve starts from top and curves inward, then back out at the bottom
    path.cubicTo(
      size.width * 0.2, // First control point x
      0, // First control point y (top)
      size.width * 0.15, // Second control point x
      size.height * 0.5, // Second control point y (middle)
      size.width * 0.2, // End point x
      size.height, // End point y (bottom)
    );

    // Continue to bottom-right, then add rounded corner
    path.lineTo(size.width - borderRadius, size.height);
    path.quadraticBezierTo(
      size.width, size.height, // Control point (corner)
      size.width, size.height - borderRadius, // End point
    );

    // Continue up the right edge, then add rounded top-right corner
    path.lineTo(size.width, borderRadius);
    path.quadraticBezierTo(
      size.width, 0, // Control point (corner)
      size.width - borderRadius, 0, // End point
    );

    // Close the path back to start
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
