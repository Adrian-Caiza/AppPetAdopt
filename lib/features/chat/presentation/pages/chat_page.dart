import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; 
import '../../../../core/services/gemini_service.dart';
import '../../../../injection_container.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Obtenemos el servicio (que ahora mantiene la sesión viva)
  final GeminiService _geminiService = getIt<GeminiService>();
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Lista local para mostrar en la UI
  final List<Map<String, String>> _messages = []; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargamos el historial existente al iniciar
    _loadHistory();
  }

  void _loadHistory() {
    // Obtenemos el historial desde el servicio (si existe)
    final history = _geminiService.history;
    
    // Si la historia está vacía, mostramos el saludo inicial
    if (history.isEmpty) {
      _addMessage('bot', '¡Hola! 🐶🐱 Soy PetBot. ¿En qué puedo ayudarte hoy con tu mascota?');
    } else {
      // Si HAY historial, lo procesamos para mostrarlo
      for (var content in history) {
        // Extraemos el texto de las partes del mensaje
        final text = content.parts
            .whereType<TextPart>()
            .map((e) => e.text)
            .join();
        
        // Convertimos el rol de Gemini ('model') al rol de nuestra UI ('bot')
        final role = content.role == 'user' ? 'user' : 'bot';
        
        if (text.isNotEmpty) {
          _messages.add({'role': role, 'text': text});
        }
      }
      
      // Actualizamos la UI
      setState(() {}); 
      
      // Hacemos scroll al final para ver los últimos mensajes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  void _addMessage(String role, String text) {
    setState(() {
      _messages.add({'role': role, 'text': text});
    });
    // Scroll al final automáticamente con animación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _addMessage('user', text);
    setState(() => _isLoading = true);

    // Llamada a Gemini (el servicio se encarga de guardar el contexto)
    final response = await _geminiService.sendMessage(text);

    setState(() => _isLoading = false);
    _addMessage('bot', response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.teal),
            SizedBox(width: 8),
            Text('Asistente Veterinario'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: isUser 
                      ? Text(msg['text']!, style: const TextStyle(color: Colors.white))
                      : MarkdownBody(data: msg['text']!), // Renderiza negritas, listas, etc.
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _isLoading ? null : _sendMessage,
              mini: true,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}