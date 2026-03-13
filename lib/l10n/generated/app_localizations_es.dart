// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ComuniApp';

  @override
  String hello(String name) {
    return 'Hola, $name';
  }

  @override
  String get userFallback => 'Usuario';

  @override
  String get navHome => 'Home';

  @override
  String get navBoard => 'Tablón';

  @override
  String get navBookings => 'Reservas';

  @override
  String get navIncidents => 'Incidencias';

  @override
  String get navDocs => 'Docs';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get rolePresident => 'Presidente';

  @override
  String get roleNeighbor => 'Vecino';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginError => 'Error de inicio de sesión';

  @override
  String get unexpectedError => 'Error inesperado';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get communityManagement => 'Gestión de Comunidades';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get thePassword => 'La contraseña';

  @override
  String get hasInvitation => '¿Tienes una invitación? Regístrate aquí';

  @override
  String get splashTitle => 'ComuniApp';

  @override
  String get registerTitle => 'Registro con Invitación';

  @override
  String get enterInvitationToken => 'Introduce el token de invitación';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get registrationComplete => '¡Registro Completado!';

  @override
  String accountCreatedMessage(String email, String dwelling) {
    return 'Tu cuenta ha sido creada exitosamente.\n\nEmail: $email\nVivienda: $dwelling\n\nYa puedes iniciar sesión en la app.';
  }

  @override
  String get goToLogin => 'Ir al Login';

  @override
  String get registrationError => 'Error al registrar';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get haveInvitation => '¿Tienes una invitación?';

  @override
  String get invitationExplanation =>
      'Si el administrador de tu comunidad te ha invitado, habrás recibido un código de invitación.\n\nIntrodúcelo a continuación para verificar tu identidad y crear tu cuenta.';

  @override
  String get invitationTokenLabel => 'Token de invitación';

  @override
  String get invitationTokenHint => 'Pega aquí tu código de invitación';

  @override
  String get verifyInvitation => 'Verificar Invitación';

  @override
  String get validInvitation => 'Invitación Válida';

  @override
  String get nameLabel => 'Nombre:';

  @override
  String get emailLabel => 'Email:';

  @override
  String get dwellingLabel => 'Vivienda:';

  @override
  String get roleLabel => 'Rol:';

  @override
  String get choosePassword => 'Elige tu contraseña';

  @override
  String get minChars => 'Mínimo 8 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get completeRegistration => 'Completar Registro';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get emailField => 'Correo electrónico';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phone => 'Teléfono';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get dwelling => 'Vivienda';

  @override
  String get role => 'Rol';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get profileEditHint =>
      'Para modificar tus datos, pulsa el icono de edición. Se enviará una solicitud al administrador para su aprobación.';

  @override
  String get logout => 'Cerrar sesion';

  @override
  String get logoutConfirm => '¿Estas seguro de que quieres cerrar sesion?';

  @override
  String requestChange(String fieldName) {
    return 'Solicitar cambio de $fieldName';
  }

  @override
  String currentValue(String value) {
    return 'Valor actual: $value';
  }

  @override
  String get newDesiredValue => 'Nuevo valor deseado';

  @override
  String get changeRequestNote =>
      'Se enviará una solicitud al administrador para su revisión.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String changeRequestSent(String fieldName) {
    return 'Solicitud de cambio de $fieldName enviada correctamente';
  }

  @override
  String get changeRequestError => 'Error al enviar solicitud';

  @override
  String get active => 'Activa';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get activitySummary => 'Resumen de actividad';

  @override
  String get bookings => 'Reservas';

  @override
  String get incidents => 'Incidencias';

  @override
  String get board => 'Tablón';

  @override
  String get documents => 'Documentos';

  @override
  String get invitations => 'Invitaciones';

  @override
  String get importData => 'Importar datos';

  @override
  String get publications => 'Publicaciones';

  @override
  String get openIncidents => 'Incidencias abiertas';

  @override
  String get loadPostsError => 'Error al cargar publicaciones';

  @override
  String get boardTitle => 'Tablón';

  @override
  String get noPosts => 'No hay publicaciones';

  @override
  String get postsWillAppear =>
      'Las publicaciones de la comunidad aparecerán aquí';

  @override
  String get deletePost => 'Eliminar publicación';

  @override
  String get deletePostConfirm =>
      '¿Seguro que quieres eliminar esta publicación?';

  @override
  String get delete => 'Eliminar';

  @override
  String get publish => 'Publicar';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get title => 'Título';

  @override
  String get content => 'Contenido';

  @override
  String get completeTitleContent => 'Completa título y contenido';

  @override
  String get announcementDetail => 'Detalle del anuncio';

  @override
  String get loadAnnouncementError => 'Error al cargar el anuncio';

  @override
  String get retry => 'Reintentar';

  @override
  String get published => 'Publicado';

  @override
  String get updated => 'Actualizado';

  @override
  String get loadBookingsError => 'Error al cargar reservas';

  @override
  String get noBookings => 'No hay reservas';

  @override
  String get cancelBooking => 'Cancelar reserva';

  @override
  String cancelBookingConfirm(String zoneName) {
    return '¿Seguro que quieres cancelar la reserva de $zoneName?';
  }

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get reasonExample => 'Ej: Cambio de planes';

  @override
  String get back => 'Volver';

  @override
  String get bookingCancelled => 'Reserva cancelada';

  @override
  String get bookingsTitle => 'Reservas';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusCompleted => 'Completada';

  @override
  String get statusInProgress => 'En curso';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get zone => 'Zona';

  @override
  String get cancelBookingTooltip => 'Cancelar reserva';

  @override
  String reason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get zoneTypePool => 'Piscina';

  @override
  String get zoneTypeCourt => 'Pista deportiva';

  @override
  String get zoneTypeGym => 'Gimnasio';

  @override
  String get zoneTypeRoom => 'Salón / Sala';

  @override
  String get zoneTypePlayground => 'Zona infantil';

  @override
  String get zoneTypeBbq => 'Barbacoa';

  @override
  String get zoneRequired => 'Zona requerida';

  @override
  String get selectZone => 'Selecciona una zona para reservar.';

  @override
  String get datesRequired => 'Fechas requeridas';

  @override
  String get selectDates => 'Selecciona fecha de inicio y fin.';

  @override
  String get invalidDates => 'Fechas inválidas';

  @override
  String get endAfterStart => 'La fecha de fin debe ser posterior al inicio.';

  @override
  String get createBookingError => 'Error al crear reserva';

  @override
  String get bookingCreated => 'Reserva creada correctamente';

  @override
  String get error => 'Error';

  @override
  String get newBooking => 'Nueva Reserva';

  @override
  String get noZonesAvailable => 'No hay zonas disponibles';

  @override
  String get adminMustCreateZones =>
      'El administrador debe crear zonas primero';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get notesExample => 'Ej: Reserva para cumpleaños';

  @override
  String get creating => 'Creando...';

  @override
  String get createBooking => 'Crear reserva';

  @override
  String get tapToSelect => 'pulsa para seleccionar';

  @override
  String get loadIncidentsError => 'Error al cargar incidentes';

  @override
  String get noIncidents => 'No hay incidencias';

  @override
  String get deleteIncident => 'Eliminar incidencia';

  @override
  String get deleteIncidentConfirm =>
      '¿Seguro que quieres eliminar esta incidencia?';

  @override
  String get incidentsTitle => 'Incidencias';

  @override
  String get newIncidentDialog => 'Nueva Incidencia';

  @override
  String get description => 'Descripción';

  @override
  String get locationOptional => 'Ubicación (opcional)';

  @override
  String get locationExample => 'Ej: Edificio A, Piso 3';

  @override
  String get priority => 'Prioridad';

  @override
  String get priorityLow => 'Baja';

  @override
  String get priorityMedium => 'Media';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityCritical => 'Urgente';

  @override
  String get priorityLowEmoji => 'Baja';

  @override
  String get priorityMediumEmoji => 'Media';

  @override
  String get priorityHighEmoji => 'Alta';

  @override
  String get completeTitleDescription => 'Completa título y descripción';

  @override
  String get create => 'Crear';

  @override
  String get statusOpen => 'Abierta';

  @override
  String get statusInProgressLabel => 'En progreso';

  @override
  String get statusResolved => 'Resuelta';

  @override
  String get statusClosed => 'Cerrada';

  @override
  String get incidentDetail => 'Detalle de incidencia';

  @override
  String get loadIncidentError => 'Error al cargar la incidencia';

  @override
  String get reportedBy => 'Reportado por';

  @override
  String get location => 'Ubicación';

  @override
  String get assignedTo => 'Asignado a';

  @override
  String get created => 'Creada';

  @override
  String get actions => 'Acciones';

  @override
  String get inProgress => 'En progreso';

  @override
  String get resolve => 'Resolver';

  @override
  String get close => 'Cerrar';

  @override
  String get statusUpdated => 'Estado actualizado';

  @override
  String get newIncidentTitle => 'Nueva incidencia';

  @override
  String get describeProblem => 'Describe brevemente el problema';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get detailProblem =>
      'Detalla el problema con toda la información posible';

  @override
  String get descriptionRequired => 'La descripción es obligatoria';

  @override
  String get locationExampleLong => 'Ej: Portal 3, planta 2 / Piscina / Garaje';

  @override
  String get submitIncident => 'Enviar incidencia';

  @override
  String get incidentCreated => 'Incidencia creada correctamente';

  @override
  String get loadDocsError => 'Error al cargar documentos';

  @override
  String get noDocuments => 'No hay documentos';

  @override
  String get noDocsInCategory =>
      'No se encontraron documentos en esta categoría';

  @override
  String get docsWillAppear => 'Los documentos de la comunidad aparecerán aquí';

  @override
  String get deleteDocument => 'Eliminar documento';

  @override
  String get deleteDocConfirm => '¿Seguro que quieres eliminar este documento?';

  @override
  String get documentsTitle => 'Documentos';

  @override
  String get catAll => 'Todos';

  @override
  String get catMinutes => 'Actas';

  @override
  String get catRegulations => 'Normativas';

  @override
  String get catInvoices => 'Facturas';

  @override
  String get catMisc => 'Varios';

  @override
  String get catDocuments => 'Documentos';

  @override
  String get downloadDocument => 'Descargar documento';

  @override
  String get uploadDocument => 'Subir Documento';

  @override
  String get fileUrl => 'URL del archivo';

  @override
  String get fileUrlHint => 'https://...';

  @override
  String get fileType => 'Tipo de archivo';

  @override
  String get fileTypePdf => 'PDF';

  @override
  String get fileTypeWord => 'Word';

  @override
  String get fileTypeExcel => 'Excel';

  @override
  String get fileTypeImage => 'Imagen';

  @override
  String get fileTypeOther => 'Otro';

  @override
  String get category => 'Categoría';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get completeTitleUrl => 'Completa título y URL';

  @override
  String get upload => 'Subir';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get allMarkedRead => 'Todas marcadas como leídas';

  @override
  String get markReadError => 'Error al marcar notificaciones';

  @override
  String get markAllRead => 'Marcar todo como leído';

  @override
  String get deleteNotifications => 'Eliminar notificaciones';

  @override
  String get deleteAllNotificationsConfirm =>
      '¿Deseas eliminar todas las notificaciones?';

  @override
  String get deleteAll => 'Eliminar todas';

  @override
  String get noNotifications => 'No tienes notificaciones';

  @override
  String get timeNow => 'Ahora';

  @override
  String timeMinAgo(int count) {
    return 'Hace $count min';
  }

  @override
  String timeHourAgo(int count) {
    return 'Hace $count h';
  }

  @override
  String get timeYesterday => 'Ayer';

  @override
  String timeDaysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get calendar => 'Calendario';

  @override
  String get goToToday => 'Ir a hoy';

  @override
  String get noEvents => 'No hay eventos';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get dayMon => 'L';

  @override
  String get dayTue => 'M';

  @override
  String get dayWed => 'X';

  @override
  String get dayThu => 'J';

  @override
  String get dayFri => 'V';

  @override
  String get daySat => 'S';

  @override
  String get daySun => 'D';

  @override
  String get dayMonFull => 'Lunes';

  @override
  String get dayTueFull => 'Martes';

  @override
  String get dayWedFull => 'Miércoles';

  @override
  String get dayThuFull => 'Jueves';

  @override
  String get dayFriFull => 'Viernes';

  @override
  String get daySatFull => 'Sábado';

  @override
  String get daySunFull => 'Domingo';

  @override
  String get monthJanuaryLower => 'enero';

  @override
  String get monthFebruaryLower => 'febrero';

  @override
  String get monthMarchLower => 'marzo';

  @override
  String get monthAprilLower => 'abril';

  @override
  String get monthMayLower => 'mayo';

  @override
  String get monthJuneLower => 'junio';

  @override
  String get monthJulyLower => 'julio';

  @override
  String get monthAugustLower => 'agosto';

  @override
  String get monthSeptemberLower => 'septiembre';

  @override
  String get monthOctoberLower => 'octubre';

  @override
  String get monthNovemberLower => 'noviembre';

  @override
  String get monthDecemberLower => 'diciembre';

  @override
  String get importTitle => 'Importar datos';

  @override
  String get importDescription =>
      'Importa vecinos, presidentes, miembros de junta, inquilinos y zonas comunes desde un archivo Excel (.xlsx) o CSV. La primera fila debe contener las cabeceras.';

  @override
  String get importUsers => 'Importar usuarios';

  @override
  String get importUsersSubtitle =>
      'Vecinos, presidentes, junta directiva, inquilinos';

  @override
  String get colEmail => 'email (obligatorio)';

  @override
  String get colName => 'nombre (obligatorio)';

  @override
  String get colRole => 'rol (ADMIN/PRESIDENT/NEIGHBOR)';

  @override
  String get colPhone => 'telefono (opcional)';

  @override
  String get colDwelling => 'vivienda (opcional)';

  @override
  String get colPassword => 'password (opcional, por defecto: ComuniApp2024)';

  @override
  String get importZones => 'Importar zonas comunes';

  @override
  String get importZonesSubtitle =>
      'Piscina, pista de pádel, sala, gimnasio...';

  @override
  String get colZoneName => 'nombre (obligatorio)';

  @override
  String get colZoneType => 'tipo (obligatorio: pool/court/room/gym/garden)';

  @override
  String get colZoneDesc => 'descripcion (opcional)';

  @override
  String get colZoneCapacity => 'capacidad (opcional, número)';

  @override
  String get colZoneApproval => 'requiere_aprobacion (opcional: si/no)';

  @override
  String get importResult => 'Resultado de la importación';

  @override
  String get fileReadError => 'Error al leer el archivo';

  @override
  String get serverError => 'Error del servidor';

  @override
  String get expectedColumns => 'Columnas esperadas:';

  @override
  String get importing => 'Importando...';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado';

  @override
  String get fileSelected => 'Archivo seleccionado';

  @override
  String get fileTooLarge => 'El archivo no puede superar 10 MB';

  @override
  String get completeTitleFile => 'Selecciona un archivo e indica el título';

  @override
  String get uploadSuccess => 'Documento subido correctamente';

  @override
  String get uploadError => 'Error al subir el documento';

  @override
  String get maxFileSize => 'Máx. 10 MB — PDF, Word, Excel, imágenes';

  @override
  String get tapToSelectFile => 'Toca para seleccionar un archivo';

  @override
  String get changeFile => 'Cambiar archivo';

  @override
  String get totalRows => 'Total filas';

  @override
  String get imported => 'Importados';

  @override
  String get errors => 'Errores';

  @override
  String get errorDetails => 'Detalle de errores:';

  @override
  String get invitationsManagement => 'Gestión de Invitaciones';

  @override
  String get emailAndNameRequired => 'Email y nombre son obligatorios';

  @override
  String get loadInvitationsError => 'Error al cargar invitaciones';

  @override
  String get invitationCreated => 'Invitación creada';

  @override
  String invitationFor(String name) {
    return 'Invitación para $name creada correctamente.';
  }

  @override
  String get registrationToken => 'Token de registro:';

  @override
  String get shareTokenHint =>
      'Comparte este token con el vecino para que pueda registrarse.';

  @override
  String get tokenCopied => 'Token copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get accept => 'Aceptar';

  @override
  String get revokeInvitation => 'Revocar invitación';

  @override
  String get revokeInvitationConfirm =>
      '¿Seguro que quieres eliminar esta invitación?';

  @override
  String get invitationDeleted => 'Invitación eliminada';

  @override
  String get noAccess => 'Sin acceso';

  @override
  String get noAccessMessage =>
      'Solo administradores o presidentes pueden acceder.';

  @override
  String get newInvitation => 'Nueva invitación';

  @override
  String get emailRequired => 'Email *';

  @override
  String get fullNameRequired => 'Nombre completo *';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get dwellingOptional => 'Vivienda (opcional)';

  @override
  String get dwellingExample => 'Ej: Bloque A - 3ºB';

  @override
  String get creatingInvitation => 'Creando...';

  @override
  String get createInvitation => 'Crear invitación';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get step1 => 'Rellena los datos y crea la invitación';

  @override
  String get step2 => 'Comparte el token generado con el vecino';

  @override
  String get step3 => 'El vecino introduce el token en la pantalla de registro';

  @override
  String get step4 => 'Crea su contraseña y ya tiene acceso a la app';

  @override
  String get noInvitationsYet => 'No hay invitaciones aún';

  @override
  String get invitationsSection => 'Invitaciones';

  @override
  String get statusUsed => 'USADA';

  @override
  String get statusExpired => 'EXPIRADA';

  @override
  String get statusPendingUpper => 'PENDIENTE';

  @override
  String get statusApprovedUpper => 'APROBADA';

  @override
  String token(String token) {
    return 'Token: $token';
  }

  @override
  String get copyToken => 'Copiar token';

  @override
  String get tokenCopiedShort => 'Token copiado';

  @override
  String get revoke => 'Revocar';

  @override
  String get errorConnection =>
      'No se pudo conectar al servidor. Verifica tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorInvalidCredentials =>
      'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo de nuevo.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha expirado. Inicia sesión de nuevo.';

  @override
  String get errorForbidden => 'No tienes permiso para realizar esta acción.';

  @override
  String get errorNotFound => 'El recurso solicitado no se ha encontrado.';

  @override
  String get errorDuplicate =>
      'Ya existe un registro con estos datos. Verifica la información.';

  @override
  String get errorBookingConflict =>
      'Ya hay una reserva en ese horario. Elige otro horario.';

  @override
  String get errorValidation =>
      'Los datos ingresados no son válidos. Revisa la información.';

  @override
  String get errorServer =>
      'El servidor está experimentando problemas. Inténtalo más tarde.';

  @override
  String get errorUnexpectedResponse =>
      'Se recibió una respuesta inesperada del servidor. Inténtalo de nuevo.';

  @override
  String get errorGeneric =>
      'Ha ocurrido un error inesperado. Inténtalo de nuevo.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get noConnectionOffline =>
      'Sin conexión. Algunos datos pueden no estar actualizados.';

  @override
  String deleteItem(String itemName) {
    return 'Eliminar $itemName';
  }

  @override
  String get deleteItemConfirm =>
      '¿Estás seguro de que quieres eliminar este elemento? Esta acción no se puede deshacer.';

  @override
  String get loading => 'Cargando...';

  @override
  String get emptyBookings => 'Sin reservas';

  @override
  String get emptyBookingsDesc =>
      'No tienes reservas activas. Reserva un espacio común para comenzar.';

  @override
  String get emptyBookingsAction => 'Nueva reserva';

  @override
  String get emptyIncidents => 'Todo en orden';

  @override
  String get emptyIncidentsDesc => 'No hay incidencias reportadas. ¡Excelente!';

  @override
  String get emptyIncidentsAction => 'Reportar incidencia';

  @override
  String get emptyDocuments => 'Sin documentos';

  @override
  String get emptyDocumentsDesc =>
      'No hay documentos disponibles en este momento.';

  @override
  String get emptyPosts => 'Sin publicaciones';

  @override
  String get emptyPostsDesc => 'No hay publicaciones en el tablón todavía.';

  @override
  String get emptyPostsAction => 'Nueva publicación';

  @override
  String get emptySearch => 'Sin resultados';

  @override
  String get emptySearchDesc =>
      'No se encontraron resultados para tu búsqueda.';

  @override
  String get errorState => 'Algo salió mal';

  @override
  String get errorStateDesc =>
      'No pudimos cargar la información. Por favor, inténtalo de nuevo.';

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get noConnectionDesc =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get validatorEmailRequired => 'El correo electrónico es obligatorio';

  @override
  String get validatorEmailInvalid =>
      'Por favor, introduce un correo electrónico válido';

  @override
  String get validatorPasswordRequired => 'La contraseña es obligatoria';

  @override
  String validatorPasswordMinLength(int minLength) {
    return 'La contraseña debe tener al menos $minLength caracteres';
  }

  @override
  String get validatorPasswordMinLength8 =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get validatorPasswordUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get validatorPasswordLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get validatorPasswordNumber =>
      'La contraseña debe contener al menos un número';

  @override
  String get validatorConfirmPassword => 'Por favor, confirma tu contraseña';

  @override
  String validatorFieldRequired(String fieldName) {
    return '$fieldName es obligatorio';
  }

  @override
  String validatorFieldMinLength(String fieldName, int minLength) {
    return '$fieldName debe tener al menos $minLength caracteres';
  }

  @override
  String validatorFieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName no puede exceder $maxLength caracteres';
  }

  @override
  String get validatorPhoneRequired => 'El teléfono es obligatorio';

  @override
  String get validatorPhoneInvalid =>
      'Por favor, introduce un número de teléfono válido (ej: 612345678)';

  @override
  String validatorNumericRequired(String fieldName) {
    return '$fieldName es obligatorio';
  }

  @override
  String validatorNumericInvalid(String fieldName) {
    return '$fieldName debe ser un número válido';
  }

  @override
  String validatorNumberRange(String fieldName, int min, int max) {
    return '$fieldName debe estar entre $min y $max';
  }

  @override
  String validatorDateRequired(String fieldName) {
    return '$fieldName es obligatoria';
  }

  @override
  String validatorDateFuture(String fieldName) {
    return '$fieldName debe ser futura';
  }

  @override
  String get validatorUrlRequired => 'La URL es obligatoria';

  @override
  String get validatorUrlInvalid => 'Por favor, introduce una URL válida';

  @override
  String get validatorPostalCodeRequired => 'El código postal es obligatorio';

  @override
  String get validatorPostalCodeInvalid =>
      'Por favor, introduce un código postal válido (5 dígitos)';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportUsers => 'Usuarios';

  @override
  String get exportBookings => 'Reservas';

  @override
  String get exportIncidents => 'Incidencias';

  @override
  String get exportDocuments => 'Documentos';

  @override
  String get exportZones => 'Zonas';

  @override
  String get exportDownloading => 'Descargando...';

  @override
  String get exportSuccess => 'Exportación descargada correctamente';

  @override
  String get exportError => 'Error al exportar datos';

  @override
  String get exportWebOnly =>
      'La descarga directa está disponible solo en la versión web';

  @override
  String get exportDescription =>
      'Descarga los datos de tu comunidad en formato CSV o PDF';

  @override
  String get downloadCsv => 'Descargar CSV';

  @override
  String get downloadPdf => 'Descargar PDF';

  @override
  String get requestTimeout =>
      'La petición ha tardado demasiado. Inténtalo de nuevo';

  @override
  String pdfExportTitle(String resource) {
    return 'Informe $resource';
  }

  @override
  String get status => 'Estado';

  @override
  String get startTime => 'Inicio';

  @override
  String get endTime => 'Fin';

  @override
  String get notes => 'Notas';

  @override
  String get createdAt => 'Creado';

  @override
  String get uploadedBy => 'Subido por';

  @override
  String get userName => 'Usuario';

  @override
  String get budget => 'Presupuesto';

  @override
  String get budgetTitle => 'Presupuesto comunitario';

  @override
  String get budgetSubtitle => 'Transparencia económica de tu comunidad';

  @override
  String get budgetTotalIncome => 'Total ingresos';

  @override
  String get budgetTotalExpense => 'Total gastos';

  @override
  String get budgetBalance => 'Balance';

  @override
  String get budgetEntries => 'Movimientos';

  @override
  String get budgetNoData => 'Sin datos para este año';

  @override
  String get budgetUploadCsv => 'Importar CSV';

  @override
  String budgetUploadSuccess(int count) {
    return 'Importados $count registros correctamente';
  }

  @override
  String budgetUploadError(String error) {
    return 'Error al importar: $error';
  }

  @override
  String budgetUploadErrors(int imported, int total, int count) {
    return 'Se importaron $imported de $total filas. Errores: $count';
  }

  @override
  String get budgetDeleteEntry => 'Eliminar partida';

  @override
  String get budgetDeleteConfirm => '¿Eliminar esta partida presupuestaria?';

  @override
  String get budgetDeleteSuccess => 'Partida eliminada';

  @override
  String get budgetPieTitle => 'Distribución de gastos';

  @override
  String get budgetBarTitle => 'Evolución mensual';

  @override
  String get budgetIncome => 'Ingresos';

  @override
  String get budgetExpense => 'Gastos';

  @override
  String get budgetSelectYear => 'Año';

  @override
  String get budgetCategory => 'Categoría';

  @override
  String get budgetConcept => 'Concepto';

  @override
  String get budgetAmount => 'Importe';

  @override
  String get budgetType => 'Tipo';

  @override
  String get budgetProvider => 'Proveedor';

  @override
  String get budgetDetail => 'Detalle';

  @override
  String get budgetDate => 'Fecha';

  @override
  String get budgetAllEntries => 'Todas las partidas';

  @override
  String get budgetFilterAll => 'Todas';

  @override
  String get budgetFilterIncome => 'Ingresos';

  @override
  String get budgetFilterExpense => 'Gastos';

  @override
  String get budgetNoPieData => 'Sin gastos este año';

  @override
  String get budgetDeleteAll => 'Borrar todo';

  @override
  String get budgetDeleteAllConfirm =>
      '¿Eliminar todas las partidas de este año? Esta acción no se puede deshacer.';

  @override
  String get navBudget => 'Presupuesto';

  @override
  String get allZones => 'Todas';

  @override
  String get filterByZone => 'Filtrar por zona';

  @override
  String get myBookings => 'Mis reservas';

  @override
  String get allStatuses => 'Todos';

  @override
  String get allPriorities => 'Todas';

  @override
  String get filterByStatus => 'Filtrar por estado';

  @override
  String get filterByPriority => 'Filtrar por prioridad';

  @override
  String get myIncidents => 'Mis incidencias';

  @override
  String get writeComment => 'Escribe un comentario...';

  @override
  String get send => 'Enviar';

  @override
  String get comments => 'Comentarios';

  @override
  String get noComments => 'Sin comentarios aún';

  @override
  String get commentAdded => 'Comentario añadido';

  @override
  String get deleteComment => 'Eliminar comentario';

  @override
  String get deleteCommentConfirm => '¿Eliminar este comentario?';

  @override
  String get like => 'Me gusta';

  @override
  String get unlike => 'Ya no me gusta';

  @override
  String get likes => 'Me gusta';

  @override
  String get errorToggleLike => 'Error al dar me gusta. Inténtalo de nuevo.';

  @override
  String get errorAddComment =>
      'Error al añadir comentario. Inténtalo de nuevo.';

  @override
  String get errorDeleteComment =>
      'Error al eliminar comentario. Inténtalo de nuevo.';

  @override
  String errorInitApp(String error) {
    return 'Error inicializando app: $error';
  }

  @override
  String profileChangeTitle(String field) {
    return 'Solicitud de cambio de datos: $field';
  }

  @override
  String profileChangeDescription(
      String field, String currentValue, String requestedValue) {
    return 'El usuario solicita cambiar \"$field\" de \"$currentValue\" a \"$requestedValue\".';
  }

  @override
  String get errorSendChangeRequest => 'Error al enviar solicitud de cambio';

  @override
  String errorSendGeneric(String error) {
    return 'Error al enviar solicitud: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get goBack => 'Volver';

  @override
  String get sendComment => 'Enviar comentario';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get dismissError => 'Cerrar';

  @override
  String get noPermissions => 'Sin permisos';

  @override
  String get roleSelect => 'Rol';

  @override
  String get newIncident => 'Nueva incidencia';

  @override
  String get validatorPasswordDigit =>
      'La contraseña debe contener al menos un número';

  @override
  String get validatorConfirmPasswordRequired =>
      'Por favor, confirma tu contraseña';

  @override
  String validatorNumberInvalid(String fieldName) {
    return '$fieldName debe ser un número válido';
  }

  @override
  String get thisField => 'Este campo';

  @override
  String get theDate => 'La fecha';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordChanged => 'Contraseña actualizada correctamente';

  @override
  String get changePasswordError => 'Error al cambiar contraseña';

  @override
  String get passwordRequirements =>
      'Mín. 8 caracteres, 1 mayúscula, 1 minúscula, 1 número';

  @override
  String get approveBooking => 'Aprobar';

  @override
  String get bookingApproved => 'Reserva aprobada';

  @override
  String get approveBookingConfirm => '¿Aprobar esta reserva?';

  @override
  String get approveDocument => 'Aprobar';

  @override
  String get rejectDocument => 'Rechazar';

  @override
  String get rejectionReason => 'Motivo del rechazo';

  @override
  String get documentApproved => 'Documento aprobado';

  @override
  String get documentRejected => 'Documento rechazado';

  @override
  String get pendingApproval => 'Pendiente de aprobación';

  @override
  String get approved => 'Aprobado';

  @override
  String get rejected => 'Rechazado';

  @override
  String get adminUsers => 'Gestión de usuarios';

  @override
  String get manageUsers => 'Usuarios';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String resetPasswordConfirm(String name) {
    return '¿Restablecer la contraseña de $name?';
  }

  @override
  String newPasswordFor(String name) {
    return 'Nueva contraseña para $name';
  }

  @override
  String get passwordResetSuccess => 'Contraseña restablecida';

  @override
  String get toggleActive => 'Activar/Desactivar';

  @override
  String get userActivated => 'Usuario activado';

  @override
  String get userDeactivated => 'Usuario desactivado';

  @override
  String get changeRole => 'Cambiar rol';

  @override
  String get roleChanged => 'Rol actualizado';

  @override
  String get noUsers => 'No hay usuarios';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get activeUsers => 'Activos';

  @override
  String get inactiveUsers => 'Inactivos';

  @override
  String get allUsers => 'Todos';

  @override
  String get manageZones => 'Gestión de zonas';

  @override
  String get zoneName => 'Nombre de la zona';

  @override
  String get zoneDescription => 'Descripción';

  @override
  String get zoneCapacity => 'Capacidad máxima';

  @override
  String get zoneRequiresApproval => 'Requiere aprobación';

  @override
  String get zoneActive => 'Activa';

  @override
  String get createZone => 'Crear zona';

  @override
  String get editZone => 'Editar zona';

  @override
  String get deleteZone => 'Eliminar zona';

  @override
  String get deleteZoneConfirm => '¿Eliminar esta zona?';

  @override
  String get zoneCreated => 'Zona creada';

  @override
  String get zoneUpdated => 'Zona actualizada';

  @override
  String get zoneDeleted => 'Zona eliminada';

  @override
  String get noZones => 'No hay zonas';

  @override
  String get maxBookingHours => 'Máx. horas por reserva';

  @override
  String get maxBookingsPerDay => 'Máx. reservas por día';

  @override
  String get advanceBookingDays => 'Días de reserva anticipada';

  @override
  String get availableFrom => 'Disponible desde';

  @override
  String get availableUntil => 'Disponible hasta';

  @override
  String get inactive => 'Inactiva';

  @override
  String get save => 'Guardar';
}
