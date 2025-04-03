// Esta clase `AppImages` se utiliza para centralizar y organizar las rutas de las imágenes
// que se usan en la aplicación. Esto facilita el mantenimiento y evita errores
// al escribir manualmente las rutas de las imágenes en diferentes partes del código.

class AppImages {
  // Define una constante basePath que contiene la ruta base donde se almacenan las imágenes.
  static const String basePath = 'assets/images/';

  // Define una constante IntroBG que representa la ruta completa de la imagen de fondo
  // llamada `intro_bg.png`, ubicada en la carpeta `assets/images/`.
  static const String IntroBG = '${basePath}intro_bg.png';
}
