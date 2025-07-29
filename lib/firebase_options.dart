import 'package:firebase_core/firebase_core.dart'; // Importa el paquete principal de Firebase para inicializar la app

class DefaultFirebaseOptions { // Clase para definir las opciones de configuración de Firebase
  static FirebaseOptions get currentPlatform { // Método estático que retorna la configuración de Firebase
    return const FirebaseOptions( // Retorna un objeto FirebaseOptions con la configuración
      apiKey: 'AIzaSyDRe8-qcmEJxh1RawtMI_aR7VthR2oVtlE', // Clave de API para autenticar con Firebase
      authDomain: 'sistemaquejasupds.firebaseapp.com', // Dominio para autenticación de Firebase
      projectId: 'sistemaquejasupds', // Identificador único del proyecto en Firebase
      storageBucket: 'sistemaquejasupds.firebasestorage.app', // Bucket de almacenamiento en Firebase Storage
      messagingSenderId: '773201440443', // ID para Firebase Cloud Messaging
      appId: '1:773201440443:web:efc84ce9ed67277a8cc39e', // ID único de la aplicación web en Firebase
      measurementId: 'G-CNEWFHB6QM', // ID para Firebase Analytics
    );
  }
}