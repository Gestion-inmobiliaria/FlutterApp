// La clase `AppVectors` se utiliza para centralizar y organizar las rutas de los archivos vectoriales (SVG)
// que se usan en la aplicación. Esto facilita el mantenimiento y evita errores al escribir manualmente
// las rutas de los vectores en diferentes partes del código.

class AppVectors {
  // Define una constante basePath que contiene la ruta base donde se almacenan los archivos vectoriales.
  static const String basePath = 'assets/vectors/';

  // Define una constante format que especifica la extensión de los archivos vectoriales (en este caso, `.svg`).
  static const String format = '.svg';

  // Define una constante logo que representa la ruta completa del archivo vectorial llamado `logo.svg`,
  // ubicado en la carpeta `assets/vectors/`.
  static const String logo = '${basePath}logo$format';
}
