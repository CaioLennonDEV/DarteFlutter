import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/audio_memo.dart';

class AudioRecorderModal extends StatefulWidget {
  final Function(AudioMemo memo) onSaveAudio;

  const AudioRecorderModal({
    super.key,
    required this.onSaveAudio,
  });

  static void show(
    BuildContext context, {
    required Function(AudioMemo memo) onSaveAudio,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioRecorderModal(onSaveAudio: onSaveAudio),
    );
  }

  @override
  State<AudioRecorderModal> createState() => _AudioRecorderModalState();
}

class _AudioRecorderModalState extends State<AudioRecorderModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlaying = false;
  String _audioTitle = 'Nota de Voz';
  String? _generatedTranscript;
  bool _isTranscribing = false;

  final TextEditingController _titleController =
      TextEditingController(text: 'Nota de Voz');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _hasRecorded = false;
      _secondsElapsed = 0;
      _generatedTranscript = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
      if (_secondsElapsed == 0) _secondsElapsed = 1;
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      Future.delayed(Duration(seconds: _secondsElapsed), () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  void _transcribeWithAI() async {
    setState(() {
      _isTranscribing = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _isTranscribing = false;
      _generatedTranscript =
          '🗣️ **Transcrição & Insights NotaIA**:\n'
          '• Ponto principal gravado em áudio (${_formatTime(_secondsElapsed)} de gravação).\n'
          '• Ação destacada: revisar anotação e alinhar com a equipe.\n'
          '• Gravação sincronizada localmente com sucesso.';
    });
  }

  String _formatTime(int sec) {
    final m = (sec / 60).floor().toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Gravar Áudio com IA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Title input
          TextField(
            controller: _titleController,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Título do Áudio',
              prefixIcon: const Icon(Icons.title, size: 18),
              isDense: true,
            ),
          ),

          const SizedBox(height: 24),

          // Animated Waveform Display
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecording
                    ? AppColors.error.withOpacity(0.5)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(24, (index) {
                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final value = _isRecording || _isPlaying
                        ? sin((index * 0.3) + (_animController.value * 2 * pi)).abs()
                        : 0.15;
                    final barHeight = max(8.0, value * 55.0);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 4,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.error
                            : (_isPlaying ? AppColors.primary : const Color(0xFF94A3B8)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Timer Display
          Text(
            _formatTime(_secondsElapsed),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: _isRecording ? AppColors.error : AppColors.primaryLight,
            ),
          ),

          const SizedBox(height: 20),

          // Action Controls: Record, Stop, Play
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRecording && !_hasRecorded)
                FilledButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.fiber_manual_record, color: Colors.white),
                  label: const Text('Iniciar Gravação'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

              if (_isRecording)
                FilledButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop_rounded, color: Colors.white),
                  label: const Text('Parar Gravação'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

              if (_hasRecorded) ...[
                OutlinedButton.icon(
                  onPressed: _togglePlayback,
                  icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(_isPlaying ? 'Pausar' : 'Ouvir'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _isTranscribing ? null : _transcribeWithAI,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Transcrever IA'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),

          // Generated Transcript box (if available)
          if (_generatedTranscript != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Text(
                _generatedTranscript!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save & Attach to Note
          if (_hasRecorded)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  final memo = AudioMemo(
                    id: const Uuid().v4(),
                    title: _titleController.text.trim().isEmpty
                        ? 'Nota de Voz'
                        : _titleController.text.trim(),
                    durationSeconds: _secondsElapsed,
                    transcript: _generatedTranscript,
                    recordedAt: DateTime.now(),
                  );
                  widget.onSaveAudio(memo);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Anexar Áudio à Nota', style: TextStyle(fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
