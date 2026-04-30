import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketService _ticketService = TicketService();
  final TextEditingController _commentController = TextEditingController();

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    await _ticketService.agregarComentario(
      ticketId: widget.ticket.id,
      contenido: _commentController.text.trim(),
      esAdmin: false, // El usuario no es admin
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticket.titulo),
        backgroundColor: const Color(0xFF3B5998),
      ),
      body: Column(
        children: [
          // Información del Ticket
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: ListTile(
                title: const Text("Descripción"),
                subtitle: Text(widget.ticket.descripcion),
              ),
            ),
          ),
          const Divider(),
          // LISTA DE COMENTARIOS (MENSAJERÍA)
          Expanded(
            child: StreamBuilder<List<Comentario>>(
              stream: _ticketService.obtenerComentarios(widget.ticket.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final comentarios = snapshot.data!;
                return ListView.builder(
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final c = comentarios[index];
                    return Align(
                      alignment: c.esAdmin ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.esAdmin ? Colors.grey[300] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(c.contenido),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Entrada de texto para el chat
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: "Escribe un mensaje..."),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendComment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}