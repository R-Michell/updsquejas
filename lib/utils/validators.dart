// lib/utils/validators.dart
// dentro del archivo UTILS

// Valida el campo de descripción de un formulario, asegurando que no esté vacío y tenga al menos 10 caracteres.
String? validarDescripcion(String? descripcion) {
  // Verifica si la descripción es nula o está vacía; si es así, retorna un mensaje de error.
  if (descripcion == null || descripcion.isEmpty) {
    return 'La descripción no puede estar vacía';
  }
  // Verifica si la descripción tiene menos de 10 caracteres; si es así, retorna un mensaje de error.
  if (descripcion.length < 10) {
    return 'La descripción debe tener al menos 10 caracteres';
  }
  // Retorna null si la descripción cumple con todos los requisitos (válida).
  return null;
}

// Valida el campo de categoría de un formulario, asegurando que no esté vacío.
String? validarCategoria(String? categoria) {
  // Verifica si la categoría es nula o está vacía; si es así, retorna un mensaje de error.
  if (categoria == null || categoria.isEmpty) {
    return 'Debes seleccionar una categoría';
  }
  // Retorna null si la categoría es válida (no vacía).
  return null;
}