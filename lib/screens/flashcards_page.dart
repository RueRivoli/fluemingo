import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'flashcards_category.dart';
import '../services/flashcard_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late final FlashcardService flashcardService;
  List<int> counts = [0, 0, 0, 0]; // Initialize with default values to avoid index errors

  @override
  void initState() {
    super.initState();
    flashcardService = FlashcardService(Supabase.instance.client);
    _getFlashcardsCount();
  }

  Future<void> _getFlashcardsCount() async {
    final fetchedCounts = await flashcardService.getFlashcardsCount();
    if (mounted) {
      setState(() {
        counts = fetchedCounts;
      });
      print("counts: $counts");
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
              child: const Text(
                'Vocabulary',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: const Text(
                'Flashcards on vocabulary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Three colored boxes
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Saved - Primary color
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/saved_purple.png',
                      title: 'saved',
                      bodyText: 'Your saved vocabulary',
                      count: counts[0],
                      icon: Icons.bookmark,
                      categoryName: 'saved',
                      shapeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    
                    // Oops - Red color
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/difficult_red.png',
                      title: 'Oops',
                      bodyText: 'Difficult vocabulary',
                      count: counts[1],
                      icon: Icons.warning,
                      categoryName: 'difficult',
                      shapeColor: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    
                    // Repeat - Secondary color
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/training_secondary.png',
                      title: 'Repeat',
                      bodyText: 'Key vocab to repeat',
                      count: counts[2],
                      icon: Icons.refresh,
                      categoryName: 'training',
                      shapeColor: AppColors.secondary,
                    ),
                                        const SizedBox(height: 12),
                    
                    // Acknowledgement - Green color
                    _buildFlashcardBox(
                      context: context,
                      backgroundColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      imagePath: 'assets/images/flashcards/achieved_green.png',
                      title: 'Acknowledged',
                      bodyText: 'Vocab you acquired',
                      count: counts[3],
                      icon: Icons.check,
                      categoryName: 'acknowledged',
                      shapeColor: AppColors.success,
                    ),
                  ],
                ),
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
    bool isPremium = false,
    required Color shapeColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: backgroundColor,
       borderRadius: BorderRadius.circular(12),
       border: Border.all(
          color: borderColor,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardsCategoryPage(
                  categoryName: categoryName,
                ),
              ),
            );
          },
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Stack(
            children: [
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
                                      const SizedBox(width: 8),
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
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: shapeColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'items',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: shapeColor.withOpacity(0.8),
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
            ]
          ),
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
    
    // Continue to bottom-right
    path.lineTo(size.width, size.height);
    
    // Continue to top-right
    path.lineTo(size.width, 0);
    
    // Close the path back to start
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

