import 'package:flutter/material.dart';
import 'dart:async';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  int _bpm = 120;
  bool _isPlaying = false;
  Timer? _timer;
  int _currentBeat = 0;
  final int _beatsPerMeasure = 4;
  String _subdivision = '1/4';
  double _multiplier = 1.0;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startMetronome();
      } else {
        _stopMetronome();
      }
    });
  }

  void _startMetronome() {
    _timer?.cancel();
    double effectiveBpm = _bpm * _multiplier;
    if (_subdivision == '1/8') effectiveBpm *= 2;
    if (_subdivision == '1/16') effectiveBpm *= 4;

    final intervalMs = (60000 / effectiveBpm).round();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      setState(() {
        _currentBeat = (_currentBeat % _beatsPerMeasure) + 1;
      });
    });
  }

  void _stopMetronome() {
    _timer?.cancel();
    setState(() {
      _currentBeat = 0;
    });
  }

  void _updateBpm(int newBpm) {
    setState(() {
      _bpm = newBpm.clamp(40, 260);
      if (_isPlaying) {
        _startMetronome();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('极简节拍器', style: TextStyle(color: Colors.white, letterSpacing: 2)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_bpm',
              style: const TextStyle(fontSize: 88, fontWeight: FontWeight.w200, color: Colors.white),
            ),
            const Text('BPM (速度)', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_beatsPerMeasure, (index) {
                bool isActive = _currentBeat == (index + 1);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.white : const Color(0xFF222222),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['1/4', '1/8', '1/16'].map((sub) {
                bool isSelected = _subdivision == sub;
                String labelName = sub == '1/16' ? '1/16 (一对四)' : sub;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(labelName),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _subdivision = sub;
                        if (_isPlaying) _startMetronome();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _bpm.toDouble(),
              min: 40,
              max: 260,
              divisions: 220,
              activeColor: Colors.white,
              inactiveColor: Colors.grey.shade800,
              onChanged: (value) => _updateBpm(value.round()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 36, color: Colors.white70),
                  onPressed: () => _updateBpm(_bpm - 1),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _togglePlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.white : const Color(0xFF222222),
                      foregroundColor: _isPlaying ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _isPlaying ? '暂停' : '开始',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 36, color: Colors.white70),
                  onPressed: () => _updateBpm(_bpm + 1),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
