import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';
import '../services/gemini_ai_service.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  int _tabIdx = 0; // 0=chat, 1=workout generator, 2=diet generator
  final _questionCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  String _aiProvider = 'groq'; // 'groq' or 'gemini'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('AI FITNESS COACH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: AppColors.textDim),
            onSelected: (value) => setState(() => _aiProvider = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'groq', child: Row(children: [
                if (_aiProvider == 'groq') const Icon(Icons.check, size: 16, color: AppColors.hiit),
                const SizedBox(width: 8),
                const Text('Groq (Ultra Fast)'),
              ])),
              PopupMenuItem(value: 'gemini', child: Row(children: [
                if (_aiProvider == 'gemini') const Icon(Icons.check, size: 16, color: AppColors.hiit),
                const SizedBox(width: 8),
                const Text('Google Gemini'),
              ])),
            ],
          ),
        ],
      ),
      body: Column(children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(children: [
            _buildTab('💬 CHAT', 0),
            const SizedBox(width: 5),
            _buildTab('💪 WORKOUT', 1),
            const SizedBox(width: 5),
            _buildTab('🍽️ DIET', 2),
          ]),
        ),
        Expanded(child: IndexedStack(index: _tabIdx, children: [
          _ChatTab(messages: _messages, loading: _loading, onSend: _sendMessage),
          _WorkoutGeneratorTab(aiProvider: _aiProvider),
          _DietGeneratorTab(aiProvider: _aiProvider),
        ])),
      ]),
    );
  }

  Widget _buildTab(String label, int idx) {
    final active = _tabIdx == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tabIdx = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: active ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: active ? AppColors.hiit : AppColors.textSub, letterSpacing: 1))),
      ),
    ));
  }

  Future<void> _sendMessage(String question) async {
    if (question.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: question, isUser: true));
      _loading = true;
    });

    try {
      final answer = _aiProvider == 'groq'
          ? await GroqAiService.getFitnessAdvice(question)
          : await GeminiAiService.getCoachingAdvice(question);
      
      setState(() {
        _messages.add(ChatMessage(text: answer, isUser: false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: ${e.toString().replaceAll('Exception: ', '')}', isUser: false, isError: true));
        _loading = false;
      });
    }
  }
}

// Chat Tab
class _ChatTab extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool loading;
  final Function(String) onSend;
  const _ChatTab({required this.messages, required this.loading, required this.onSend});
  @override State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: widget.messages.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Text('🤖', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('Ask me anything about fitness!', style: TextStyle(fontSize: 16, color: AppColors.textDim)),
              SizedBox(height: 8),
              Text('Try: "How do I build muscle?"', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
            ]))
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(14),
              itemCount: widget.messages.length,
              itemBuilder: (_, i) => _MessageBubble(message: widget.messages[i]),
            )),
      if (widget.loading)
        const Padding(
          padding: EdgeInsets.all(14),
          child: Row(children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.hiit)),
            SizedBox(width: 12),
            Text('AI is thinking...', style: TextStyle(color: AppColors.textDim)),
          ]),
        ),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: AppColors.textPrim),
            decoration: const InputDecoration(
              hintText: 'Ask your fitness question...',
              isDense: true,
              contentPadding: EdgeInsets.all(12),
            ),
            onSubmitted: (text) {
              widget.onSend(text);
              _ctrl.clear();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_scrollCtrl.hasClients) {
                  _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              });
            },
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              widget.onSend(_ctrl.text);
              _ctrl.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.send, color: Colors.black, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.hiit.withOpacity(0.2) : message.isError ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: message.isUser ? AppColors.hiit : message.isError ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text, style: TextStyle(color: message.isError ? AppColors.hiit : AppColors.textPrim, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

// Workout Generator Tab
class _WorkoutGeneratorTab extends StatefulWidget {
  final String aiProvider;
  const _WorkoutGeneratorTab({required this.aiProvider});
  @override State<_WorkoutGeneratorTab> createState() => _WorkoutGeneratorTabState();
}

class _WorkoutGeneratorTabState extends State<_WorkoutGeneratorTab> {
  String _goal = 'Build Muscle';
  String _level = 'Intermediate';
  int _days = 5;
  bool _loading = false;
  String? _result;

  Future<void> _generate() async {
    setState(() { _loading = true; _result = null; });
    try {
      if (widget.aiProvider == 'groq') {
        final result = await GroqAiService.generateWorkoutPlan(goal: _goal, fitnessLevel: _level, equipment: 'Full Gym', daysPerWeek: _days);
        setState(() {
          _result = result.description;
          _loading = false;
        });
      } else {
        final result = await GeminiAiService.generateWorkoutPlan(goal: _goal, level: _level, daysPerWeek: _days);
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GOAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: ['Build Muscle', 'Lose Fat', 'Get Stronger', 'Improve Endurance'].map((g) {
          final active = _goal == g;
          return GestureDetector(
            onTap: () => setState(() => _goal = g),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.hiit.withOpacity(0.2) : AppColors.card2,
                border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(g, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.hiit : AppColors.textDim)),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),
        const Text('FITNESS LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
          final active = _level == l;
          return GestureDetector(
            onTap: () => setState(() => _level = l),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.hiit.withOpacity(0.2) : AppColors.card2,
                border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.hiit : AppColors.textDim)),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),
        Text('DAYS PER WEEK: $_days', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        Slider(value: _days.toDouble(), min: 3, max: 7, divisions: 4, activeColor: AppColors.hiit, inactiveColor: AppColors.border, onChanged: (v) => setState(() => _days = v.toInt())),
      ])),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _loading ? null : _generate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _loading ? AppColors.card : AppColors.hiit, borderRadius: BorderRadius.circular(13)),
          child: Center(child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('GENERATE WORKOUT PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
        ),
      ),
      if (_result != null) ...[
        const SizedBox(height: 12),
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI-GENERATED PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.hiit, letterSpacing: 3)),
          const SizedBox(height: 12),
          Text(_result!, style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.6)),
        ])),
      ],
    ]);
  }
}

// Diet Generator Tab
class _DietGeneratorTab extends StatefulWidget {
  final String aiProvider;
  const _DietGeneratorTab({required this.aiProvider});
  @override State<_DietGeneratorTab> createState() => _DietGeneratorTabState();
}

class _DietGeneratorTabState extends State<_DietGeneratorTab> {
  String _goal = 'Muscle Gain';
  int _calories = 2500;
  String _restrictions = 'None';
  bool _loading = false;
  String? _result;

  Future<void> _generate() async {
    setState(() { _loading = true; _result = null; });
    try {
      if (widget.aiProvider == 'groq') {
        final result = await GroqAiService.generateDietPlan(goal: _goal, targetCalories: _calories, dietaryRestrictions: _restrictions, mealsPerDay: 5);
        setState(() {
          _result = result.description;
          _loading = false;
        });
      } else {
        final result = await GeminiAiService.generateDietPlan(goal: _goal, calories: _calories, restrictions: _restrictions);
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GOAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: ['Muscle Gain', 'Fat Loss', 'Maintenance', 'Performance'].map((g) {
          final active = _goal == g;
          return GestureDetector(
            onTap: () => setState(() => _goal = g),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.hiit.withOpacity(0.2) : AppColors.card2,
                border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(g, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.hiit : AppColors.textDim)),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),
        Text('DAILY CALORIES: $_calories', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        Slider(value: _calories.toDouble(), min: 1500, max: 4000, divisions: 25, activeColor: AppColors.hiit, inactiveColor: AppColors.border, onChanged: (v) => setState(() => _calories = v.toInt())),
        const SizedBox(height: 14),
        const Text('DIETARY RESTRICTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: ['None', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Dairy-Free'].map((r) {
          final active = _restrictions == r;
          return GestureDetector(
            onTap: () => setState(() => _restrictions = r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.hiit.withOpacity(0.2) : AppColors.card2,
                border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(r, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.hiit : AppColors.textDim)),
            ),
          );
        }).toList()),
      ])),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _loading ? null : _generate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _loading ? AppColors.card : AppColors.hiit, borderRadius: BorderRadius.circular(13)),
          child: Center(child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('GENERATE DIET PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
        ),
      ),
      if (_result != null) ...[
        const SizedBox(height: 12),
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI-GENERATED PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.hiit, letterSpacing: 3)),
          const SizedBox(height: 12),
          Text(_result!, style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.6)),
        ])),
      ],
    ]);
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  ChatMessage({required this.text, required this.isUser, this.isError = false});
}
