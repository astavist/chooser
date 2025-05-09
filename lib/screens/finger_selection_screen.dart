import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mode.dart';

class FingerSelectionScreen extends StatefulWidget {
  const FingerSelectionScreen({super.key});

  @override
  State<FingerSelectionScreen> createState() => _FingerSelectionScreenState();
}

class _FingerSelectionScreenState extends State<FingerSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<int, _TouchPoint> _touchPoints = {};
  Mode _currentMode = Mode.single;
  int _count = 1;
  bool _isSelecting = false;
  List<Color> _colors = [];
  final List<_NumberLabel> _numbers = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // Debug mesajı
    print('FingerSelectionScreen başlatılıyor...');
    
    // Asenkron işlemler içeren karmaşık işlemler yerine
    // basit bir başlatma yapalım
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _generateColors();
      
      // Başarılı başlangıç
      _isLoaded = true;
      print('FingerSelectionScreen başlatma başarılı');
    } catch (e) {
      print('FingerSelectionScreen başlatma hatası: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateColors() {
    final random = math.Random();
    _colors = List.generate(5, (index) {
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isSelecting) return;

    setState(() {
      _touchPoints[event.pointer] = _TouchPoint(
        position: event.localPosition,
        color: _colors[_touchPoints.length % _colors.length],
        scale: _controller.drive(
          Tween(begin: 1.0, end: 1.2),
        ),
      );
    });

    if (_touchPoints.length > 1) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (_touchPoints.isNotEmpty && !_isSelecting) {
          _selectWinners();
        }
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_touchPoints.containsKey(event.pointer)) {
      setState(() {
        _touchPoints[event.pointer]!.position = event.localPosition;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _touchPoints.remove(event.pointer);
    });

    if (_touchPoints.isEmpty && _isSelecting) {
      _resetSelection();
    }
  }

  void _selectWinners() {
    if (_touchPoints.length <= _count) return;

    setState(() {
      _isSelecting = true;
      switch (_currentMode) {
        case Mode.single:
          _selectSingleMode();
        case Mode.group:
          _selectGroupMode();
        case Mode.order:
          _selectOrderMode();
      }
    });
    _controller.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  void _selectSingleMode() {
    final List<int> pointers = _touchPoints.keys.toList()..shuffle();
    final winners = pointers.take(_count).toList();
    
    for (final pointer in pointers.skip(_count)) {
      _touchPoints.remove(pointer);
    }

    for (final winner in winners) {
      _touchPoints[winner]!.isWinner = true;
      _touchPoints[winner]!.scale = _controller.drive(
        Tween(begin: 1.0, end: 1.2),
      );
    }
  }

  void _selectGroupMode() {
    final List<int> pointers = _touchPoints.keys.toList()..shuffle();
    final int teamSize = _touchPoints.length ~/ _count;
    int remainder = _touchPoints.length % _count;
    
    _generateColors();
    int colorIndex = 0;
    int currentIndex = 0;

    for (int i = 0; i < _count; i++) {
      final size = remainder > 0 ? teamSize + 1 : teamSize;
      remainder--;

      for (int j = 0; j < size && currentIndex < pointers.length; j++) {
        final pointer = pointers[currentIndex++];
        _touchPoints[pointer]!.color = _colors[colorIndex];
        _touchPoints[pointer]!.isWinner = true;
        _touchPoints[pointer]!.scale = _controller.drive(
          Tween(begin: 1.0, end: 1.2),
        );
      }
      colorIndex = (colorIndex + 1) % _colors.length;
    }
  }

  void _selectOrderMode() {
    void selectNext(int number) {
      final availablePointers = _touchPoints.entries
          .where((e) => !e.value.isWinner)
          .map((e) => e.key)
          .toList();

      if (availablePointers.isEmpty) return;

      final selected = availablePointers[math.Random().nextInt(availablePointers.length)];
      _touchPoints[selected]!.isWinner = true;
      _touchPoints[selected]!.scale = _controller.drive(
        Tween(begin: 1.0, end: 1.2),
      );

      _numbers.add(_NumberLabel(
        number: number,
        position: _touchPoints[selected]!.position,
        color: _touchPoints[selected]!.color,
      ));

      if (availablePointers.length > 1) {
        Future.delayed(
          Duration(milliseconds: math.min(3000 ~/ _touchPoints.length, 800)),
          () => selectNext(number + 1),
        );
      }
    }

    selectNext(1);
  }

  void _resetSelection() {
    setState(() {
      _isSelecting = false;
      _numbers.clear();
      _generateColors();
    });
    _controller.reset();
  }

  void _cycleMode() {
    if (_isSelecting) return;
    setState(() {
      _currentMode = _currentMode.next();
      _count = _currentMode.initialCount();
    });
  }

  void _cycleCount() {
    if (_isSelecting) return;
    setState(() {
      _count = _currentMode.nextCount(_count);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ekran başlatılamadıysa basit bir yükleme ekranı gösterelim
    if (!_isLoaded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Yükleniyor...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    
    // Normal ekranı render edelim
    try {
      // Burada mevcut ekranın build kodu
      return Scaffold(
        backgroundColor: Colors.black,
        body: Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          child: Stack(
            children: [
              // Touch points
              for (final point in _touchPoints.entries)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: point.value.position.dx - 40,
                  top: point.value.position.dy - 40,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: point.value.scale?.value ?? 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: point.value.color,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: point.value.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Number labels for order mode
              for (final number in _numbers)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: number.position.dx - 20,
                  top: number.position.dy - 60,
                  child: Text(
                    number.number.toString(),
                    style: TextStyle(
                      color: number.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Mode button
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 16,
                child: IconButton(
                  icon: Icon(
                    _currentMode == Mode.single
                        ? Icons.person
                        : _currentMode == Mode.group
                            ? Icons.group
                            : Icons.format_list_numbered,
                    color: Colors.white,
                  ),
                  onPressed: _cycleMode,
                ),
              ),
              // Count button
              if (_currentMode != Mode.order)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).padding.top + 16,
                  child: IconButton(
                    icon: Text(
                      _count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _cycleCount,
                  ),
                ),
              // Çizim alanı
              CustomPaint(
                painter: _TouchPointsPainter(
                  touchPoints: _touchPoints,
                ),
                size: Size.infinite,
              ),
              
              // Sayı etiketleri
              if (_numbers.isNotEmpty)
                CustomPaint(
                  painter: _NumberLabelPainter(
                    numbers: _numbers,
                  ),
                  size: Size.infinite,
                ),
                
              // Mod göstergesi
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _cycleMode,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        _currentMode.displayName(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Sayaç göstergesi
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _cycleCount,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // Herhangi bir render hatası durumunda basit bir hata ekranı gösterelim
      print('FingerSelectionScreen render hatası: $e');
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Chooser - Hata'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Ekran yüklenirken bir hata oluştu',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Ekranı yeniden başlatmayı deneyelim
                    _isLoaded = false;
                    initState();
                  });
                },
                child: Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _TouchPoint {
  Offset position;
  Color color;
  bool isWinner;
  Animation<double>? scale;

  _TouchPoint({
    required this.position,
    required this.color,
    this.isWinner = false,
    this.scale,
  });
}

class _NumberLabel {
  final int number;
  final Offset position;
  final Color color;

  _NumberLabel({
    required this.number,
    required this.position,
    required this.color,
  });
}

class _TouchPointsPainter extends CustomPainter {
  final Map<int, _TouchPoint> touchPoints;

  _TouchPointsPainter({
    required this.touchPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in touchPoints.values) {
      final radius = point.isWinner && point.scale != null
          ? 40.0 * point.scale!.value
          : 40.0;

      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point.position, radius, paint);

      // Kenar çizgisi
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(point.position, radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NumberLabelPainter extends CustomPainter {
  final List<_NumberLabel> numbers;

  _NumberLabelPainter({
    required this.numbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    for (final number in numbers) {
      final textSpan = TextSpan(
        text: number.number.toString(),
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final offset = Offset(
        number.position.dx - textPainter.width / 2,
        number.position.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 