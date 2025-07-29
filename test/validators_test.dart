// EN LA RAÍZ DEL PROYECTO, "lib/test/validators_test.dart"

// Importa el paquete de pruebas de Flutter para escribir y ejecutar tests.
import 'package:flutter_test/flutter_test.dart';
// Importa las funciones de validación definidas en el archivo validators.dart.
import 'package:quejas/utils/validators.dart';

// Punto de entrada para las pruebas unitarias.
void main() {
  // Agrupa las pruebas relacionadas con la validación de la descripción.
  group('Validación de descripción', () {
    // Prueba que verifica si la función validarDescripcion retorna un mensaje de error
    // cuando se pasa una descripción vacía.
    test('Retorna error si la descripción está vacía', () {
      final resultado = validarDescripcion('');
      // Verifica que el resultado sea el mensaje de error esperado.
      expect(resultado, 'La descripción no puede estar vacía');
    });

    // Prueba que verifica si la función validarDescripcion retorna un mensaje de error
    // cuando la descripción tiene menos de 10 caracteres.
    test('Retorna error si la descripción es muy corta', () {
      final resultado = validarDescripcion('Muy corta');
      // Verifica que el resultado sea el mensaje de error esperado.
      expect(resultado, 'La descripción debe tener al menos 10 caracteres');
    });

    // Prueba que verifica si la función validarDescripcion retorna null
    // cuando la descripción es válida (cumple con los requisitos).
    test('Retorna null si la descripción es válida', () {
      final resultado = validarDescripcion('Esta es una descripción válida.');
      // Verifica que el resultado sea null, indicando que no hay errores.
      expect(resultado, null);
    });
  });
  // Agrupa las pruebas relacionadas con la validación de la categoría.
  group('Validación de categoría', () {
    // Prueba que verifica si la función validarCategoria retorna un mensaje de error
    // cuando se pasa una categoría vacía.
    test('Retorna error si la categoría está vacía', () {
      final resultado = validarCategoria('');
      // Verifica que el resultado sea el mensaje de error esperado.
      expect(resultado, 'Debes seleccionar una categoría');
    });

    // Prueba que verifica si la función validarCategoria retorna null
    // cuando se pasa una categoría válida.
    test('Retorna null si la categoría es válida', () {
      final resultado = validarCategoria('Docentes');
      // Verifica que el resultado sea null, indicando que no hay errores.
      expect(resultado, null);
    });
  });
}