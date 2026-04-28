import 'package:flutter/material.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';

class DashboardWidget extends StatelessWidget {
  final List<Ticket> tickets;

  const DashboardWidget({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final total = tickets.length;
    final pendientes = tickets.where((t) => t.estado == 'pendiente').length;
    final enProceso = tickets.where((t) => t.estado == 'en_proceso').length;
    final resueltos = tickets.where((t) => t.estado == 'resuelto').length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resumen de Tickets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B5998),
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _buildCard('Pendientes', pendientes, total, Colors.orange),
              _buildCard('En Proceso', enProceso, total, Colors.blue),
              _buildCard('Resueltos', resueltos, total, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String label, int count, int total, Color color) {
    final double porcentaje = total > 0 ? count / total : 0;

    return Container(
      width: 150, // Definimos un ancho para que el Wrap se vea ordenado
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: porcentaje,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Text(
                '$count (${(porcentaje * 100).toInt()}%)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}