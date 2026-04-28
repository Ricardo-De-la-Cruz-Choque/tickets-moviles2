import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_moviles2/model/ticket_model.dart';
import 'package:proyecto_moviles2/model/usuario_model.dart';

void main() {
  //  Prueba 1: Validar Ticket incompleto (simulación de validación lógica)
  test('Ticket con título vacío debería ser inválido', () {
    final ticket = Ticket(
      id: '1',
      titulo: '',
      descripcion: 'Descripción',
      estado: 'pendiente',
      userId: 'u1',
      usuarioNombre: 'Helbert',
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
      prioridad: 'alta',
      categoria: 'general',
    );

    final esValido = ticket.titulo.trim().isNotEmpty;
    expect(esValido, false);
  });

  //  Prueba 2: Ticket cambia correctamente de estado y actualiza fecha
  test('Actualizar estado de ticket debería cambiar estado y fecha', () {
    final original = Ticket(
      id: 't1',
      titulo: 'Error en login',
      descripcion: 'Pantalla negra',
      estado: 'pendiente',
      userId: 'u2',
      usuarioNombre: 'Luis',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
      fechaActualizacion: DateTime.now().subtract(const Duration(days: 1)),
      prioridad: 'media',
      categoria: 'sistema',
    );

    final actualizado = Ticket(
      id: original.id,
      titulo: original.titulo,
      descripcion: original.descripcion,
      estado: 'cerrado',
      userId: original.userId,
      usuarioNombre: original.usuarioNombre,
      fechaCreacion: original.fechaCreacion,
      fechaActualizacion: DateTime.now(),
      prioridad: original.prioridad,
      categoria: original.categoria,
    );

    expect(actualizado.estado, isNot(equals(original.estado)));
    expect(actualizado.fechaActualizacion.isAfter(original.fechaActualizacion), true);
  });

  // Prueba 3: Validación de email en modelo Usuario
  test('Usuario con email inválido no debe pasar validación', () {
    final usuario = Usuario(
      id: 'u1',
      username: 'userx',
      email: 'correo-no-valido',
      nombreCompleto: 'Helbert CL',
      fechaCreacion: DateTime.now(),
      ultimoLogin: null,
      emailVerificado: false,
      rol: 'usuario',
    );

    final emailEsValido = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(usuario.email);

    expect(emailEsValido, false);
  });
}
