import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  // Historial de chat para mantener el contexto
  final List<Content> _chatHistory = [];

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY no encontrada en .env');
    }

    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Creatividad equilibrada
      ),
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      // Prompt del sistema para darle personalidad
      const systemPrompt = 
          'Eres un asistente veterinario amable y experto llamado "PetBot". '
          'Ayudas a adoptantes con dudas sobre cuidado de mascotas. '
          'Tus respuestas son concisas, empáticas y usas emojis. '
          'Si la pregunta es sobre temas médicos graves, recomienda ir a un veterinario real.';

      // Preparamos el historial si es la primera vez
      if (_chatHistory.isEmpty) {
        _chatHistory.add(Content.text(systemPrompt));
      }

      // Agregamos mensaje del usuario
      _chatHistory.add(Content.text(message));

      // Enviamos a Gemini
      final response = await _model.generateContent(_chatHistory);
      final responseText = response.text ?? 'Lo siento, no pude procesar eso.';

      // Agregamos respuesta de la IA al historial
      _chatHistory.add(Content.model([TextPart(responseText)]));

      return responseText;
    } catch (e) {
      return 'Error de conexión con IA: $e';
    }
  }
}