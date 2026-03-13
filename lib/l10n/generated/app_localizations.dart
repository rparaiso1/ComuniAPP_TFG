import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// App title
  ///
  /// In es, this message translates to:
  /// **'ComuniApp'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String hello(String name);

  /// No description provided for @userFallback.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get userFallback;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBoard.
  ///
  /// In es, this message translates to:
  /// **'Tablón'**
  String get navBoard;

  /// No description provided for @navBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get navBookings;

  /// No description provided for @navIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get navIncidents;

  /// No description provided for @navDocs.
  ///
  /// In es, this message translates to:
  /// **'Docs'**
  String get navDocs;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @rolePresident.
  ///
  /// In es, this message translates to:
  /// **'Presidente'**
  String get rolePresident;

  /// No description provided for @roleNeighbor.
  ///
  /// In es, this message translates to:
  /// **'Vecino'**
  String get roleNeighbor;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'Error de inicio de sesión'**
  String get loginError;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get unexpectedError;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// No description provided for @communityManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Comunidades'**
  String get communityManagement;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @thePassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña'**
  String get thePassword;

  /// No description provided for @hasInvitation.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes una invitación? Regístrate aquí'**
  String get hasInvitation;

  /// No description provided for @splashTitle.
  ///
  /// In es, this message translates to:
  /// **'ComuniApp'**
  String get splashTitle;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro con Invitación'**
  String get registerTitle;

  /// No description provided for @enterInvitationToken.
  ///
  /// In es, this message translates to:
  /// **'Introduce el token de invitación'**
  String get enterInvitationToken;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Registro Completado!'**
  String get registrationComplete;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta ha sido creada exitosamente.\n\nEmail: {email}\nVivienda: {dwelling}\n\nYa puedes iniciar sesión en la app.'**
  String accountCreatedMessage(String email, String dwelling);

  /// No description provided for @goToLogin.
  ///
  /// In es, this message translates to:
  /// **'Ir al Login'**
  String get goToLogin;

  /// No description provided for @registrationError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrar'**
  String get registrationError;

  /// No description provided for @connectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get connectionError;

  /// No description provided for @haveInvitation.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes una invitación?'**
  String get haveInvitation;

  /// No description provided for @invitationExplanation.
  ///
  /// In es, this message translates to:
  /// **'Si el administrador de tu comunidad te ha invitado, habrás recibido un código de invitación.\n\nIntrodúcelo a continuación para verificar tu identidad y crear tu cuenta.'**
  String get invitationExplanation;

  /// No description provided for @invitationTokenLabel.
  ///
  /// In es, this message translates to:
  /// **'Token de invitación'**
  String get invitationTokenLabel;

  /// No description provided for @invitationTokenHint.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí tu código de invitación'**
  String get invitationTokenHint;

  /// No description provided for @verifyInvitation.
  ///
  /// In es, this message translates to:
  /// **'Verificar Invitación'**
  String get verifyInvitation;

  /// No description provided for @validInvitation.
  ///
  /// In es, this message translates to:
  /// **'Invitación Válida'**
  String get validInvitation;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre:'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Email:'**
  String get emailLabel;

  /// No description provided for @dwellingLabel.
  ///
  /// In es, this message translates to:
  /// **'Vivienda:'**
  String get dwellingLabel;

  /// No description provided for @roleLabel.
  ///
  /// In es, this message translates to:
  /// **'Rol:'**
  String get roleLabel;

  /// No description provided for @choosePassword.
  ///
  /// In es, this message translates to:
  /// **'Elige tu contraseña'**
  String get choosePassword;

  /// No description provided for @minChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get minChars;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @completeRegistration.
  ///
  /// In es, this message translates to:
  /// **'Completar Registro'**
  String get completeRegistration;

  /// No description provided for @myProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get myProfile;

  /// No description provided for @emailField.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailField;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @notSpecified.
  ///
  /// In es, this message translates to:
  /// **'No especificado'**
  String get notSpecified;

  /// No description provided for @dwelling.
  ///
  /// In es, this message translates to:
  /// **'Vivienda'**
  String get dwelling;

  /// No description provided for @role.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get role;

  /// No description provided for @memberSince.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get memberSince;

  /// No description provided for @profileEditHint.
  ///
  /// In es, this message translates to:
  /// **'Para modificar tus datos, pulsa el icono de edición. Se enviará una solicitud al administrador para su aprobación.'**
  String get profileEditHint;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesion'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estas seguro de que quieres cerrar sesion?'**
  String get logoutConfirm;

  /// No description provided for @requestChange.
  ///
  /// In es, this message translates to:
  /// **'Solicitar cambio de {fieldName}'**
  String requestChange(String fieldName);

  /// No description provided for @currentValue.
  ///
  /// In es, this message translates to:
  /// **'Valor actual: {value}'**
  String currentValue(String value);

  /// No description provided for @newDesiredValue.
  ///
  /// In es, this message translates to:
  /// **'Nuevo valor deseado'**
  String get newDesiredValue;

  /// No description provided for @changeRequestNote.
  ///
  /// In es, this message translates to:
  /// **'Se enviará una solicitud al administrador para su revisión.'**
  String get changeRequestNote;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @sendRequest.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get sendRequest;

  /// No description provided for @changeRequestSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de cambio de {fieldName} enviada correctamente'**
  String changeRequestSent(String fieldName);

  /// No description provided for @changeRequestError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar solicitud'**
  String get changeRequestError;

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get active;

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get quickActions;

  /// No description provided for @activitySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de actividad'**
  String get activitySummary;

  /// No description provided for @bookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get bookings;

  /// No description provided for @incidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get incidents;

  /// No description provided for @board.
  ///
  /// In es, this message translates to:
  /// **'Tablón'**
  String get board;

  /// No description provided for @documents.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get documents;

  /// No description provided for @invitations.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones'**
  String get invitations;

  /// No description provided for @importData.
  ///
  /// In es, this message translates to:
  /// **'Importar datos'**
  String get importData;

  /// No description provided for @publications.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get publications;

  /// No description provided for @openIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias abiertas'**
  String get openIncidents;

  /// No description provided for @loadPostsError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar publicaciones'**
  String get loadPostsError;

  /// No description provided for @boardTitle.
  ///
  /// In es, this message translates to:
  /// **'Tablón'**
  String get boardTitle;

  /// No description provided for @noPosts.
  ///
  /// In es, this message translates to:
  /// **'No hay publicaciones'**
  String get noPosts;

  /// No description provided for @postsWillAppear.
  ///
  /// In es, this message translates to:
  /// **'Las publicaciones de la comunidad aparecerán aquí'**
  String get postsWillAppear;

  /// No description provided for @deletePost.
  ///
  /// In es, this message translates to:
  /// **'Eliminar publicación'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta publicación?'**
  String get deletePostConfirm;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @publish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publish;

  /// No description provided for @newPost.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get newPost;

  /// No description provided for @title.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @content.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get content;

  /// No description provided for @completeTitleContent.
  ///
  /// In es, this message translates to:
  /// **'Completa título y contenido'**
  String get completeTitleContent;

  /// No description provided for @announcementDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del anuncio'**
  String get announcementDetail;

  /// No description provided for @loadAnnouncementError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el anuncio'**
  String get loadAnnouncementError;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @published.
  ///
  /// In es, this message translates to:
  /// **'Publicado'**
  String get published;

  /// No description provided for @updated.
  ///
  /// In es, this message translates to:
  /// **'Actualizado'**
  String get updated;

  /// No description provided for @loadBookingsError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar reservas'**
  String get loadBookingsError;

  /// No description provided for @noBookings.
  ///
  /// In es, this message translates to:
  /// **'No hay reservas'**
  String get noBookings;

  /// No description provided for @cancelBooking.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar la reserva de {zoneName}?'**
  String cancelBookingConfirm(String zoneName);

  /// No description provided for @reasonOptional.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get reasonOptional;

  /// No description provided for @reasonExample.
  ///
  /// In es, this message translates to:
  /// **'Ej: Cambio de planes'**
  String get reasonExample;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @bookingCancelled.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada'**
  String get bookingCancelled;

  /// No description provided for @bookingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get bookingsTitle;

  /// No description provided for @statusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get statusCompleted;

  /// No description provided for @statusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get statusInProgress;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get statusConfirmed;

  /// No description provided for @zone.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get zone;

  /// No description provided for @cancelBookingTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelBookingTooltip;

  /// No description provided for @reason.
  ///
  /// In es, this message translates to:
  /// **'Motivo: {reason}'**
  String reason(String reason);

  /// No description provided for @zoneTypePool.
  ///
  /// In es, this message translates to:
  /// **'Piscina'**
  String get zoneTypePool;

  /// No description provided for @zoneTypeCourt.
  ///
  /// In es, this message translates to:
  /// **'Pista deportiva'**
  String get zoneTypeCourt;

  /// No description provided for @zoneTypeGym.
  ///
  /// In es, this message translates to:
  /// **'Gimnasio'**
  String get zoneTypeGym;

  /// No description provided for @zoneTypeRoom.
  ///
  /// In es, this message translates to:
  /// **'Salón / Sala'**
  String get zoneTypeRoom;

  /// No description provided for @zoneTypePlayground.
  ///
  /// In es, this message translates to:
  /// **'Zona infantil'**
  String get zoneTypePlayground;

  /// No description provided for @zoneTypeBbq.
  ///
  /// In es, this message translates to:
  /// **'Barbacoa'**
  String get zoneTypeBbq;

  /// No description provided for @zoneRequired.
  ///
  /// In es, this message translates to:
  /// **'Zona requerida'**
  String get zoneRequired;

  /// No description provided for @selectZone.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una zona para reservar.'**
  String get selectZone;

  /// No description provided for @datesRequired.
  ///
  /// In es, this message translates to:
  /// **'Fechas requeridas'**
  String get datesRequired;

  /// No description provided for @selectDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona fecha de inicio y fin.'**
  String get selectDates;

  /// No description provided for @invalidDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas inválidas'**
  String get invalidDates;

  /// No description provided for @endAfterStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin debe ser posterior al inicio.'**
  String get endAfterStart;

  /// No description provided for @createBookingError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear reserva'**
  String get createBookingError;

  /// No description provided for @bookingCreated.
  ///
  /// In es, this message translates to:
  /// **'Reserva creada correctamente'**
  String get bookingCreated;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @newBooking.
  ///
  /// In es, this message translates to:
  /// **'Nueva Reserva'**
  String get newBooking;

  /// No description provided for @noZonesAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay zonas disponibles'**
  String get noZonesAvailable;

  /// No description provided for @adminMustCreateZones.
  ///
  /// In es, this message translates to:
  /// **'El administrador debe crear zonas primero'**
  String get adminMustCreateZones;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get start;

  /// No description provided for @end.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get end;

  /// No description provided for @notesOptional.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get notesOptional;

  /// No description provided for @notesExample.
  ///
  /// In es, this message translates to:
  /// **'Ej: Reserva para cumpleaños'**
  String get notesExample;

  /// No description provided for @creating.
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get creating;

  /// No description provided for @createBooking.
  ///
  /// In es, this message translates to:
  /// **'Crear reserva'**
  String get createBooking;

  /// No description provided for @tapToSelect.
  ///
  /// In es, this message translates to:
  /// **'pulsa para seleccionar'**
  String get tapToSelect;

  /// No description provided for @loadIncidentsError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar incidentes'**
  String get loadIncidentsError;

  /// No description provided for @noIncidents.
  ///
  /// In es, this message translates to:
  /// **'No hay incidencias'**
  String get noIncidents;

  /// No description provided for @deleteIncident.
  ///
  /// In es, this message translates to:
  /// **'Eliminar incidencia'**
  String get deleteIncident;

  /// No description provided for @deleteIncidentConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta incidencia?'**
  String get deleteIncidentConfirm;

  /// No description provided for @incidentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get incidentsTitle;

  /// No description provided for @newIncidentDialog.
  ///
  /// In es, this message translates to:
  /// **'Nueva Incidencia'**
  String get newIncidentDialog;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @locationOptional.
  ///
  /// In es, this message translates to:
  /// **'Ubicación (opcional)'**
  String get locationOptional;

  /// No description provided for @locationExample.
  ///
  /// In es, this message translates to:
  /// **'Ej: Edificio A, Piso 3'**
  String get locationExample;

  /// No description provided for @priority.
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get priorityHigh;

  /// No description provided for @priorityCritical.
  ///
  /// In es, this message translates to:
  /// **'Urgente'**
  String get priorityCritical;

  /// No description provided for @priorityLowEmoji.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get priorityLowEmoji;

  /// No description provided for @priorityMediumEmoji.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get priorityMediumEmoji;

  /// No description provided for @priorityHighEmoji.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get priorityHighEmoji;

  /// No description provided for @completeTitleDescription.
  ///
  /// In es, this message translates to:
  /// **'Completa título y descripción'**
  String get completeTitleDescription;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @statusOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierta'**
  String get statusOpen;

  /// No description provided for @statusInProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get statusInProgressLabel;

  /// No description provided for @statusResolved.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get statusClosed;

  /// No description provided for @incidentDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de incidencia'**
  String get incidentDetail;

  /// No description provided for @loadIncidentError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la incidencia'**
  String get loadIncidentError;

  /// No description provided for @reportedBy.
  ///
  /// In es, this message translates to:
  /// **'Reportado por'**
  String get reportedBy;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @assignedTo.
  ///
  /// In es, this message translates to:
  /// **'Asignado a'**
  String get assignedTo;

  /// No description provided for @created.
  ///
  /// In es, this message translates to:
  /// **'Creada'**
  String get created;

  /// No description provided for @actions.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get actions;

  /// No description provided for @inProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get inProgress;

  /// No description provided for @resolve.
  ///
  /// In es, this message translates to:
  /// **'Resolver'**
  String get resolve;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @statusUpdated.
  ///
  /// In es, this message translates to:
  /// **'Estado actualizado'**
  String get statusUpdated;

  /// No description provided for @newIncidentTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva incidencia'**
  String get newIncidentTitle;

  /// No description provided for @describeProblem.
  ///
  /// In es, this message translates to:
  /// **'Describe brevemente el problema'**
  String get describeProblem;

  /// No description provided for @titleRequired.
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get titleRequired;

  /// No description provided for @detailProblem.
  ///
  /// In es, this message translates to:
  /// **'Detalla el problema con toda la información posible'**
  String get detailProblem;

  /// No description provided for @descriptionRequired.
  ///
  /// In es, this message translates to:
  /// **'La descripción es obligatoria'**
  String get descriptionRequired;

  /// No description provided for @locationExampleLong.
  ///
  /// In es, this message translates to:
  /// **'Ej: Portal 3, planta 2 / Piscina / Garaje'**
  String get locationExampleLong;

  /// No description provided for @submitIncident.
  ///
  /// In es, this message translates to:
  /// **'Enviar incidencia'**
  String get submitIncident;

  /// No description provided for @incidentCreated.
  ///
  /// In es, this message translates to:
  /// **'Incidencia creada correctamente'**
  String get incidentCreated;

  /// No description provided for @loadDocsError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar documentos'**
  String get loadDocsError;

  /// No description provided for @noDocuments.
  ///
  /// In es, this message translates to:
  /// **'No hay documentos'**
  String get noDocuments;

  /// No description provided for @noDocsInCategory.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron documentos en esta categoría'**
  String get noDocsInCategory;

  /// No description provided for @docsWillAppear.
  ///
  /// In es, this message translates to:
  /// **'Los documentos de la comunidad aparecerán aquí'**
  String get docsWillAppear;

  /// No description provided for @deleteDocument.
  ///
  /// In es, this message translates to:
  /// **'Eliminar documento'**
  String get deleteDocument;

  /// No description provided for @deleteDocConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar este documento?'**
  String get deleteDocConfirm;

  /// No description provided for @documentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get documentsTitle;

  /// No description provided for @catAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get catAll;

  /// No description provided for @catMinutes.
  ///
  /// In es, this message translates to:
  /// **'Actas'**
  String get catMinutes;

  /// No description provided for @catRegulations.
  ///
  /// In es, this message translates to:
  /// **'Normativas'**
  String get catRegulations;

  /// No description provided for @catInvoices.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get catInvoices;

  /// No description provided for @catMisc.
  ///
  /// In es, this message translates to:
  /// **'Varios'**
  String get catMisc;

  /// No description provided for @catDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get catDocuments;

  /// No description provided for @downloadDocument.
  ///
  /// In es, this message translates to:
  /// **'Descargar documento'**
  String get downloadDocument;

  /// No description provided for @uploadDocument.
  ///
  /// In es, this message translates to:
  /// **'Subir Documento'**
  String get uploadDocument;

  /// No description provided for @fileUrl.
  ///
  /// In es, this message translates to:
  /// **'URL del archivo'**
  String get fileUrl;

  /// No description provided for @fileUrlHint.
  ///
  /// In es, this message translates to:
  /// **'https://...'**
  String get fileUrlHint;

  /// No description provided for @fileType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de archivo'**
  String get fileType;

  /// No description provided for @fileTypePdf.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get fileTypePdf;

  /// No description provided for @fileTypeWord.
  ///
  /// In es, this message translates to:
  /// **'Word'**
  String get fileTypeWord;

  /// No description provided for @fileTypeExcel.
  ///
  /// In es, this message translates to:
  /// **'Excel'**
  String get fileTypeExcel;

  /// No description provided for @fileTypeImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get fileTypeImage;

  /// No description provided for @fileTypeOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get fileTypeOther;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descriptionOptional;

  /// No description provided for @completeTitleUrl.
  ///
  /// In es, this message translates to:
  /// **'Completa título y URL'**
  String get completeTitleUrl;

  /// No description provided for @upload.
  ///
  /// In es, this message translates to:
  /// **'Subir'**
  String get upload;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @allMarkedRead.
  ///
  /// In es, this message translates to:
  /// **'Todas marcadas como leídas'**
  String get allMarkedRead;

  /// No description provided for @markReadError.
  ///
  /// In es, this message translates to:
  /// **'Error al marcar notificaciones'**
  String get markReadError;

  /// No description provided for @markAllRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar todo como leído'**
  String get markAllRead;

  /// No description provided for @deleteNotifications.
  ///
  /// In es, this message translates to:
  /// **'Eliminar notificaciones'**
  String get deleteNotifications;

  /// No description provided for @deleteAllNotificationsConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas eliminar todas las notificaciones?'**
  String get deleteAllNotificationsConfirm;

  /// No description provided for @deleteAll.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todas'**
  String get deleteAll;

  /// No description provided for @noNotifications.
  ///
  /// In es, this message translates to:
  /// **'No tienes notificaciones'**
  String get noNotifications;

  /// No description provided for @timeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get timeNow;

  /// No description provided for @timeMinAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} min'**
  String timeMinAgo(int count);

  /// No description provided for @timeHourAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} h'**
  String timeHourAgo(int count);

  /// No description provided for @timeYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} días'**
  String timeDaysAgo(int count);

  /// No description provided for @calendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendar;

  /// No description provided for @goToToday.
  ///
  /// In es, this message translates to:
  /// **'Ir a hoy'**
  String get goToToday;

  /// No description provided for @noEvents.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos'**
  String get noEvents;

  /// No description provided for @monthJanuary.
  ///
  /// In es, this message translates to:
  /// **'Enero'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In es, this message translates to:
  /// **'Febrero'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In es, this message translates to:
  /// **'Marzo'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In es, this message translates to:
  /// **'Abril'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In es, this message translates to:
  /// **'Mayo'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In es, this message translates to:
  /// **'Junio'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In es, this message translates to:
  /// **'Julio'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In es, this message translates to:
  /// **'Agosto'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In es, this message translates to:
  /// **'Septiembre'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In es, this message translates to:
  /// **'Octubre'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In es, this message translates to:
  /// **'Noviembre'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In es, this message translates to:
  /// **'Diciembre'**
  String get monthDecember;

  /// No description provided for @dayMon.
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get daySun;

  /// No description provided for @dayMonFull.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get dayMonFull;

  /// No description provided for @dayTueFull.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get dayTueFull;

  /// No description provided for @dayWedFull.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get dayWedFull;

  /// No description provided for @dayThuFull.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get dayThuFull;

  /// No description provided for @dayFriFull.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get dayFriFull;

  /// No description provided for @daySatFull.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get daySatFull;

  /// No description provided for @daySunFull.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get daySunFull;

  /// No description provided for @monthJanuaryLower.
  ///
  /// In es, this message translates to:
  /// **'enero'**
  String get monthJanuaryLower;

  /// No description provided for @monthFebruaryLower.
  ///
  /// In es, this message translates to:
  /// **'febrero'**
  String get monthFebruaryLower;

  /// No description provided for @monthMarchLower.
  ///
  /// In es, this message translates to:
  /// **'marzo'**
  String get monthMarchLower;

  /// No description provided for @monthAprilLower.
  ///
  /// In es, this message translates to:
  /// **'abril'**
  String get monthAprilLower;

  /// No description provided for @monthMayLower.
  ///
  /// In es, this message translates to:
  /// **'mayo'**
  String get monthMayLower;

  /// No description provided for @monthJuneLower.
  ///
  /// In es, this message translates to:
  /// **'junio'**
  String get monthJuneLower;

  /// No description provided for @monthJulyLower.
  ///
  /// In es, this message translates to:
  /// **'julio'**
  String get monthJulyLower;

  /// No description provided for @monthAugustLower.
  ///
  /// In es, this message translates to:
  /// **'agosto'**
  String get monthAugustLower;

  /// No description provided for @monthSeptemberLower.
  ///
  /// In es, this message translates to:
  /// **'septiembre'**
  String get monthSeptemberLower;

  /// No description provided for @monthOctoberLower.
  ///
  /// In es, this message translates to:
  /// **'octubre'**
  String get monthOctoberLower;

  /// No description provided for @monthNovemberLower.
  ///
  /// In es, this message translates to:
  /// **'noviembre'**
  String get monthNovemberLower;

  /// No description provided for @monthDecemberLower.
  ///
  /// In es, this message translates to:
  /// **'diciembre'**
  String get monthDecemberLower;

  /// No description provided for @importTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar datos'**
  String get importTitle;

  /// No description provided for @importDescription.
  ///
  /// In es, this message translates to:
  /// **'Importa vecinos, presidentes, miembros de junta, inquilinos y zonas comunes desde un archivo Excel (.xlsx) o CSV. La primera fila debe contener las cabeceras.'**
  String get importDescription;

  /// No description provided for @importUsers.
  ///
  /// In es, this message translates to:
  /// **'Importar usuarios'**
  String get importUsers;

  /// No description provided for @importUsersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vecinos, presidentes, junta directiva, inquilinos'**
  String get importUsersSubtitle;

  /// No description provided for @colEmail.
  ///
  /// In es, this message translates to:
  /// **'email (obligatorio)'**
  String get colEmail;

  /// No description provided for @colName.
  ///
  /// In es, this message translates to:
  /// **'nombre (obligatorio)'**
  String get colName;

  /// No description provided for @colRole.
  ///
  /// In es, this message translates to:
  /// **'rol (ADMIN/PRESIDENT/NEIGHBOR)'**
  String get colRole;

  /// No description provided for @colPhone.
  ///
  /// In es, this message translates to:
  /// **'telefono (opcional)'**
  String get colPhone;

  /// No description provided for @colDwelling.
  ///
  /// In es, this message translates to:
  /// **'vivienda (opcional)'**
  String get colDwelling;

  /// No description provided for @colPassword.
  ///
  /// In es, this message translates to:
  /// **'password (opcional, por defecto: ComuniApp2024)'**
  String get colPassword;

  /// No description provided for @importZones.
  ///
  /// In es, this message translates to:
  /// **'Importar zonas comunes'**
  String get importZones;

  /// No description provided for @importZonesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Piscina, pista de pádel, sala, gimnasio...'**
  String get importZonesSubtitle;

  /// No description provided for @colZoneName.
  ///
  /// In es, this message translates to:
  /// **'nombre (obligatorio)'**
  String get colZoneName;

  /// No description provided for @colZoneType.
  ///
  /// In es, this message translates to:
  /// **'tipo (obligatorio: pool/court/room/gym/garden)'**
  String get colZoneType;

  /// No description provided for @colZoneDesc.
  ///
  /// In es, this message translates to:
  /// **'descripcion (opcional)'**
  String get colZoneDesc;

  /// No description provided for @colZoneCapacity.
  ///
  /// In es, this message translates to:
  /// **'capacidad (opcional, número)'**
  String get colZoneCapacity;

  /// No description provided for @colZoneApproval.
  ///
  /// In es, this message translates to:
  /// **'requiere_aprobacion (opcional: si/no)'**
  String get colZoneApproval;

  /// No description provided for @importResult.
  ///
  /// In es, this message translates to:
  /// **'Resultado de la importación'**
  String get importResult;

  /// No description provided for @fileReadError.
  ///
  /// In es, this message translates to:
  /// **'Error al leer el archivo'**
  String get fileReadError;

  /// No description provided for @serverError.
  ///
  /// In es, this message translates to:
  /// **'Error del servidor'**
  String get serverError;

  /// No description provided for @expectedColumns.
  ///
  /// In es, this message translates to:
  /// **'Columnas esperadas:'**
  String get expectedColumns;

  /// No description provided for @importing.
  ///
  /// In es, this message translates to:
  /// **'Importando...'**
  String get importing;

  /// No description provided for @selectFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo'**
  String get selectFile;

  /// No description provided for @noFileSelected.
  ///
  /// In es, this message translates to:
  /// **'Ningún archivo seleccionado'**
  String get noFileSelected;

  /// No description provided for @fileSelected.
  ///
  /// In es, this message translates to:
  /// **'Archivo seleccionado'**
  String get fileSelected;

  /// No description provided for @fileTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El archivo no puede superar 10 MB'**
  String get fileTooLarge;

  /// No description provided for @completeTitleFile.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un archivo e indica el título'**
  String get completeTitleFile;

  /// No description provided for @uploadSuccess.
  ///
  /// In es, this message translates to:
  /// **'Documento subido correctamente'**
  String get uploadSuccess;

  /// No description provided for @uploadError.
  ///
  /// In es, this message translates to:
  /// **'Error al subir el documento'**
  String get uploadError;

  /// No description provided for @maxFileSize.
  ///
  /// In es, this message translates to:
  /// **'Máx. 10 MB — PDF, Word, Excel, imágenes'**
  String get maxFileSize;

  /// No description provided for @tapToSelectFile.
  ///
  /// In es, this message translates to:
  /// **'Toca para seleccionar un archivo'**
  String get tapToSelectFile;

  /// No description provided for @changeFile.
  ///
  /// In es, this message translates to:
  /// **'Cambiar archivo'**
  String get changeFile;

  /// No description provided for @totalRows.
  ///
  /// In es, this message translates to:
  /// **'Total filas'**
  String get totalRows;

  /// No description provided for @imported.
  ///
  /// In es, this message translates to:
  /// **'Importados'**
  String get imported;

  /// No description provided for @errors.
  ///
  /// In es, this message translates to:
  /// **'Errores'**
  String get errors;

  /// No description provided for @errorDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalle de errores:'**
  String get errorDetails;

  /// No description provided for @invitationsManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Invitaciones'**
  String get invitationsManagement;

  /// No description provided for @emailAndNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Email y nombre son obligatorios'**
  String get emailAndNameRequired;

  /// No description provided for @loadInvitationsError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar invitaciones'**
  String get loadInvitationsError;

  /// No description provided for @invitationCreated.
  ///
  /// In es, this message translates to:
  /// **'Invitación creada'**
  String get invitationCreated;

  /// No description provided for @invitationFor.
  ///
  /// In es, this message translates to:
  /// **'Invitación para {name} creada correctamente.'**
  String invitationFor(String name);

  /// No description provided for @registrationToken.
  ///
  /// In es, this message translates to:
  /// **'Token de registro:'**
  String get registrationToken;

  /// No description provided for @shareTokenHint.
  ///
  /// In es, this message translates to:
  /// **'Comparte este token con el vecino para que pueda registrarse.'**
  String get shareTokenHint;

  /// No description provided for @tokenCopied.
  ///
  /// In es, this message translates to:
  /// **'Token copiado al portapapeles'**
  String get tokenCopied;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @revokeInvitation.
  ///
  /// In es, this message translates to:
  /// **'Revocar invitación'**
  String get revokeInvitation;

  /// No description provided for @revokeInvitationConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta invitación?'**
  String get revokeInvitationConfirm;

  /// No description provided for @invitationDeleted.
  ///
  /// In es, this message translates to:
  /// **'Invitación eliminada'**
  String get invitationDeleted;

  /// No description provided for @noAccess.
  ///
  /// In es, this message translates to:
  /// **'Sin acceso'**
  String get noAccess;

  /// No description provided for @noAccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Solo administradores o presidentes pueden acceder.'**
  String get noAccessMessage;

  /// No description provided for @newInvitation.
  ///
  /// In es, this message translates to:
  /// **'Nueva invitación'**
  String get newInvitation;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Email *'**
  String get emailRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo *'**
  String get fullNameRequired;

  /// No description provided for @phoneOptional.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phoneOptional;

  /// No description provided for @dwellingOptional.
  ///
  /// In es, this message translates to:
  /// **'Vivienda (opcional)'**
  String get dwellingOptional;

  /// No description provided for @dwellingExample.
  ///
  /// In es, this message translates to:
  /// **'Ej: Bloque A - 3ºB'**
  String get dwellingExample;

  /// No description provided for @creatingInvitation.
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get creatingInvitation;

  /// No description provided for @createInvitation.
  ///
  /// In es, this message translates to:
  /// **'Crear invitación'**
  String get createInvitation;

  /// No description provided for @howItWorks.
  ///
  /// In es, this message translates to:
  /// **'Cómo funciona'**
  String get howItWorks;

  /// No description provided for @step1.
  ///
  /// In es, this message translates to:
  /// **'Rellena los datos y crea la invitación'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In es, this message translates to:
  /// **'Comparte el token generado con el vecino'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In es, this message translates to:
  /// **'El vecino introduce el token en la pantalla de registro'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In es, this message translates to:
  /// **'Crea su contraseña y ya tiene acceso a la app'**
  String get step4;

  /// No description provided for @noInvitationsYet.
  ///
  /// In es, this message translates to:
  /// **'No hay invitaciones aún'**
  String get noInvitationsYet;

  /// No description provided for @invitationsSection.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones'**
  String get invitationsSection;

  /// No description provided for @statusUsed.
  ///
  /// In es, this message translates to:
  /// **'USADA'**
  String get statusUsed;

  /// No description provided for @statusExpired.
  ///
  /// In es, this message translates to:
  /// **'EXPIRADA'**
  String get statusExpired;

  /// No description provided for @statusPendingUpper.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get statusPendingUpper;

  /// No description provided for @statusApprovedUpper.
  ///
  /// In es, this message translates to:
  /// **'APROBADA'**
  String get statusApprovedUpper;

  /// No description provided for @token.
  ///
  /// In es, this message translates to:
  /// **'Token: {token}'**
  String token(String token);

  /// No description provided for @copyToken.
  ///
  /// In es, this message translates to:
  /// **'Copiar token'**
  String get copyToken;

  /// No description provided for @tokenCopiedShort.
  ///
  /// In es, this message translates to:
  /// **'Token copiado'**
  String get tokenCopiedShort;

  /// No description provided for @revoke.
  ///
  /// In es, this message translates to:
  /// **'Revocar'**
  String get revoke;

  /// No description provided for @errorConnection.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar al servidor. Verifica tu conexión a internet e inténtalo de nuevo.'**
  String get errorConnection;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Usuario o contraseña incorrectos. Verifica tus datos e inténtalo de nuevo.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorSessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ha expirado. Inicia sesión de nuevo.'**
  String get errorSessionExpired;

  /// No description provided for @errorForbidden.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para realizar esta acción.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'El recurso solicitado no se ha encontrado.'**
  String get errorNotFound;

  /// No description provided for @errorDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un registro con estos datos. Verifica la información.'**
  String get errorDuplicate;

  /// No description provided for @errorBookingConflict.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una reserva en ese horario. Elige otro horario.'**
  String get errorBookingConflict;

  /// No description provided for @errorValidation.
  ///
  /// In es, this message translates to:
  /// **'Los datos ingresados no son válidos. Revisa la información.'**
  String get errorValidation;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'El servidor está experimentando problemas. Inténtalo más tarde.'**
  String get errorServer;

  /// No description provided for @errorUnexpectedResponse.
  ///
  /// In es, this message translates to:
  /// **'Se recibió una respuesta inesperada del servidor. Inténtalo de nuevo.'**
  String get errorUnexpectedResponse;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Ha ocurrido un error inesperado. Inténtalo de nuevo.'**
  String get errorGeneric;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @noConnectionOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Algunos datos pueden no estar actualizados.'**
  String get noConnectionOffline;

  /// No description provided for @deleteItem.
  ///
  /// In es, this message translates to:
  /// **'Eliminar {itemName}'**
  String deleteItem(String itemName);

  /// No description provided for @deleteItemConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este elemento? Esta acción no se puede deshacer.'**
  String get deleteItemConfirm;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @emptyBookings.
  ///
  /// In es, this message translates to:
  /// **'Sin reservas'**
  String get emptyBookings;

  /// No description provided for @emptyBookingsDesc.
  ///
  /// In es, this message translates to:
  /// **'No tienes reservas activas. Reserva un espacio común para comenzar.'**
  String get emptyBookingsDesc;

  /// No description provided for @emptyBookingsAction.
  ///
  /// In es, this message translates to:
  /// **'Nueva reserva'**
  String get emptyBookingsAction;

  /// No description provided for @emptyIncidents.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden'**
  String get emptyIncidents;

  /// No description provided for @emptyIncidentsDesc.
  ///
  /// In es, this message translates to:
  /// **'No hay incidencias reportadas. ¡Excelente!'**
  String get emptyIncidentsDesc;

  /// No description provided for @emptyIncidentsAction.
  ///
  /// In es, this message translates to:
  /// **'Reportar incidencia'**
  String get emptyIncidentsAction;

  /// No description provided for @emptyDocuments.
  ///
  /// In es, this message translates to:
  /// **'Sin documentos'**
  String get emptyDocuments;

  /// No description provided for @emptyDocumentsDesc.
  ///
  /// In es, this message translates to:
  /// **'No hay documentos disponibles en este momento.'**
  String get emptyDocumentsDesc;

  /// No description provided for @emptyPosts.
  ///
  /// In es, this message translates to:
  /// **'Sin publicaciones'**
  String get emptyPosts;

  /// No description provided for @emptyPostsDesc.
  ///
  /// In es, this message translates to:
  /// **'No hay publicaciones en el tablón todavía.'**
  String get emptyPostsDesc;

  /// No description provided for @emptyPostsAction.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get emptyPostsAction;

  /// No description provided for @emptySearch.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get emptySearch;

  /// No description provided for @emptySearchDesc.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados para tu búsqueda.'**
  String get emptySearchDesc;

  /// No description provided for @errorState.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get errorState;

  /// No description provided for @errorStateDesc.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la información. Por favor, inténtalo de nuevo.'**
  String get errorStateDesc;

  /// No description provided for @noConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get noConnection;

  /// No description provided for @noConnectionDesc.
  ///
  /// In es, this message translates to:
  /// **'Comprueba tu conexión a internet e inténtalo de nuevo.'**
  String get noConnectionDesc;

  /// No description provided for @validatorEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'El correo electrónico es obligatorio'**
  String get validatorEmailRequired;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un correo electrónico válido'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {minLength} caracteres'**
  String validatorPasswordMinLength(int minLength);

  /// No description provided for @validatorPasswordMinLength8.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get validatorPasswordMinLength8;

  /// No description provided for @validatorPasswordUppercase.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos una letra mayúscula'**
  String get validatorPasswordUppercase;

  /// No description provided for @validatorPasswordLowercase.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos una letra minúscula'**
  String get validatorPasswordLowercase;

  /// No description provided for @validatorPasswordNumber.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos un número'**
  String get validatorPasswordNumber;

  /// No description provided for @validatorConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor, confirma tu contraseña'**
  String get validatorConfirmPassword;

  /// No description provided for @validatorFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} es obligatorio'**
  String validatorFieldRequired(String fieldName);

  /// No description provided for @validatorFieldMinLength.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe tener al menos {minLength} caracteres'**
  String validatorFieldMinLength(String fieldName, int minLength);

  /// No description provided for @validatorFieldMaxLength.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} no puede exceder {maxLength} caracteres'**
  String validatorFieldMaxLength(String fieldName, int maxLength);

  /// No description provided for @validatorPhoneRequired.
  ///
  /// In es, this message translates to:
  /// **'El teléfono es obligatorio'**
  String get validatorPhoneRequired;

  /// No description provided for @validatorPhoneInvalid.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un número de teléfono válido (ej: 612345678)'**
  String get validatorPhoneInvalid;

  /// No description provided for @validatorNumericRequired.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} es obligatorio'**
  String validatorNumericRequired(String fieldName);

  /// No description provided for @validatorNumericInvalid.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe ser un número válido'**
  String validatorNumericInvalid(String fieldName);

  /// No description provided for @validatorNumberRange.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe estar entre {min} y {max}'**
  String validatorNumberRange(String fieldName, int min, int max);

  /// No description provided for @validatorDateRequired.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} es obligatoria'**
  String validatorDateRequired(String fieldName);

  /// No description provided for @validatorDateFuture.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe ser futura'**
  String validatorDateFuture(String fieldName);

  /// No description provided for @validatorUrlRequired.
  ///
  /// In es, this message translates to:
  /// **'La URL es obligatoria'**
  String get validatorUrlRequired;

  /// No description provided for @validatorUrlInvalid.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce una URL válida'**
  String get validatorUrlInvalid;

  /// No description provided for @validatorPostalCodeRequired.
  ///
  /// In es, this message translates to:
  /// **'El código postal es obligatorio'**
  String get validatorPostalCodeRequired;

  /// No description provided for @validatorPostalCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un código postal válido (5 dígitos)'**
  String get validatorPostalCodeInvalid;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @themeMode.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeMode;

  /// No description provided for @themeModeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeModeSystem;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get exportData;

  /// No description provided for @exportUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get exportUsers;

  /// No description provided for @exportBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get exportBookings;

  /// No description provided for @exportIncidents.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get exportIncidents;

  /// No description provided for @exportDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get exportDocuments;

  /// No description provided for @exportZones.
  ///
  /// In es, this message translates to:
  /// **'Zonas'**
  String get exportZones;

  /// No description provided for @exportDownloading.
  ///
  /// In es, this message translates to:
  /// **'Descargando...'**
  String get exportDownloading;

  /// No description provided for @exportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Exportación descargada correctamente'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar datos'**
  String get exportError;

  /// No description provided for @exportWebOnly.
  ///
  /// In es, this message translates to:
  /// **'La descarga directa está disponible solo en la versión web'**
  String get exportWebOnly;

  /// No description provided for @exportDescription.
  ///
  /// In es, this message translates to:
  /// **'Descarga los datos de tu comunidad en formato CSV o PDF'**
  String get exportDescription;

  /// No description provided for @downloadCsv.
  ///
  /// In es, this message translates to:
  /// **'Descargar CSV'**
  String get downloadCsv;

  /// No description provided for @downloadPdf.
  ///
  /// In es, this message translates to:
  /// **'Descargar PDF'**
  String get downloadPdf;

  /// No description provided for @requestTimeout.
  ///
  /// In es, this message translates to:
  /// **'La petición ha tardado demasiado. Inténtalo de nuevo'**
  String get requestTimeout;

  /// No description provided for @pdfExportTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe {resource}'**
  String pdfExportTitle(String resource);

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @startTime.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get endTime;

  /// No description provided for @notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notes;

  /// No description provided for @createdAt.
  ///
  /// In es, this message translates to:
  /// **'Creado'**
  String get createdAt;

  /// No description provided for @uploadedBy.
  ///
  /// In es, this message translates to:
  /// **'Subido por'**
  String get uploadedBy;

  /// No description provided for @userName.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get userName;

  /// No description provided for @budget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get budget;

  /// No description provided for @budgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto comunitario'**
  String get budgetTitle;

  /// No description provided for @budgetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Transparencia económica de tu comunidad'**
  String get budgetSubtitle;

  /// No description provided for @budgetTotalIncome.
  ///
  /// In es, this message translates to:
  /// **'Total ingresos'**
  String get budgetTotalIncome;

  /// No description provided for @budgetTotalExpense.
  ///
  /// In es, this message translates to:
  /// **'Total gastos'**
  String get budgetTotalExpense;

  /// No description provided for @budgetBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get budgetBalance;

  /// No description provided for @budgetEntries.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get budgetEntries;

  /// No description provided for @budgetNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos para este año'**
  String get budgetNoData;

  /// No description provided for @budgetUploadCsv.
  ///
  /// In es, this message translates to:
  /// **'Importar CSV'**
  String get budgetUploadCsv;

  /// No description provided for @budgetUploadSuccess.
  ///
  /// In es, this message translates to:
  /// **'Importados {count} registros correctamente'**
  String budgetUploadSuccess(int count);

  /// No description provided for @budgetUploadError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar: {error}'**
  String budgetUploadError(String error);

  /// No description provided for @budgetUploadErrors.
  ///
  /// In es, this message translates to:
  /// **'Se importaron {imported} de {total} filas. Errores: {count}'**
  String budgetUploadErrors(int imported, int total, int count);

  /// No description provided for @budgetDeleteEntry.
  ///
  /// In es, this message translates to:
  /// **'Eliminar partida'**
  String get budgetDeleteEntry;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta partida presupuestaria?'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Partida eliminada'**
  String get budgetDeleteSuccess;

  /// No description provided for @budgetPieTitle.
  ///
  /// In es, this message translates to:
  /// **'Distribución de gastos'**
  String get budgetPieTitle;

  /// No description provided for @budgetBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Evolución mensual'**
  String get budgetBarTitle;

  /// No description provided for @budgetIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get budgetIncome;

  /// No description provided for @budgetExpense.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get budgetExpense;

  /// No description provided for @budgetSelectYear.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get budgetSelectYear;

  /// No description provided for @budgetCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get budgetCategory;

  /// No description provided for @budgetConcept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get budgetConcept;

  /// No description provided for @budgetAmount.
  ///
  /// In es, this message translates to:
  /// **'Importe'**
  String get budgetAmount;

  /// No description provided for @budgetType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get budgetType;

  /// No description provided for @budgetProvider.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get budgetProvider;

  /// No description provided for @budgetDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get budgetDetail;

  /// No description provided for @budgetDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get budgetDate;

  /// No description provided for @budgetAllEntries.
  ///
  /// In es, this message translates to:
  /// **'Todas las partidas'**
  String get budgetAllEntries;

  /// No description provided for @budgetFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get budgetFilterAll;

  /// No description provided for @budgetFilterIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get budgetFilterIncome;

  /// No description provided for @budgetFilterExpense.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get budgetFilterExpense;

  /// No description provided for @budgetNoPieData.
  ///
  /// In es, this message translates to:
  /// **'Sin gastos este año'**
  String get budgetNoPieData;

  /// No description provided for @budgetDeleteAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get budgetDeleteAll;

  /// No description provided for @budgetDeleteAllConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar todas las partidas de este año? Esta acción no se puede deshacer.'**
  String get budgetDeleteAllConfirm;

  /// No description provided for @navBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get navBudget;

  /// No description provided for @allZones.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get allZones;

  /// No description provided for @filterByZone.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por zona'**
  String get filterByZone;

  /// No description provided for @myBookings.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get myBookings;

  /// No description provided for @allStatuses.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allStatuses;

  /// No description provided for @allPriorities.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get allPriorities;

  /// No description provided for @filterByStatus.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por estado'**
  String get filterByStatus;

  /// No description provided for @filterByPriority.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por prioridad'**
  String get filterByPriority;

  /// No description provided for @myIncidents.
  ///
  /// In es, this message translates to:
  /// **'Mis incidencias'**
  String get myIncidents;

  /// No description provided for @writeComment.
  ///
  /// In es, this message translates to:
  /// **'Escribe un comentario...'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// No description provided for @comments.
  ///
  /// In es, this message translates to:
  /// **'Comentarios'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In es, this message translates to:
  /// **'Sin comentarios aún'**
  String get noComments;

  /// No description provided for @commentAdded.
  ///
  /// In es, this message translates to:
  /// **'Comentario añadido'**
  String get commentAdded;

  /// No description provided for @deleteComment.
  ///
  /// In es, this message translates to:
  /// **'Eliminar comentario'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este comentario?'**
  String get deleteCommentConfirm;

  /// No description provided for @like.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In es, this message translates to:
  /// **'Ya no me gusta'**
  String get unlike;

  /// No description provided for @likes.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get likes;

  /// No description provided for @errorToggleLike.
  ///
  /// In es, this message translates to:
  /// **'Error al dar me gusta. Inténtalo de nuevo.'**
  String get errorToggleLike;

  /// No description provided for @errorAddComment.
  ///
  /// In es, this message translates to:
  /// **'Error al añadir comentario. Inténtalo de nuevo.'**
  String get errorAddComment;

  /// No description provided for @errorDeleteComment.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar comentario. Inténtalo de nuevo.'**
  String get errorDeleteComment;

  /// No description provided for @errorInitApp.
  ///
  /// In es, this message translates to:
  /// **'Error inicializando app: {error}'**
  String errorInitApp(String error);

  /// No description provided for @profileChangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de cambio de datos: {field}'**
  String profileChangeTitle(String field);

  /// No description provided for @profileChangeDescription.
  ///
  /// In es, this message translates to:
  /// **'El usuario solicita cambiar \"{field}\" de \"{currentValue}\" a \"{requestedValue}\".'**
  String profileChangeDescription(
      String field, String currentValue, String requestedValue);

  /// No description provided for @errorSendChangeRequest.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar solicitud de cambio'**
  String get errorSendChangeRequest;

  /// No description provided for @errorSendGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar solicitud: {error}'**
  String errorSendGeneric(String error);

  /// No description provided for @errorWithMessage.
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @goBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get goBack;

  /// No description provided for @sendComment.
  ///
  /// In es, this message translates to:
  /// **'Enviar comentario'**
  String get sendComment;

  /// No description provided for @previousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get nextMonth;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @dismissError.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get dismissError;

  /// No description provided for @noPermissions.
  ///
  /// In es, this message translates to:
  /// **'Sin permisos'**
  String get noPermissions;

  /// No description provided for @roleSelect.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get roleSelect;

  /// No description provided for @newIncident.
  ///
  /// In es, this message translates to:
  /// **'Nueva incidencia'**
  String get newIncident;

  /// No description provided for @validatorPasswordDigit.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe contener al menos un número'**
  String get validatorPasswordDigit;

  /// No description provided for @validatorConfirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor, confirma tu contraseña'**
  String get validatorConfirmPasswordRequired;

  /// No description provided for @validatorNumberInvalid.
  ///
  /// In es, this message translates to:
  /// **'{fieldName} debe ser un número válido'**
  String validatorNumberInvalid(String fieldName);

  /// No description provided for @thisField.
  ///
  /// In es, this message translates to:
  /// **'Este campo'**
  String get thisField;

  /// No description provided for @theDate.
  ///
  /// In es, this message translates to:
  /// **'La fecha'**
  String get theDate;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada correctamente'**
  String get passwordChanged;

  /// No description provided for @changePasswordError.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar contraseña'**
  String get changePasswordError;

  /// No description provided for @passwordRequirements.
  ///
  /// In es, this message translates to:
  /// **'Mín. 8 caracteres, 1 mayúscula, 1 minúscula, 1 número'**
  String get passwordRequirements;

  /// No description provided for @approveBooking.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approveBooking;

  /// No description provided for @bookingApproved.
  ///
  /// In es, this message translates to:
  /// **'Reserva aprobada'**
  String get bookingApproved;

  /// No description provided for @approveBookingConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Aprobar esta reserva?'**
  String get approveBookingConfirm;

  /// No description provided for @approveDocument.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approveDocument;

  /// No description provided for @rejectDocument.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get rejectDocument;

  /// No description provided for @rejectionReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo'**
  String get rejectionReason;

  /// No description provided for @documentApproved.
  ///
  /// In es, this message translates to:
  /// **'Documento aprobado'**
  String get documentApproved;

  /// No description provided for @documentRejected.
  ///
  /// In es, this message translates to:
  /// **'Documento rechazado'**
  String get documentRejected;

  /// No description provided for @pendingApproval.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de aprobación'**
  String get pendingApproval;

  /// No description provided for @approved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get rejected;

  /// No description provided for @adminUsers.
  ///
  /// In es, this message translates to:
  /// **'Gestión de usuarios'**
  String get adminUsers;

  /// No description provided for @manageUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get manageUsers;

  /// No description provided for @resetPassword.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get resetPassword;

  /// No description provided for @resetPasswordConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Restablecer la contraseña de {name}?'**
  String resetPasswordConfirm(String name);

  /// No description provided for @newPasswordFor.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña para {name}'**
  String newPasswordFor(String name);

  /// No description provided for @passwordResetSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña restablecida'**
  String get passwordResetSuccess;

  /// No description provided for @toggleActive.
  ///
  /// In es, this message translates to:
  /// **'Activar/Desactivar'**
  String get toggleActive;

  /// No description provided for @userActivated.
  ///
  /// In es, this message translates to:
  /// **'Usuario activado'**
  String get userActivated;

  /// No description provided for @userDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Usuario desactivado'**
  String get userDeactivated;

  /// No description provided for @changeRole.
  ///
  /// In es, this message translates to:
  /// **'Cambiar rol'**
  String get changeRole;

  /// No description provided for @roleChanged.
  ///
  /// In es, this message translates to:
  /// **'Rol actualizado'**
  String get roleChanged;

  /// No description provided for @noUsers.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios'**
  String get noUsers;

  /// No description provided for @searchUsers.
  ///
  /// In es, this message translates to:
  /// **'Buscar usuarios...'**
  String get searchUsers;

  /// No description provided for @activeUsers.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get activeUsers;

  /// No description provided for @inactiveUsers.
  ///
  /// In es, this message translates to:
  /// **'Inactivos'**
  String get inactiveUsers;

  /// No description provided for @allUsers.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allUsers;

  /// No description provided for @manageZones.
  ///
  /// In es, this message translates to:
  /// **'Gestión de zonas'**
  String get manageZones;

  /// No description provided for @zoneName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la zona'**
  String get zoneName;

  /// No description provided for @zoneDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get zoneDescription;

  /// No description provided for @zoneCapacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad máxima'**
  String get zoneCapacity;

  /// No description provided for @zoneRequiresApproval.
  ///
  /// In es, this message translates to:
  /// **'Requiere aprobación'**
  String get zoneRequiresApproval;

  /// No description provided for @zoneActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get zoneActive;

  /// No description provided for @createZone.
  ///
  /// In es, this message translates to:
  /// **'Crear zona'**
  String get createZone;

  /// No description provided for @editZone.
  ///
  /// In es, this message translates to:
  /// **'Editar zona'**
  String get editZone;

  /// No description provided for @deleteZone.
  ///
  /// In es, this message translates to:
  /// **'Eliminar zona'**
  String get deleteZone;

  /// No description provided for @deleteZoneConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta zona?'**
  String get deleteZoneConfirm;

  /// No description provided for @zoneCreated.
  ///
  /// In es, this message translates to:
  /// **'Zona creada'**
  String get zoneCreated;

  /// No description provided for @zoneUpdated.
  ///
  /// In es, this message translates to:
  /// **'Zona actualizada'**
  String get zoneUpdated;

  /// No description provided for @zoneDeleted.
  ///
  /// In es, this message translates to:
  /// **'Zona eliminada'**
  String get zoneDeleted;

  /// No description provided for @noZones.
  ///
  /// In es, this message translates to:
  /// **'No hay zonas'**
  String get noZones;

  /// No description provided for @maxBookingHours.
  ///
  /// In es, this message translates to:
  /// **'Máx. horas por reserva'**
  String get maxBookingHours;

  /// No description provided for @maxBookingsPerDay.
  ///
  /// In es, this message translates to:
  /// **'Máx. reservas por día'**
  String get maxBookingsPerDay;

  /// No description provided for @advanceBookingDays.
  ///
  /// In es, this message translates to:
  /// **'Días de reserva anticipada'**
  String get advanceBookingDays;

  /// No description provided for @availableFrom.
  ///
  /// In es, this message translates to:
  /// **'Disponible desde'**
  String get availableFrom;

  /// No description provided for @availableUntil.
  ///
  /// In es, this message translates to:
  /// **'Disponible hasta'**
  String get availableUntil;

  /// No description provided for @inactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get inactive;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
