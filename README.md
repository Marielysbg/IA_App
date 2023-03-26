# IA_APP

Asistente conectado con OpenAI, con capacidad de enviar mensajes escritos o por voz.

## CONFIGURACIÓN DE API KEY

Por seguridad, openAI restringue la api key si ésta es expuesta en algun repositorio de GitHub, por lo tanto, hay que configurar la apikey en el proyecto.

Para configurar la api key:

- Obtener la api key en OpenAI
- Pegar la api key en la variable API_KEY del archivo ``lib\config\helpers\constants.dart``

## LEVANTAR PROYECTO

Este proyecto solo tiene los permisos configurados para el SO Android.

Para compilar la aplicación correr:

- Flutter pub get
- flutter run
