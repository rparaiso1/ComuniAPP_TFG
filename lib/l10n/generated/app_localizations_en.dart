// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ComuniApp';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get userFallback => 'User';

  @override
  String get navHome => 'Home';

  @override
  String get navBoard => 'Board';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navIncidents => 'Incidents';

  @override
  String get navDocs => 'Docs';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get rolePresident => 'President';

  @override
  String get roleNeighbor => 'Neighbor';

  @override
  String get login => 'Log in';

  @override
  String get loginError => 'Login error';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get welcome => 'Welcome';

  @override
  String get communityManagement => 'Community Management';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get thePassword => 'The password';

  @override
  String get hasInvitation => 'Have an invitation? Register here';

  @override
  String get splashTitle => 'ComuniApp';

  @override
  String get registerTitle => 'Register with Invitation';

  @override
  String get enterInvitationToken => 'Enter the invitation token';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registrationComplete => 'Registration Complete!';

  @override
  String accountCreatedMessage(String email, String dwelling) {
    return 'Your account has been created successfully.\n\nEmail: $email\nDwelling: $dwelling\n\nYou can now log in to the app.';
  }

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get registrationError => 'Registration error';

  @override
  String get connectionError => 'Connection error';

  @override
  String get haveInvitation => 'Have an invitation?';

  @override
  String get invitationExplanation =>
      'If your community administrator has invited you, you will have received an invitation code.\n\nEnter it below to verify your identity and create your account.';

  @override
  String get invitationTokenLabel => 'Invitation token';

  @override
  String get invitationTokenHint => 'Paste your invitation code here';

  @override
  String get verifyInvitation => 'Verify Invitation';

  @override
  String get validInvitation => 'Valid Invitation';

  @override
  String get nameLabel => 'Name:';

  @override
  String get emailLabel => 'Email:';

  @override
  String get dwellingLabel => 'Dwelling:';

  @override
  String get roleLabel => 'Role:';

  @override
  String get choosePassword => 'Choose your password';

  @override
  String get minChars => 'Minimum 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get myProfile => 'My Profile';

  @override
  String get emailField => 'Email';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get dwelling => 'Dwelling';

  @override
  String get role => 'Role';

  @override
  String get memberSince => 'Member since';

  @override
  String get profileEditHint =>
      'To modify your information, tap the edit icon. A request will be sent to the administrator for approval.';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String requestChange(String fieldName) {
    return 'Request change for $fieldName';
  }

  @override
  String currentValue(String value) {
    return 'Current value: $value';
  }

  @override
  String get newDesiredValue => 'New desired value';

  @override
  String get changeRequestNote =>
      'A request will be sent to the administrator for review.';

  @override
  String get cancel => 'Cancel';

  @override
  String get sendRequest => 'Send request';

  @override
  String changeRequestSent(String fieldName) {
    return '$fieldName change request sent successfully';
  }

  @override
  String get changeRequestError => 'Error sending request';

  @override
  String get active => 'Active';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get activitySummary => 'Activity summary';

  @override
  String get bookings => 'Bookings';

  @override
  String get incidents => 'Incidents';

  @override
  String get board => 'Board';

  @override
  String get documents => 'Documents';

  @override
  String get invitations => 'Invitations';

  @override
  String get importData => 'Import data';

  @override
  String get publications => 'Posts';

  @override
  String get openIncidents => 'Open incidents';

  @override
  String get loadPostsError => 'Error loading posts';

  @override
  String get boardTitle => 'Board';

  @override
  String get noPosts => 'No posts';

  @override
  String get postsWillAppear => 'Community posts will appear here';

  @override
  String get deletePost => 'Delete post';

  @override
  String get deletePostConfirm => 'Are you sure you want to delete this post?';

  @override
  String get delete => 'Delete';

  @override
  String get publish => 'Publish';

  @override
  String get newPost => 'New post';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get completeTitleContent => 'Complete title and content';

  @override
  String get announcementDetail => 'Announcement detail';

  @override
  String get loadAnnouncementError => 'Error loading the announcement';

  @override
  String get retry => 'Retry';

  @override
  String get published => 'Published';

  @override
  String get updated => 'Updated';

  @override
  String get loadBookingsError => 'Error loading bookings';

  @override
  String get noBookings => 'No bookings';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String cancelBookingConfirm(String zoneName) {
    return 'Are you sure you want to cancel the booking for $zoneName?';
  }

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get reasonExample => 'E.g.: Change of plans';

  @override
  String get back => 'Back';

  @override
  String get bookingCancelled => 'Booking cancelled';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get zone => 'Zone';

  @override
  String get cancelBookingTooltip => 'Cancel booking';

  @override
  String reason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get zoneTypePool => 'Pool';

  @override
  String get zoneTypeCourt => 'Sports court';

  @override
  String get zoneTypeGym => 'Gym';

  @override
  String get zoneTypeRoom => 'Lounge / Room';

  @override
  String get zoneTypePlayground => 'Playground';

  @override
  String get zoneTypeBbq => 'BBQ area';

  @override
  String get zoneRequired => 'Zone required';

  @override
  String get selectZone => 'Select a zone to book.';

  @override
  String get datesRequired => 'Dates required';

  @override
  String get selectDates => 'Select start and end dates.';

  @override
  String get invalidDates => 'Invalid dates';

  @override
  String get endAfterStart => 'The end date must be after the start.';

  @override
  String get createBookingError => 'Error creating booking';

  @override
  String get bookingCreated => 'Booking created successfully';

  @override
  String get error => 'Error';

  @override
  String get newBooking => 'New Booking';

  @override
  String get noZonesAvailable => 'No zones available';

  @override
  String get adminMustCreateZones =>
      'The administrator must create zones first';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesExample => 'E.g.: Birthday party booking';

  @override
  String get creating => 'Creating...';

  @override
  String get createBooking => 'Create booking';

  @override
  String get tapToSelect => 'tap to select';

  @override
  String get loadIncidentsError => 'Error loading incidents';

  @override
  String get noIncidents => 'No incidents';

  @override
  String get deleteIncident => 'Delete incident';

  @override
  String get deleteIncidentConfirm =>
      'Are you sure you want to delete this incident?';

  @override
  String get incidentsTitle => 'Incidents';

  @override
  String get newIncidentDialog => 'New Incident';

  @override
  String get description => 'Description';

  @override
  String get locationOptional => 'Location (optional)';

  @override
  String get locationExample => 'E.g.: Building A, Floor 3';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get priorityLowEmoji => 'Low';

  @override
  String get priorityMediumEmoji => 'Medium';

  @override
  String get priorityHighEmoji => 'High';

  @override
  String get completeTitleDescription => 'Complete title and description';

  @override
  String get create => 'Create';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusInProgressLabel => 'In progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusClosed => 'Closed';

  @override
  String get incidentDetail => 'Incident detail';

  @override
  String get loadIncidentError => 'Error loading the incident';

  @override
  String get reportedBy => 'Reported by';

  @override
  String get location => 'Location';

  @override
  String get assignedTo => 'Assigned to';

  @override
  String get created => 'Created';

  @override
  String get actions => 'Actions';

  @override
  String get inProgress => 'In progress';

  @override
  String get resolve => 'Resolve';

  @override
  String get close => 'Close';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get newIncidentTitle => 'New incident';

  @override
  String get describeProblem => 'Briefly describe the problem';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get detailProblem =>
      'Detail the problem with as much information as possible';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get locationExampleLong => 'E.g.: Building 3, floor 2 / Pool / Garage';

  @override
  String get submitIncident => 'Submit incident';

  @override
  String get incidentCreated => 'Incident created successfully';

  @override
  String get loadDocsError => 'Error loading documents';

  @override
  String get noDocuments => 'No documents';

  @override
  String get noDocsInCategory => 'No documents found in this category';

  @override
  String get docsWillAppear => 'Community documents will appear here';

  @override
  String get deleteDocument => 'Delete document';

  @override
  String get deleteDocConfirm =>
      'Are you sure you want to delete this document?';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get catAll => 'All';

  @override
  String get catMinutes => 'Minutes';

  @override
  String get catRegulations => 'Regulations';

  @override
  String get catInvoices => 'Invoices';

  @override
  String get catMisc => 'Misc';

  @override
  String get catDocuments => 'Documents';

  @override
  String get downloadDocument => 'Download document';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get fileUrl => 'File URL';

  @override
  String get fileUrlHint => 'https://...';

  @override
  String get fileType => 'File type';

  @override
  String get fileTypePdf => 'PDF';

  @override
  String get fileTypeWord => 'Word';

  @override
  String get fileTypeExcel => 'Excel';

  @override
  String get fileTypeImage => 'Image';

  @override
  String get fileTypeOther => 'Other';

  @override
  String get category => 'Category';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get completeTitleUrl => 'Complete title and URL';

  @override
  String get upload => 'Upload';

  @override
  String get notifications => 'Notifications';

  @override
  String get allMarkedRead => 'All marked as read';

  @override
  String get markReadError => 'Error marking notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get deleteNotifications => 'Delete notifications';

  @override
  String get deleteAllNotificationsConfirm =>
      'Do you want to delete all notifications?';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get timeNow => 'Now';

  @override
  String timeMinAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHourAgo(int count) {
    return '$count h ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get calendar => 'Calendar';

  @override
  String get goToToday => 'Go to today';

  @override
  String get noEvents => 'No events';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get dayMon => 'M';

  @override
  String get dayTue => 'T';

  @override
  String get dayWed => 'W';

  @override
  String get dayThu => 'T';

  @override
  String get dayFri => 'F';

  @override
  String get daySat => 'S';

  @override
  String get daySun => 'S';

  @override
  String get dayMonFull => 'Monday';

  @override
  String get dayTueFull => 'Tuesday';

  @override
  String get dayWedFull => 'Wednesday';

  @override
  String get dayThuFull => 'Thursday';

  @override
  String get dayFriFull => 'Friday';

  @override
  String get daySatFull => 'Saturday';

  @override
  String get daySunFull => 'Sunday';

  @override
  String get monthJanuaryLower => 'january';

  @override
  String get monthFebruaryLower => 'february';

  @override
  String get monthMarchLower => 'march';

  @override
  String get monthAprilLower => 'april';

  @override
  String get monthMayLower => 'may';

  @override
  String get monthJuneLower => 'june';

  @override
  String get monthJulyLower => 'july';

  @override
  String get monthAugustLower => 'august';

  @override
  String get monthSeptemberLower => 'september';

  @override
  String get monthOctoberLower => 'october';

  @override
  String get monthNovemberLower => 'november';

  @override
  String get monthDecemberLower => 'december';

  @override
  String get importTitle => 'Import data';

  @override
  String get importDescription =>
      'Import neighbors, presidents, board members, tenants and common areas from an Excel (.xlsx) or CSV file. The first row must contain headers.';

  @override
  String get importUsers => 'Import users';

  @override
  String get importUsersSubtitle => 'Neighbors, presidents, board, tenants';

  @override
  String get colEmail => 'email (required)';

  @override
  String get colName => 'name (required)';

  @override
  String get colRole => 'role (ADMIN/PRESIDENT/NEIGHBOR)';

  @override
  String get colPhone => 'phone (optional)';

  @override
  String get colDwelling => 'dwelling (optional)';

  @override
  String get colPassword => 'password (optional, default: ComuniApp2024)';

  @override
  String get importZones => 'Import common areas';

  @override
  String get importZonesSubtitle => 'Pool, padel court, room, gym...';

  @override
  String get colZoneName => 'name (required)';

  @override
  String get colZoneType => 'type (required: pool/court/room/gym/garden)';

  @override
  String get colZoneDesc => 'description (optional)';

  @override
  String get colZoneCapacity => 'capacity (optional, number)';

  @override
  String get colZoneApproval => 'requires_approval (optional: yes/no)';

  @override
  String get importResult => 'Import result';

  @override
  String get fileReadError => 'Error reading the file';

  @override
  String get serverError => 'Server error';

  @override
  String get expectedColumns => 'Expected columns:';

  @override
  String get importing => 'Importing...';

  @override
  String get selectFile => 'Select file';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get fileSelected => 'File selected';

  @override
  String get fileTooLarge => 'File cannot exceed 10 MB';

  @override
  String get completeTitleFile => 'Select a file and enter a title';

  @override
  String get uploadSuccess => 'Document uploaded successfully';

  @override
  String get uploadError => 'Error uploading document';

  @override
  String get maxFileSize => 'Max 10 MB — PDF, Word, Excel, images';

  @override
  String get tapToSelectFile => 'Tap to select a file';

  @override
  String get changeFile => 'Change file';

  @override
  String get totalRows => 'Total rows';

  @override
  String get imported => 'Imported';

  @override
  String get errors => 'Errors';

  @override
  String get errorDetails => 'Error details:';

  @override
  String get invitationsManagement => 'Invitation Management';

  @override
  String get emailAndNameRequired => 'Email and name are required';

  @override
  String get loadInvitationsError => 'Error loading invitations';

  @override
  String get invitationCreated => 'Invitation created';

  @override
  String invitationFor(String name) {
    return 'Invitation for $name created successfully.';
  }

  @override
  String get registrationToken => 'Registration token:';

  @override
  String get shareTokenHint =>
      'Share this token with the neighbor so they can register.';

  @override
  String get tokenCopied => 'Token copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get accept => 'Accept';

  @override
  String get revokeInvitation => 'Revoke invitation';

  @override
  String get revokeInvitationConfirm =>
      'Are you sure you want to delete this invitation?';

  @override
  String get invitationDeleted => 'Invitation deleted';

  @override
  String get noAccess => 'No access';

  @override
  String get noAccessMessage => 'Only administrators or presidents can access.';

  @override
  String get newInvitation => 'New invitation';

  @override
  String get emailRequired => 'Email *';

  @override
  String get fullNameRequired => 'Full name *';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get dwellingOptional => 'Dwelling (optional)';

  @override
  String get dwellingExample => 'E.g.: Block A - 3B';

  @override
  String get creatingInvitation => 'Creating...';

  @override
  String get createInvitation => 'Create invitation';

  @override
  String get howItWorks => 'How it works';

  @override
  String get step1 => 'Fill in the details and create the invitation';

  @override
  String get step2 => 'Share the generated token with the neighbor';

  @override
  String get step3 =>
      'The neighbor enters the token on the registration screen';

  @override
  String get step4 => 'They create their password and have app access';

  @override
  String get noInvitationsYet => 'No invitations yet';

  @override
  String get invitationsSection => 'Invitations';

  @override
  String get statusUsed => 'USED';

  @override
  String get statusExpired => 'EXPIRED';

  @override
  String get statusPendingUpper => 'PENDING';

  @override
  String get statusApprovedUpper => 'APPROVED';

  @override
  String token(String token) {
    return 'Token: $token';
  }

  @override
  String get copyToken => 'Copy token';

  @override
  String get tokenCopiedShort => 'Token copied';

  @override
  String get revoke => 'Revoke';

  @override
  String get errorConnection =>
      'Could not connect to server. Check your internet connection and try again.';

  @override
  String get errorInvalidCredentials =>
      'Invalid email or password. Check your credentials and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorForbidden =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorDuplicate =>
      'A record with this data already exists. Check the information.';

  @override
  String get errorBookingConflict =>
      'There is already a booking at that time. Choose another time.';

  @override
  String get errorValidation =>
      'The data entered is not valid. Check the information.';

  @override
  String get errorServer =>
      'The server is experiencing problems. Try again later.';

  @override
  String get errorUnexpectedResponse =>
      'Unexpected response received from server. Try again.';

  @override
  String get errorGeneric => 'An unexpected error occurred. Try again.';

  @override
  String get confirm => 'Confirm';

  @override
  String get noConnectionOffline =>
      'No connection. Some data may not be up to date.';

  @override
  String deleteItem(String itemName) {
    return 'Delete $itemName';
  }

  @override
  String get deleteItemConfirm =>
      'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get loading => 'Loading...';

  @override
  String get emptyBookings => 'No bookings';

  @override
  String get emptyBookingsDesc =>
      'You have no active bookings. Book a common area to get started.';

  @override
  String get emptyBookingsAction => 'New booking';

  @override
  String get emptyIncidents => 'All good';

  @override
  String get emptyIncidentsDesc => 'No incidents reported. Excellent!';

  @override
  String get emptyIncidentsAction => 'Report incident';

  @override
  String get emptyDocuments => 'No documents';

  @override
  String get emptyDocumentsDesc => 'No documents available at this time.';

  @override
  String get emptyPosts => 'No posts';

  @override
  String get emptyPostsDesc => 'No posts on the board yet.';

  @override
  String get emptyPostsAction => 'New post';

  @override
  String get emptySearch => 'No results';

  @override
  String get emptySearchDesc => 'No results found for your search.';

  @override
  String get errorState => 'Something went wrong';

  @override
  String get errorStateDesc =>
      'We couldn\'t load the information. Please try again.';

  @override
  String get noConnection => 'No connection';

  @override
  String get noConnectionDesc =>
      'Check your internet connection and try again.';

  @override
  String get validatorEmailRequired => 'Email is required';

  @override
  String get validatorEmailInvalid => 'Please enter a valid email address';

  @override
  String get validatorPasswordRequired => 'Password is required';

  @override
  String validatorPasswordMinLength(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get validatorPasswordMinLength8 =>
      'Password must be at least 8 characters';

  @override
  String get validatorPasswordUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get validatorPasswordLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get validatorPasswordNumber =>
      'Password must contain at least one number';

  @override
  String get validatorConfirmPassword => 'Please confirm your password';

  @override
  String validatorFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String validatorFieldMinLength(String fieldName, int minLength) {
    return '$fieldName must be at least $minLength characters';
  }

  @override
  String validatorFieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName cannot exceed $maxLength characters';
  }

  @override
  String get validatorPhoneRequired => 'Phone number is required';

  @override
  String get validatorPhoneInvalid =>
      'Please enter a valid phone number (e.g. 612345678)';

  @override
  String validatorNumericRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String validatorNumericInvalid(String fieldName) {
    return '$fieldName must be a valid number';
  }

  @override
  String validatorNumberRange(String fieldName, int min, int max) {
    return '$fieldName must be between $min and $max';
  }

  @override
  String validatorDateRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String validatorDateFuture(String fieldName) {
    return '$fieldName must be in the future';
  }

  @override
  String get validatorUrlRequired => 'URL is required';

  @override
  String get validatorUrlInvalid => 'Please enter a valid URL';

  @override
  String get validatorPostalCodeRequired => 'Postal code is required';

  @override
  String get validatorPostalCodeInvalid =>
      'Please enter a valid postal code (5 digits)';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'System';

  @override
  String get exportData => 'Export data';

  @override
  String get exportUsers => 'Users';

  @override
  String get exportBookings => 'Bookings';

  @override
  String get exportIncidents => 'Incidents';

  @override
  String get exportDocuments => 'Documents';

  @override
  String get exportZones => 'Zones';

  @override
  String get exportDownloading => 'Downloading...';

  @override
  String get exportSuccess => 'Export downloaded successfully';

  @override
  String get exportError => 'Error exporting data';

  @override
  String get exportWebOnly =>
      'Direct download is only available on the web version';

  @override
  String get exportDescription =>
      'Download your community data in CSV or PDF format';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get requestTimeout => 'The request took too long. Please try again';

  @override
  String pdfExportTitle(String resource) {
    return '$resource Report';
  }

  @override
  String get status => 'Status';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End';

  @override
  String get notes => 'Notes';

  @override
  String get createdAt => 'Created';

  @override
  String get uploadedBy => 'Uploaded by';

  @override
  String get userName => 'User';

  @override
  String get budget => 'Budget';

  @override
  String get budgetTitle => 'Community Budget';

  @override
  String get budgetSubtitle => 'Financial transparency for your community';

  @override
  String get budgetTotalIncome => 'Total income';

  @override
  String get budgetTotalExpense => 'Total expenses';

  @override
  String get budgetBalance => 'Balance';

  @override
  String get budgetEntries => 'Transactions';

  @override
  String get budgetNoData => 'No data for this year';

  @override
  String get budgetUploadCsv => 'Import CSV';

  @override
  String budgetUploadSuccess(int count) {
    return 'Imported $count records successfully';
  }

  @override
  String budgetUploadError(String error) {
    return 'Import error: $error';
  }

  @override
  String budgetUploadErrors(int imported, int total, int count) {
    return 'Imported $imported of $total rows. Errors: $count';
  }

  @override
  String get budgetDeleteEntry => 'Delete entry';

  @override
  String get budgetDeleteConfirm => 'Delete this budget entry?';

  @override
  String get budgetDeleteSuccess => 'Entry deleted';

  @override
  String get budgetPieTitle => 'Expense distribution';

  @override
  String get budgetBarTitle => 'Monthly evolution';

  @override
  String get budgetIncome => 'Income';

  @override
  String get budgetExpense => 'Expense';

  @override
  String get budgetSelectYear => 'Year';

  @override
  String get budgetCategory => 'Category';

  @override
  String get budgetConcept => 'Concept';

  @override
  String get budgetAmount => 'Amount';

  @override
  String get budgetType => 'Type';

  @override
  String get budgetProvider => 'Provider';

  @override
  String get budgetDetail => 'Detail';

  @override
  String get budgetDate => 'Date';

  @override
  String get budgetAllEntries => 'All entries';

  @override
  String get budgetFilterAll => 'All';

  @override
  String get budgetFilterIncome => 'Income';

  @override
  String get budgetFilterExpense => 'Expenses';

  @override
  String get budgetNoPieData => 'No expenses this year';

  @override
  String get budgetDeleteAll => 'Delete all';

  @override
  String get budgetDeleteAllConfirm =>
      'Delete all entries for this year? This action cannot be undone.';

  @override
  String get navBudget => 'Budget';

  @override
  String get allZones => 'All';

  @override
  String get filterByZone => 'Filter by zone';

  @override
  String get myBookings => 'My bookings';

  @override
  String get allStatuses => 'All';

  @override
  String get allPriorities => 'All';

  @override
  String get filterByStatus => 'Filter by status';

  @override
  String get filterByPriority => 'Filter by priority';

  @override
  String get myIncidents => 'My incidents';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get send => 'Send';

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No comments yet';

  @override
  String get commentAdded => 'Comment added';

  @override
  String get deleteComment => 'Delete comment';

  @override
  String get deleteCommentConfirm => 'Delete this comment?';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Unlike';

  @override
  String get likes => 'Likes';

  @override
  String get errorToggleLike => 'Failed to toggle like. Please try again.';

  @override
  String get errorAddComment => 'Failed to add comment. Please try again.';

  @override
  String get errorDeleteComment =>
      'Failed to delete comment. Please try again.';

  @override
  String errorInitApp(String error) {
    return 'Error initializing app: $error';
  }

  @override
  String profileChangeTitle(String field) {
    return 'Profile data change request: $field';
  }

  @override
  String profileChangeDescription(
      String field, String currentValue, String requestedValue) {
    return 'User requests to change \"$field\" from \"$currentValue\" to \"$requestedValue\".';
  }

  @override
  String get errorSendChangeRequest => 'Failed to send change request';

  @override
  String errorSendGeneric(String error) {
    return 'Error sending request: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get goBack => 'Go back';

  @override
  String get sendComment => 'Send comment';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get dismissError => 'Dismiss';

  @override
  String get noPermissions => 'No permissions';

  @override
  String get roleSelect => 'Role';

  @override
  String get newIncident => 'New incident';

  @override
  String get validatorPasswordDigit =>
      'Password must contain at least one number';

  @override
  String get validatorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String validatorNumberInvalid(String fieldName) {
    return '$fieldName must be a valid number';
  }

  @override
  String get thisField => 'This field';

  @override
  String get theDate => 'The date';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get changePasswordError => 'Error changing password';

  @override
  String get passwordRequirements =>
      'Min. 8 characters, 1 uppercase, 1 lowercase, 1 number';

  @override
  String get approveBooking => 'Approve';

  @override
  String get bookingApproved => 'Booking approved';

  @override
  String get approveBookingConfirm => 'Approve this booking?';

  @override
  String get approveDocument => 'Approve';

  @override
  String get rejectDocument => 'Reject';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get documentApproved => 'Document approved';

  @override
  String get documentRejected => 'Document rejected';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get adminUsers => 'User management';

  @override
  String get manageUsers => 'Users';

  @override
  String get resetPassword => 'Reset password';

  @override
  String resetPasswordConfirm(String name) {
    return 'Reset password for $name?';
  }

  @override
  String newPasswordFor(String name) {
    return 'New password for $name';
  }

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get toggleActive => 'Activate/Deactivate';

  @override
  String get userActivated => 'User activated';

  @override
  String get userDeactivated => 'User deactivated';

  @override
  String get changeRole => 'Change role';

  @override
  String get roleChanged => 'Role updated';

  @override
  String get noUsers => 'No users';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get activeUsers => 'Active';

  @override
  String get inactiveUsers => 'Inactive';

  @override
  String get allUsers => 'All';

  @override
  String get manageZones => 'Zone management';

  @override
  String get zoneName => 'Zone name';

  @override
  String get zoneDescription => 'Description';

  @override
  String get zoneCapacity => 'Max capacity';

  @override
  String get zoneRequiresApproval => 'Requires approval';

  @override
  String get zoneActive => 'Active';

  @override
  String get createZone => 'Create zone';

  @override
  String get editZone => 'Edit zone';

  @override
  String get deleteZone => 'Delete zone';

  @override
  String get deleteZoneConfirm => 'Delete this zone?';

  @override
  String get zoneCreated => 'Zone created';

  @override
  String get zoneUpdated => 'Zone updated';

  @override
  String get zoneDeleted => 'Zone deleted';

  @override
  String get noZones => 'No zones';

  @override
  String get maxBookingHours => 'Max hours per booking';

  @override
  String get maxBookingsPerDay => 'Max bookings per day';

  @override
  String get advanceBookingDays => 'Advance booking days';

  @override
  String get availableFrom => 'Available from';

  @override
  String get availableUntil => 'Available until';

  @override
  String get inactive => 'Inactive';

  @override
  String get save => 'Save';
}
