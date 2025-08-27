import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Confetti Particle Class
class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;
  late double gravity;
  late double life;
  late double maxLife;

  ConfettiParticle(double startX, double startY) {
    final random = Random();
    x = startX;
    y = startY;
    vx = (random.nextDouble() - 0.5) * 10;
    vy = -random.nextDouble() * 15 - 5;
    color = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange][random.nextInt(6)];
    size = random.nextDouble() * 8 + 4;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
    gravity = 0.3;
    maxLife = 120;
    life = maxLife;
  }

  void update() {
    x += vx;
    y += vy;
    vy += gravity;
    rotation += rotationSpeed;
    life--;
  }

  bool get isDead => life <= 0;

  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}

// Confetti Widget
class ConfettiWidget extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const ConfettiWidget({super.key, required this.isActive, required this.child});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<ConfettiParticle> particles = [];
  late Size screenSize;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animationController.addListener(_updateParticles);
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    particles.clear();
    final random = Random();
    
    // Create particles from multiple points
    for (int i = 0; i < 50; i++) {
      particles.add(ConfettiParticle(
        screenSize.width * 0.5 + (random.nextDouble() - 0.5) * 100,
        screenSize.height * 0.3,
      ));
    }
    
    _animationController.reset();
    _animationController.forward();
  }

  void _updateParticles() {
    setState(() {
      particles.forEach((particle) => particle.update());
      particles.removeWhere((particle) => particle.isDead || particle.y > screenSize.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        widget.child,
        if (particles.isNotEmpty)
          CustomPaint(
            painter: ConfettiPainter(particles),
            size: screenSize,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Confetti Painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      
      // Draw confetti as small rectangles
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pointer Painter for wheel indicator
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Enhanced pointer with gradient and glow effects
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.grey.shade100,
        Colors.grey.shade200,
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Draw glow effect behind pointer
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Enhanced pointer shape with rounded edges
    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom center
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.7, 0, size.height * 0.2); // Left curve
    path.quadraticBezierTo(size.width * 0.2, 0, size.width / 2, 0); // Top left curve
    path.quadraticBezierTo(size.width * 0.8, 0, size.width, size.height * 0.2); // Top right curve
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.7, size.width / 2, size.height); // Right curve
    path.close();
    
    // Draw glow
    canvas.drawPath(path, glowPaint);
    
    // Draw main pointer
    canvas.drawPath(path, paint);
    
    // Enhanced border with multiple layers
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, innerBorderPaint);
    
    // Add small highlight at the tip
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.1),
      2,
      highlightPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wheel Painter for displaying dishes
class WheelPainter extends CustomPainter {
  final List<String> dishes;
  final double rotation;

  WheelPainter({required this.dishes, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    if (dishes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / dishes.length;

    // Enhanced gradient colors for segments
    final gradientColors = [
      [const Color(0xFF8B5CF6), const Color(0xFF6366F1)], // Purple gradient
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan gradient
      [const Color(0xFF10B981), const Color(0xFF059669)], // Green gradient
      [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amber gradient
      [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Red gradient
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pink gradient
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Purple to Pink
      [const Color(0xFF06B6D4), const Color(0xFF10B981)], // Cyan to Green
    ];

    // Draw outer glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(center, radius + 4, glowPaint);

    for (int i = 0; i < dishes.length; i++) {
      final startAngle = i * segmentAngle + rotation;
      final sweepAngle = segmentAngle;
      final colorPair = gradientColors[i % gradientColors.length];
      
      // Create gradient for each segment
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          colorPair[0].withOpacity(0.9),
          colorPair[1].withOpacity(0.7),
          colorPair[1].withOpacity(0.9),
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      
      // Draw segment with gradient
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      
      // Draw inner shadow effect
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      final shadowRect = Rect.fromCircle(center: center, radius: radius * 0.95);
      canvas.drawArc(shadowRect, startAngle, sweepAngle, true, shadowPaint);
      
      // Draw segment with main gradient again (layered effect)
      final mainPaint = Paint()
        ..shader = gradient.createShader(shadowRect)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(shadowRect, startAngle, sweepAngle, true, mainPaint);
      
      // Draw enhanced segment border with glow
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);
      
      // Draw thin inner border
      final innerBorderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, innerBorderPaint);
      
      // Draw text with enhanced styling
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + cos(textAngle) * textRadius;
      final textY = center.dy + sin(textAngle) * textRadius;
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      
      // Enhanced text with multiple shadows for depth
      final textPainter = TextPainter(
        text: TextSpan(
          text: dishes[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black87,
              ),
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
              Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.white24,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      
      canvas.restore();
    }
    
    // Draw enhanced center circle with gradient
    final centerRadius = radius * 0.18;
    final centerGradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.grey.shade100,
        Colors.grey.shade200,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final centerPaint = Paint()
      ..shader = centerGradient.createShader(
        Rect.fromCircle(center: center, radius: centerRadius),
      )
      ..style = PaintingStyle.fill;
    
    // Draw center shadow
    final centerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(center, centerRadius + 2, centerShadowPaint);
    canvas.drawCircle(center, centerRadius, centerPaint);
    
    // Draw center border with glow
    final centerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    
    canvas.drawCircle(center, centerRadius, centerBorderPaint);
    
    // Draw enhanced center icon with shadow
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🍽️',
        style: TextStyle(
          fontSize: 28,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black26,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WheelPainter &&
        (oldDelegate.rotation != rotation || oldDelegate.dishes != dishes);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin Dinner Dish',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spin Dinner Dish'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<String> _challenges = [];
  final TextEditingController _challengeController = TextEditingController();
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _addChallenge() {
    if (_challengeController.text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _challenges.add(_challengeController.text);
        _challengeController.clear();
      });
    }
  }

  void _navigateToWheel() {
    if (_challenges.isNotEmpty) {
      HapticFeedback.mediumImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpinWheelScreen(challenges: _challenges),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeTablet = screenSize.width > 900;
    final horizontalPadding = isLargeTablet ? 60.0 : (isTablet ? 40.0 : 20.0);
    final titleFontSize = isLargeTablet ? 32.0 : (isTablet ? 28.0 : 24.0);
    final maxContentWidth = isLargeTablet ? 800.0 : (isTablet ? 600.0 : double.infinity);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '🍽️ Spin Dinner Dish',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (_challenges.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Dishes'),
                    content: const Text('Are you sure you want to remove all dishes?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _challenges.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.clear_all,
              color: Colors.white,
            ),
            tooltip: 'Clear All Dishes',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFF06B6D4),
              Color(0xFF10B981),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 80.0, horizontalPadding, 20.0),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 24 : 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Text(
                              'Add your dishes:',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Input Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _challengeController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter a dish name...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onSubmitted: (_) => _addChallenge(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _addChallenge,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 24 : 20,
                                      vertical: isTablet ? 16 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Dishes List
                      if (_challenges.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Dishes (${_challenges.length}):',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _challenges.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _challenges[index],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  _challenges.removeAt(index);
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_challenges.isEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(isTablet ? 24 : 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '🍽️ No dishes added yet.\nAdd some dishes to get started!',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      // Centered Start Button with Enhanced Glassmorphism
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _challenges.isNotEmpty
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.25),
                                            Colors.white.withOpacity(0.1),
                                            const Color(0xFF8B5CF6).withOpacity(0.2),
                                            const Color(0xFF06B6D4).withOpacity(0.15),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.grey.withOpacity(0.1),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: _challenges.isNotEmpty
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: _challenges.isNotEmpty
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                            blurRadius: 25,
                                            offset: const Offset(0, 12),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, -2),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: _challenges.isNotEmpty ? _navigateToWheel : null,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 50 : 40,
                                        vertical: isTablet ? 22 : 18,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _challenges.isEmpty
                                                ? Icons.warning_amber_rounded
                                                : Icons.play_circle_filled,
                                            color: _challenges.isNotEmpty
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
                                            size: isTablet ? 28 : 24,
                                          ),
                                          const SizedBox(width: 12),
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: Text(
                                              _challenges.isEmpty
                                                  ? 'Add dishes to continue'
                                                  : '🎯 Start Spinning!',
                                              key: ValueKey(_challenges.isEmpty),
                                              style: TextStyle(
                                                fontSize: isTablet ? 22 : 20,
                                                fontWeight: FontWeight.bold,
                                                color: _challenges.isNotEmpty
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(0.6),
                                                letterSpacing: 0.5,
                                                shadows: [
                                                  Shadow(
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 3,
                                                    color: Colors.black.withOpacity(0.3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

    );
  }

  @override
  void dispose() {
    _challengeController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }
}

class SpinWheelScreen extends StatefulWidget {
  final List<String> challenges;

  const SpinWheelScreen({super.key, required this.challenges});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _selectedChallenge = '';
  bool _isSpinning = false;
  bool _showConfetti = false;
  final Random _random = Random();
  double _rotationMultiplier = 15.0; // Default rotation multiplier

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedChallenge = '';
      _showConfetti = false;
    });

    HapticFeedback.mediumImpact();

    // Generate random rotation multiplier between 15 and 35
    _rotationMultiplier = 15 + _random.nextDouble() * 20; // 15 to 35

    _controller.reset();
    _controller.forward().then((_) {
      // Calculate which segment is at the top of the wheel when it stops
      final finalRotation = _animation.value * _rotationMultiplier * 3.14159;
      final segmentAngle = 2 * pi / widget.challenges.length;
      
      // Normalize the rotation to 0-2π range
      final normalizedRotation = finalRotation % (2 * pi);
      
      // Calculate which segment is at the top (12 o'clock position)
      // Segments start at 0 radians (3 o'clock), so top is at -π/2 from start
      // We need to find which segment covers the top position (-π/2 or 3π/2)
      final topPosition = (3 * pi / 2 - normalizedRotation) % (2 * pi);
      final selectedIndex = (topPosition / segmentAngle).floor() % widget.challenges.length;
      
      setState(() {
        _selectedChallenge = widget.challenges[selectedIndex];
        _isSpinning = false;
        _showConfetti = true; // Trigger confetti animation
      });
      HapticFeedback.heavyImpact();
      
      // Reset confetti after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final wheelSize = isTablet ? 300.0 : 250.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🎰 Spin the Wheel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ConfettiWidget(
        isActive: _showConfetti,
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFF06B6D4),
              Color(0xFF10B981),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wheel with pointer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wheel
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: wheelSize,
                          height: wheelSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              // Main shadow
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: 2,
                              ),
                              // Secondary shadow for depth
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                                spreadRadius: 5,
                              ),
                              // Subtle inner glow
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, -5),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            size: Size(wheelSize, wheelSize),
                            painter: WheelPainter(
                              dishes: widget.challenges,
                              rotation: _animation.value * _rotationMultiplier * 3.14159,
                            ),
                          ),
                        );
                      },
                    ),
                    // Pointer
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 0,
                        height: 0,
                        decoration: const BoxDecoration(),
                        child: CustomPaint(
                          size: const Size(30, 40),
                          painter: PointerPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Result
                if (_selectedChallenge.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '🎉 Tonight\'s Dish:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedChallenge,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                // Spin Button - only show if no dish is selected
                if (_selectedChallenge.isEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _isSpinning ? null : _spinWheel,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 50 : 40,
                                  vertical: isTablet ? 24 : 20,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isSpinning ? Icons.casino : Icons.play_circle_filled,
                                      color: Colors.white,
                                      size: isTablet ? 28 : 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isSpinning ? '🎰 Spinning...' : '🎯 Start Spinning!',
                                      style: TextStyle(
                                        fontSize: isTablet ? 22 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
        ), // Close ConfettiWidget
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
