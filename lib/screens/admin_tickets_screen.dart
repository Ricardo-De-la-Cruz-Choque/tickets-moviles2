import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/services/ticket_service.dart';
import 'package:proyecto_moviles2/services/auth_service.dart';
import 'package:proyecto_moviles2/screens/login_screen.dart';
import 'package:proyecto_moviles2/screens/admin_ticket_detail_screen.dart';
import 'package:proyecto_moviles2/screens/admin_users_screen.dart';
import 'package:proyecto_moviles2/widgets/dashboard_widget.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  _AdminTicketsScreenState createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'todos';

  late Stream<List<Ticket>> _ticketsStream;

  @override
  void initState() {
    super.initState();
    // 2. Inicializamos el stream al cargar la pantalla
    _updateStream();
  }

  void _updateStream() {
    setState(() {
      _ticketsStream = _filterStatus == 'todos'
          ? TicketService().obtenerTodosLosTickets()
          : TicketService().obtenerTicketsPorEstado(_filterStatus);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.amber.shade700;
      case 'en_proceso':
        return Colors.blueAccent;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

 @override
  Widget build(BuildContext context) {
    // Definición de colores consistentes
    const primaryColor = Color(0xFF3B5998);
    const buttonColor = Color(0xFF4267B2);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Administrador de Tickets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // SECCIÓN DE FILTROS Y BÚSQUEDA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Filtrar:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    // Dropdown para estados
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['todos', 'pendiente', 'en_proceso', 'resuelto']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.toUpperCase(),
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _filterStatus = value;
                              _updateStream(); // Actualizamos el Stream en el estado
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón de Usuarios
                    ElevatedButton.icon(
                      icon: const Icon(Icons.group, size: 18),
                      label: const Text('Usuarios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AdminUsersScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Campo de Búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o usuario...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  }),
                ),
              ],
            ),
          ),

          // LISTADO DE TICKETS CON STREAMBUILDER
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _buildTicketsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList() {
    // IMPORTANTE: Se usa la variable _ticketsStream del estado para evitar parpadeos
    return StreamBuilder<List<Ticket>>(
      stream: _ticketsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay tickets disponibles'));
        }

        final tickets = snapshot.data!;
        
        // Filtrado por texto (búsqueda local)
        final filteredTickets = tickets.where((ticket) {
          final titulo = ticket.titulo.toLowerCase();
          final nombre = ticket.usuarioNombre.toLowerCase();
          final descripcion = ticket.descripcion.toLowerCase();
          return titulo.contains(_searchQuery) ||
              nombre.contains(_searchQuery) ||
              descripcion.contains(_searchQuery);
        }).toList();

        if (filteredTickets.isEmpty) {
          return const Center(
            child: Text('No hay resultados para tu búsqueda'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          itemCount: (_filterStatus == 'todos' ? 1 : 0) + filteredTickets.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Colors.grey,
            indent: 12,
            endIndent: 12,
          ),
          itemBuilder: (context, index) {
            if (_filterStatus == 'todos' && index == 0) {
              return DashboardWidget(tickets: tickets);
            }

            final ticket = filteredTickets[_filterStatus == 'todos' ? index - 1 : index];

            return Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                // --- CAMBIO AQUÍ: Ahora toda la tarjeta es cliqueable ---
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminTicketDetailScreen(ticket: ticket),
                    ),
                  );
                },
                // -------------------------------------------------------
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(ticket.estado),
                  child: const Icon(
                    Icons.receipt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                title: Text(
                  ticket.titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ticket.usuarioNombre,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ticket.estado).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.estado.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(ticket.estado),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.priority_high, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            ticket.prioridad,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.descripcion,
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF3B5998)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminTicketDetailScreen(ticket: ticket),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmarEliminar(ticket),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmarEliminar(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('¿Eliminar Ticket?'),
        content: Text('¿Estás seguro de que deseas eliminar el ticket "${ticket.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await TicketService().eliminarTicket(ticket.id);
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket eliminado correctamente')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
