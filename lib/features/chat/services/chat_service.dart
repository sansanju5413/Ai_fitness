import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../../profile/models/user_profile.dart';
import '../../session/models/workout_session.dart';
import '../models/chat_message.dart';

class ChatService extends BaseAiService {
  ChatService() : super(model: 'openai/gpt-4o-mini-2024-07-18');

  Future<String?> generatePersonalizedResponse({
    required String userQuery,
    required List<ChatMessage> history,
    UserProfile? profile,
    List<WorkoutSession>? recentSessions,
  }) async {
    final systemPrompt = _buildSystemPrompt(profile, recentSessions);
    
    // Constructing single string prompt for BaseAiService
    final fullPrompt = """
System: $systemPrompt

Previous Conversation:
${history.map((msg) => "${msg.role.name.toUpperCase()}: ${msg.text}").join('\n')}

User Query: $userQuery
""";

    return await generatePlainContent(fullPrompt);
  }

  String _buildSystemPrompt(UserProfile? profile, List<WorkoutSession>? recentSessions) {
    String prompt = "You are 'Aura', a professional AI Fitness & Nutrition Coach for the 'Ai Fitness' app. ";
    prompt += "Your tone is encouraging, scientific, and professional. ";
    
    prompt += "\n\nCORE RULE: You ONLY answer questions related to Gym, Fitness, Workouts, and Nutrition. ";
    prompt += "If the user asks anything outside of these topics (e.g., politics, coding, general news), politely decline and redirect them to their fitness journey.";

    if (profile != null) {
      prompt += "\n\nUser Profile Context:";
      prompt += "\n- Name: ${profile.basicInfo.fullName}";
      prompt += "\n- Fitness Level: ${profile.fitnessProfile.fitnessLevel}";
      prompt += "\n- Primary Goal: ${profile.fitnessProfile.primaryGoal}";
      prompt += "\n- Weight: ${profile.bodyMetrics.weight}kg, Height: ${profile.bodyMetrics.height}cm";
    }

    if (recentSessions != null && recentSessions.isNotEmpty) {
      prompt += "\n\nRecent Workout Context:";
      for (var session in recentSessions.take(3)) {
        prompt += "\n- ${session.startTime.toLocal().toString().split(' ')[0]}: ${session.workoutFocus} (${session.duration.inMinutes} mins)";
      }
    }

    prompt += "\n\nResponse Guidelines:";
    prompt += "\n1. BE CONCISE. Avoid long paragraphs. Use bullet points and bold text for readability.";
    prompt += "\n2. Use Markdown formatting (bold, lists, etc.) to make the output look professional.";
    prompt += "\n3. Directly answer the user's question without unnecessary filler.";
    prompt += "\n4. Provide actionable fitness/nutrition advice based on the user's data.";
    
    return prompt;
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});
