import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml para las fechas

class AdminTicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const AdminTicketDetailScreen({super.key, required this.ticket});

  @override
  _AdminTicketDetailScreenState createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  late TextEditingController _tituloController;
  final TextEditingController _mensajeController = TextEditingController();
  String _estado = '';
  String _prioridad = '';
  final TicketService _ticketService = TicketService();

  final primaryColor = const Color(0xFF3B5998);

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.ticket.titulo);
    _estado = widget.ticket.estado;
    _prioridad = widget.ticket.prioridad;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final actualizado = Ticket(
      id: widget.ticket.id,
      titulo: _tituloController.text.trim(),
      descripcion: widget.ticket.descripcion,
      estado: _estado,
      prioridad: _prioridad,
      categoria: widget.ticket.categoria,
      userId: widget.ticket.userId,
      usuarioNombre: widget.ticket.usuarioNombre,
      fechaCreacion: widget.ticket.fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );

    await _ticketService.actualizarTicket(actualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket actualizado correctamente')),
    );
  }

  void _enviarRespuesta() async {
    if (_mensajeController.text.trim().isEmpty) return;

    try {
      await _ticketService.agregarComentario(
        ticketId: widget.ticket.id,
        contenido: _mensajeController.text.trim(),
        esAdmin: true,
      );
      _mensajeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text('Ticket: ${widget.ticket.usuarioNombre}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
          )
        ],
      ),
      body: Column(
        children: [
          // SECCIÓN DE EDICIÓN (Colapsable o pequeña)
          ExpansionTile(
            title: const Text("Detalles y Configuración", style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInputField(controller: _tituloController, label: 'Título'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Estado',
                            value: _estado,
                            items: ['pendiente', 'en_proceso', 'resuelto'],
                            onChanged: (val) => setState(() => _estado = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Prioridad',
                            value: _prioridad,
                            items: ['baja', 'media', 'alta'],
                            onChanged: (val) => setState(() => _prioridad = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // SECCIÓN DE MENSAJES (CHAT)
          Expanded(
            child: StreamBuilder<List<Comentario>>(
              stream: _ticketService.obtenerComentarios(widget.ticket.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay mensajes aún."));
                }

                final comentarios = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final c = comentarios[index];
                    return _buildChatBubble(c);
                  },
                );
              },
            ),
          ),

          // CAMPO DE TEXTO PARA RESPONDER
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Comentario c) {
    final bool soyAdmin = c.esAdmin;
    return Align(
      alignment: soyAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: soyAdmin ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomRight: soyAdmin ? Radius.zero : const Radius.circular(15),
            bottomLeft: !soyAdmin ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.contenido,
              style: TextStyle(color: soyAdmin ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(c.fecha),
              style: TextStyle(
                fontSize: 10,
                color: soyAdmin ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensajeController,
              decoration: InputDecoration(
                hintText: "Escribir respuesta...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: primaryColor),
            onPressed: _enviarRespuesta,
          ),
        ],
      ),
    );
  }

  // WIDGETS DE APOYO
  Widget _buildInputField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
      onChanged: onChanged,
    );
  }
}