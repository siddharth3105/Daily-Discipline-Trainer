import 'dart:math';
import 'package:flutter/material.dart';

// ── Figure Animation Widget ───────────────────────────────────────────────────
class FigureAnimation extends StatefulWidget {
  final String type;
  final Color color;
  final double speed;
  const FigureAnimation({super.key, required this.type, required this.color, this.speed = 1.0});

  @override
  State<FigureAnimation> createState() => _FigureAnimationState();
}

class _FigureAnimationState extends State<FigureAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _ctrl = AnimationController(vsync: this, duration: _getDuration())..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  Duration _getDuration() {
    final base = _getBaseDuration();
    return Duration(milliseconds: (base / widget.speed).round());
  }

  int _getBaseDuration() {
    switch (widget.type) {
      case 'jumpjax':
      case 'mountainclimber': return 650;
      case 'pushup':
      case 'benchpress':
      case 'burpee': return 1000;
      case 'squat':
      case 'ohp': return 1100;
      case 'pullup': return 1200;
      case 'deadlift': return 1800;
      case 'cobra':
      case 'hang': return 2500;
      default: return 2000;
    }
  }

  @override
  void didUpdateWidget(FigureAnimation old) {
    super.didUpdateWidget(old);
    if (old.speed != widget.speed || old.type != widget.type) {
      _ctrl.dispose();
      _initController();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(170, 140),
        painter: _FigurePainter(type: widget.type, color: widget.color, t: _anim.value),
      ),
    );
  }
}

// ── Figure Painter ────────────────────────────────────────────────────────────
class _FigurePainter extends CustomPainter {
  final String type;
  final Color color;
  final double t;

  _FigurePainter({required this.type, required this.color, required this.t});

  Paint get _p => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;

  Paint get _pFill => Paint()..color = color.withOpacity(0.5);

  void _circle(Canvas c, double x, double y, double r) {
    c.drawCircle(Offset(x, y), r, _p);
  }
  void _line(Canvas c, double x1, double y1, double x2, double y2) {
    c.drawLine(Offset(x1, y1), Offset(x2, y2), _p);
  }
  void _floor(Canvas c, Size s, String label) {
    final fp = Paint()..color = const Color(0xFF1E1E1E)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    c.drawLine(Offset(0, s.height - 16), Offset(s.width, s.height - 16), fp);
    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF444444), fontSize: 8, letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: s.width);
    tp.paint(c, Offset((s.width - tp.width) / 2, s.height - 12));
  }

  double _lerp(double a, double b) => a + (b - a) * (0.5 - 0.5 * cos(t * 2 * pi));

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'pushup':    _drawPushup(canvas, size);
      case 'pullup':    _drawPullup(canvas, size);
      case 'squat':     _drawSquat(canvas, size);
      case 'deadlift':  _drawDeadlift(canvas, size);
      case 'benchpress':_drawBench(canvas, size);
      case 'ohp':       _drawOhp(canvas, size);
      case 'plank':     _drawPlank(canvas, size);
      case 'jumpjax':   _drawJumpjax(canvas, size);
      case 'burpee':    _drawBurpee(canvas, size);
      case 'mountainclimber': _drawMtnClimber(canvas, size);
      case 'hang':      _drawHang(canvas, size);
      case 'cobra':     _drawCobra(canvas, size);
      case 'hipstretch':_drawHipStretch(canvas, size);
      case 'catcow':    _drawCatCow(canvas, size);
      default:          _drawPlank(canvas, size);
    }
  }

  void _drawPushup(Canvas c, Size s) {
    final bodyY = _lerp(0.0, 14.0);
    c.save();
    c.translate(0, bodyY);
    _circle(c, 144, 24, 13); // head
    _line(c, 130, 30, 16, 52); // body horizontal
    // Arms
    final armAngle = _lerp(-25.0 * pi/180, -92.0 * pi/180);
    c.save();
    c.translate(110, 44);
    c.rotate(armAngle);
    _line(c, 0, 0, 0, 26);
    c.restore();
    c.save();
    c.translate(72, 49);
    c.rotate(armAngle);
    _line(c, 0, 0, 0, 26);
    c.restore();
    // Legs
    _line(c, 16, 52, -4, 58);
    _line(c, -4, 58, -16, 88);
    _line(c, -4, 58, -8, 88);
    c.restore();
    _floor(c, s, 'LOWER → PUSH THROUGH');
  }

  void _drawPullup(Canvas c, Size s) {
    // Bar
    final barP = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(10,10), const Offset(120,10), barP);
    final bodyY = _lerp(0.0, -24.0);
    c.save();
    c.translate(65, 16 + bodyY);
    // Arms
    final armA = _lerp(-168.0*pi/180, -105.0*pi/180);
    c.save(); c.rotate(armA);
    _line(c, -21, 0, -23, 14);
    _line(c, -21, 0, -9, 28);
    c.restore();
    c.save(); c.rotate(-armA);
    _line(c, 21, 0, 23, 14);
    _line(c, 21, 0, 9, 28);
    c.restore();
    _circle(c, 0, 50, 13);
    _line(c, 0, 63, 0, 95);
    _line(c, -15, 95, 15, 95);
    _line(c, -15, 95, -19, 122);
    _line(c, 15, 95, 19, 122);
    c.restore();
    final tp = TextPainter(
      text: const TextSpan(text:'DRIVE ELBOWS DOWN', style: TextStyle(color: Color(0xFF444444), fontSize:8, letterSpacing:2)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: s.width);
    tp.paint(c, Offset((s.width - tp.width)/2, s.height - 12));
  }

  void _drawSquat(Canvas c, Size s) {
    // Bar
    final barP = Paint()..color = color.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(18,38), const Offset(112,38), barP);
    _circle(c, 65, 14, 13);
    final bodyY = _lerp(0.0, 24.0);
    c.save();
    c.translate(0, bodyY);
    _line(c, 65, 28, 65, 68);
    _line(c, 65, 44, 40, 60);
    _line(c, 40, 60, 32, 74);
    _line(c, 65, 44, 90, 60);
    _line(c, 90, 60, 98, 74);
    final legA = _lerp(0.0, 54.0*pi/180);
    c.save(); c.translate(50, 68); c.rotate(legA);
    _line(c, 0, 0, -12, 36); _line(c, -12, 36, -18, 64);
    c.restore();
    c.save(); c.translate(80, 68); c.scale(-1, 1); c.rotate(legA);
    _line(c, 0, 0, -12, 36); _line(c, -12, 36, -18, 64);
    c.restore();
    c.restore();
    _floor(c, s, 'BREAK PARALLEL');
  }

  void _drawDeadlift(Canvas c, Size s) {
    final barP = Paint()..color = color.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(8,124), const Offset(132,124), barP);
    _circle(c, 92, 14, 13);
    final torsoA = _lerp(0.0, 40.0*pi/180);
    c.save(); c.translate(88, 28); c.rotate(torsoA);
    _line(c, 0, 0, -20, 50);
    c.restore();
    _line(c, 68, 78, 52, 106); _line(c, 52, 106, 48, 132);
    _line(c, 68, 78, 82, 106); _line(c, 82, 106, 86, 132);
    _floor(c, s, 'NEUTRAL SPINE');
  }

  void _drawBench(Canvas c, Size s) {
    final benchP = Paint()..color = const Color(0xFF111111)..style = PaintingStyle.fill;
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(22,74,116,10), const Radius.circular(5)), benchP);
    _circle(c, 142, 54, 12);
    _line(c, 128, 60, 32, 68);
    final armA = _lerp(-55.0*pi/180, -108.0*pi/180);
    c.save(); c.translate(88, 64); c.rotate(armA);
    _line(c, 17, -2, 12, -28);
    _line(c, -14, 1, -18, -26);
    final barP = Paint()..color = color.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(-34,-31), const Offset(28,-31), barP);
    c.restore();
    _line(c, 32, 68, 14, 76); _line(c, 14, 76, 10, 104);
    _floor(c, s, 'LOWER TO CHEST');
  }

  void _drawOhp(Canvas c, Size s) {
    _circle(c, 62, 14, 12);
    _line(c, 62, 26, 62, 74);
    final armA = _lerp(-95.0*pi/180, -165.0*pi/180);
    c.save(); c.translate(62, 44); c.rotate(armA);
    _line(c, -34, 8, -44, -8);
    c.restore();
    c.save(); c.translate(62, 44); c.rotate(-armA);
    _line(c, 34, 8, 44, -8);
    c.restore();
    final barP = Paint()..color = color.withOpacity(0.85)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    final barY = _lerp(33.0, 6.0);
    c.drawLine(Offset(10, barY), Offset(114, barY), barP);
    _line(c, 62, 74, 46, 108); _line(c, 46, 108, 40, 136);
    _line(c, 62, 74, 78, 108); _line(c, 78, 108, 84, 136);
    _floor(c, s, 'PRESS OVERHEAD');
  }

  void _drawPlank(Canvas c, Size s) {
    final alpha = (0.5 + 0.5 * sin(t * 2 * pi)).clamp(0.0, 1.0);
    final plankP = Paint()..color = color.withOpacity(alpha)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(136,34), const Offset(14,54), plankP);
    c.drawCircle(const Offset(150,28), 12, plankP..style = PaintingStyle.stroke);
    c.drawLine(const Offset(118,42), const Offset(116,66), plankP);
    c.drawLine(const Offset(82,50), const Offset(78,68), plankP);
    c.drawCircle(const Offset(116,68), 5, Paint()..color = color.withOpacity(0.5*alpha));
    c.drawCircle(const Offset(78,70), 5, Paint()..color = color.withOpacity(0.5*alpha));
    c.drawLine(const Offset(14,54), const Offset(-8,60), plankP);
    c.drawLine(const Offset(-8,60), const Offset(-18,82), plankP);
    _floor(c, s, 'HOLD THE LINE');
  }

  void _drawJumpjax(Canvas c, Size s) {
    final lift = _lerp(0.0, -12.0);
    c.save(); c.translate(0, lift);
    _circle(c, 65, 14, 12);
    _line(c, 65, 26, 65, 68);
    final armA = _lerp(15.0*pi/180, -68.0*pi/180);
    c.save(); c.translate(65, 42);
    _line(c, 0, 0, -37, 16);
    c.save(); c.translate(-37, 16); c.rotate(armA);
    _line(c, 0, 0, -14, -14);
    c.restore();
    _line(c, 0, 0, 37, 16);
    c.save(); c.translate(37, 16); c.rotate(-armA);
    _line(c, 0, 0, 14, -14);
    c.restore();
    c.restore();
    final legA = _lerp(0.0, 30.0*pi/180);
    c.save(); c.translate(65, 68); c.rotate(-legA);
    _line(c, 0, 0, -23, 34); _line(c, -23, 34, -31, 62);
    c.restore();
    c.save(); c.translate(65, 68); c.rotate(legA);
    _line(c, 0, 0, 23, 34); _line(c, 23, 34, 31, 62);
    c.restore();
    c.restore();
    _floor(c, s, 'FULL EXTENSION');
  }

  void _drawBurpee(Canvas c, Size s) {
    // Phase: 0-0.3 standing, 0.3-0.65 plank, 0.65-1 jumping
    final phase = t;
    double bodyY = 0, bodyR = 0;
    if (phase < 0.3) {
      bodyY = _lerp(0, 18) * (phase / 0.3);
      bodyR = (70.0 * pi / 180) * (phase / 0.3);
    } else if (phase < 0.65) {
      bodyY = 18; bodyR = 70.0 * pi / 180;
    } else {
      final p2 = (phase - 0.65) / 0.35;
      bodyY = 18 - 32 * p2; bodyR = (70.0 * pi / 180) * (1 - p2);
    }
    c.save(); c.translate(70, 14 + bodyY); c.rotate(bodyR);
    _circle(c, 0, 0, 12);
    _line(c, 0, 12, 0, 54);
    _line(c, 0, 30, -28, 40); _line(c, -28, 40, -42, 30);
    _line(c, 0, 30, 28, 40); _line(c, 28, 40, 42, 30);
    _line(c, 0, 54, -18, 86); _line(c, -18, 86, -26, 114);
    _line(c, 0, 54, 18, 86); _line(c, 18, 86, 26, 114);
    c.restore();
    _floor(c, s, 'EXPLOSIVE JUMP');
  }

  void _drawMtnClimber(Canvas c, Size s) {
    _circle(c, 152, 26, 12);
    _line(c, 138, 32, 24, 50);
    _line(c, 120, 40, 118, 64);
    _line(c, 82, 48, 78, 66);
    c.drawCircle(const Offset(118,66), 4, Paint()..color = color.withOpacity(0.5));
    c.drawCircle(const Offset(78,68), 4, Paint()..color = color.withOpacity(0.5));
    final legLA = _lerp(0.0, -58.0*pi/180);
    final legRA = _lerp(-58.0*pi/180, 0.0);
    c.save(); c.translate(24, 50); c.rotate(legLA);
    _line(c, 0, 0, -12, 28); _line(c, -12, 28, -6, 46);
    c.restore();
    c.save(); c.translate(24, 50); c.rotate(legRA);
    _line(c, 0, 0, -20, 16); _line(c, -20, 16, -30, 32);
    c.restore();
    _floor(c, s, 'DRIVE KNEES HIGH');
  }

  void _drawHang(Canvas c, Size s) {
    final barP = Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(10,10), const Offset(115,10), barP);
    final swayA = _lerp(-5.0*pi/180, 5.0*pi/180);
    c.save(); c.translate(62, 14); c.rotate(swayA);
    _line(c, 0, 0, -20, 24); _line(c, -20, 24, -22, 38);
    _line(c, 0, 0, 20, 24); _line(c, 20, 24, 22, 38);
    _circle(c, 0, 50, 13);
    _line(c, 0, 63, 0, 92);
    _line(c, -14, 92, 14, 92);
    _line(c, -14, 92, -18, 122);
    _line(c, 14, 92, 18, 122);
    c.restore();
    final tp = TextPainter(
      text: const TextSpan(text:'DECOMPRESS SPINE', style: TextStyle(color: Color(0xFF444444), fontSize:8, letterSpacing:2)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: s.width);
    tp.paint(c, Offset((s.width - tp.width)/2, s.height - 8));
  }

  void _drawCobra(Canvas c, Size s) {
    final archA = _lerp(-10.0*pi/180, -32.0*pi/180);
    c.save(); c.translate(85, 80); c.rotate(archA);
    c.translate(-85, -80);
    _circle(c, 150, 30, 12);
    _line(c, 136, 36, 126, 48);
    final path = Path()..moveTo(126, 48)..quadraticBezierTo(100, 56, 76, 68)..quadraticBezierTo(52, 78, 28, 76);
    c.drawPath(path, _p..strokeWidth = 3);
    _line(c, 126, 48, 122, 70); _line(c, 100, 54, 98, 74);
    _line(c, 28, 76, 4, 78); _line(c, 28, 72, 4, 74);
    c.restore();
    _floor(c, s, 'ARCH AND HOLD');
  }

  void _drawHipStretch(Canvas c, Size s) {
    final lungeX = _lerp(0.0, 5.0);
    c.save(); c.translate(lungeX, 0);
    _circle(c, 65, 14, 12);
    _line(c, 65, 26, 65, 68);
    _line(c, 65, 42, 38, 34); _line(c, 38, 34, 28, 20);
    _line(c, 65, 42, 90, 32); _line(c, 90, 32, 102, 18);
    _line(c, 65, 68, 82, 96); _line(c, 82, 96, 88, 128);
    _line(c, 65, 68, 46, 96); _line(c, 46, 96, 42, 126);
    c.drawCircle(const Offset(42, 128), 5, Paint()..color = color.withOpacity(0.4));
    c.restore();
    _floor(c, s, 'TUCK PELVIS UNDER');
  }

  void _drawCatCow(Canvas c, Size s) {
    final spineScale = _lerp(1.0, 0.82);
    c.save(); c.translate(85, 55); c.scale(1, spineScale); c.translate(-85, -55);
    _circle(c, 142, 32, 11);
    final path = Path()..moveTo(130, 40)..quadraticBezierTo(105, 38, 80, 48)..quadraticBezierTo(55, 56, 32, 50);
    c.drawPath(path, _p..strokeWidth = 3);
    _line(c, 112, 42, 110, 66);
    _line(c, 44, 52, 42, 74);
    _line(c, 32, 50, 22, 72);
    _line(c, 32, 46, 20, 64);
    c.restore();
    _floor(c, s, 'ARCH ↕ ROUND');
  }

  @override
  bool shouldRepaint(_FigurePainter old) => old.t != t || old.type != type || old.color != color;
}
