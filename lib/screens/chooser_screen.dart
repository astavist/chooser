import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/choice_circle.dart';
import 'settings_screen.dart';

class ChooserScreen extends StatefulWidget {
  const ChooserScreen({super.key});

  @override
  State<ChooserScreen> createState() => _ChooserScreenState();
}

class _ChooserScreenState extends State<ChooserScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _choices = [];
  final TextEditingController _textController = TextEditingController();
  String? _selectedChoice;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _addChoice() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _choices.add(_textController.text);
        _textController.clear();
      });
    }
  }

  void _makeChoice() {
    if (_choices.isEmpty) return;
    _controller.reset();
    _controller.forward();
    setState(() {
      _selectedChoice = _choices[Random().nextInt(_choices.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Chooser',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter a choice',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addChoice,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onSubmitted: (_) => _addChoice(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _choices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _choices[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _choices.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_choices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _makeChoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Make a Choice',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          if (_selectedChoice != null)
            ChoiceCircle(
              choice: _selectedChoice!,
              animation: _animation,
            ),
        ],
      ),
    );
  }
} 