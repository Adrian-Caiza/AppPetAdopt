import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat; // Usamos ChatSession para manejar el historial automáticamente
  

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY no encontrada en .env');
    }

    _model = GenerativeModel(
      
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, 
      ),
      // CAMBIO 2: Inyectamos la personalidad como 'systemInstruction' nativa
      // (Esto evita el error de mandar dos mensajes de usuario seguidos)
      systemInstruction: Content.system(
        'Eres un asistente veterinario amable y experto llamado "PetBot". '
        'Ayudas a adoptantes con dudas sobre cuidado de mascotas. '
        'Tus respuestas son concisas, empáticas y usas emojis. '
        'Si la pregunta es sobre temas médicos graves, recomienda ir a un veterinario real.'
      ),
    );

    // CAMBIO 3: Iniciamos la sesión de chat
    _chat = _model.startChat();
  }

  Iterable<Content> get history => _chat.history;

  

  Future<String> sendMessage(String message) async {
    try {
      // Enviamos mensaje usando el objeto ChatSession
      // Esto maneja automáticamente el historial User -> Model -> User
      final response = await _chat.sendMessage(Content.text(message));
      
      return response.text ?? 'Lo siento, no pude procesar eso.';
    } catch (e) {
      return 'Error de conexión con IA: $e';
    }
  }
}