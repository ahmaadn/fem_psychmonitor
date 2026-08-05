import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FemMonitor'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your daily companion to gently understand\nyour emotions and cycle.'**
  String get appTagline;

  /// No description provided for @swipeUpToStart.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to start'**
  String get swipeUpToStart;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FemMonitor'**
  String get welcomeToApp;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Understand your emotions, one voice at a time.'**
  String get onboardingHeadline;

  /// No description provided for @chooseSignInMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how to sign in and start monitoring your emotions and cycle.'**
  String get chooseSignInMethod;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @microphonePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Microphone & Privacy'**
  String get microphonePrivacy;

  /// No description provided for @appNeedsMicAccess.
  ///
  /// In en, this message translates to:
  /// **'The app needs microphone access to record your voice and store recordings locally. Data is used only for emotion analysis.'**
  String get appNeedsMicAccess;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @notGranted.
  ///
  /// In en, this message translates to:
  /// **'Not Granted'**
  String get notGranted;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request Permission'**
  String get requestPermission;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @quickQuestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Questions'**
  String get quickQuestions;

  /// No description provided for @selectMoodToHelp.
  ///
  /// In en, this message translates to:
  /// **'Select your current mood to help with analysis'**
  String get selectMoodToHelp;

  /// No description provided for @selectDominantEmotion.
  ///
  /// In en, this message translates to:
  /// **'Select Dominant Emotion'**
  String get selectDominantEmotion;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @anger.
  ///
  /// In en, this message translates to:
  /// **'Anger'**
  String get anger;

  /// No description provided for @fearful.
  ///
  /// In en, this message translates to:
  /// **'Fearful'**
  String get fearful;

  /// No description provided for @disgust.
  ///
  /// In en, this message translates to:
  /// **'Disgust'**
  String get disgust;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverCalendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get discoverCalendarTab;

  /// No description provided for @discoverJournalTab.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get discoverJournalTab;

  /// No description provided for @discoverEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No recordings on this date.'**
  String get discoverEmptyDay;

  /// No description provided for @discoverRecordMoodCta.
  ///
  /// In en, this message translates to:
  /// **'I feel today…'**
  String get discoverRecordMoodCta;

  /// No description provided for @discoverEmotionDistribution.
  ///
  /// In en, this message translates to:
  /// **'Emotion distribution'**
  String get discoverEmotionDistribution;

  /// No description provided for @discoverScoreHistory.
  ///
  /// In en, this message translates to:
  /// **'Mental score history'**
  String get discoverScoreHistory;

  /// No description provided for @discoverRecordingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get discoverRecordingsLabel;

  /// No description provided for @discoverPrevYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get discoverPrevYear;

  /// No description provided for @discoverNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get discoverNextYear;

  /// No description provided for @discoverNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get discoverNoData;

  /// No description provided for @angry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get angry;

  /// No description provided for @briefNote.
  ///
  /// In en, this message translates to:
  /// **'Brief Note'**
  String get briefNote;

  /// No description provided for @writeWhatYouWant.
  ///
  /// In en, this message translates to:
  /// **'Write what you\'d like to note...'**
  String get writeWhatYouWant;

  /// No description provided for @startDemoRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Demo Recording'**
  String get startDemoRecording;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @continueCheckin.
  ///
  /// In en, this message translates to:
  /// **'Continue your daily check-in to maintain emotional balance.'**
  String get continueCheckin;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQ;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountYet;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey'**
  String get startYourJourney;

  /// No description provided for @createAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Create an account to record daily emotions\nand understand your cycle better.'**
  String get createAccountDesc;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Evelyn Thorne'**
  String get fullNameHint;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInLink;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to our Privacy Policy and Terms of Service.'**
  String get termsAgreement;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @enterEmailForRecovery.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a recovery link.'**
  String get enterEmailForRecovery;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @signInHere.
  ///
  /// In en, this message translates to:
  /// **'Sign in here'**
  String get signInHere;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String goodEvening(String name);

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling right now?'**
  String get howAreYouFeeling;

  /// No description provided for @calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calm;

  /// No description provided for @moodDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re feeling calm and balanced. Keep this peace going with relaxation and self-care activities.'**
  String get moodDescription;

  /// No description provided for @recordYourVoice.
  ///
  /// In en, this message translates to:
  /// **'Record Your Voice'**
  String get recordYourVoice;

  /// No description provided for @letAiRecognize.
  ///
  /// In en, this message translates to:
  /// **'Let AI recognize your true emotions'**
  String get letAiRecognize;

  /// No description provided for @uploadAudio.
  ///
  /// In en, this message translates to:
  /// **'Upload Audio'**
  String get uploadAudio;

  /// No description provided for @currentMood.
  ///
  /// In en, this message translates to:
  /// **'CURRENT MOOD'**
  String get currentMood;

  /// No description provided for @totalRecordings.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RECORDINGS'**
  String get totalRecordings;

  /// No description provided for @checkInStreak.
  ///
  /// In en, this message translates to:
  /// **'Your Check-in Streak'**
  String get checkInStreak;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String daysCount(int count);

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SUMMARY'**
  String get todaysSummary;

  /// No description provided for @failedToReadAudioPath.
  ///
  /// In en, this message translates to:
  /// **'Failed to read audio file path.'**
  String get failedToReadAudioPath;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @monthlyReflection.
  ///
  /// In en, this message translates to:
  /// **'Monthly Reflection'**
  String get monthlyReflection;

  /// No description provided for @monthDominatedBy.
  ///
  /// In en, this message translates to:
  /// **'This month is dominated by '**
  String get monthDominatedBy;

  /// No description provided for @calmEmotion.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calmEmotion;

  /// No description provided for @monthEndNote.
  ///
  /// In en, this message translates to:
  /// **' emotions, with small energy spikes on weekends.'**
  String get monthEndNote;

  /// No description provided for @recentRecordings.
  ///
  /// In en, this message translates to:
  /// **'Recent Recordings'**
  String get recentRecordings;

  /// No description provided for @liveRecordingHistory.
  ///
  /// In en, this message translates to:
  /// **'Live\nRecording History'**
  String get liveRecordingHistory;

  /// No description provided for @liveRecordingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your real-time\nemotion recordings'**
  String get liveRecordingSubtitle;

  /// No description provided for @uploadedAudioHistory.
  ///
  /// In en, this message translates to:
  /// **'Uploaded\nAudio History'**
  String get uploadedAudioHistory;

  /// No description provided for @uploadedAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore your uploaded\naudio journals'**
  String get uploadedAudioSubtitle;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editImage.
  ///
  /// In en, this message translates to:
  /// **'Edit Image'**
  String get editImage;

  /// No description provided for @joinedSince.
  ///
  /// In en, this message translates to:
  /// **'Joined since January 2024'**
  String get joinedSince;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appGuide.
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get appGuide;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @licenseLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2024 FemPsychMonitor. All rights reserved.'**
  String get licenseLegalese;

  /// No description provided for @goOnBoarding.
  ///
  /// In en, this message translates to:
  /// **'Go On Boarding'**
  String get goOnBoarding;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthValue.
  ///
  /// In en, this message translates to:
  /// **'March 15, 1998'**
  String get dateOfBirthValue;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changeAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Change your account password'**
  String get changeAccountPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter old password'**
  String get enterOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get minCharacters;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @repeatNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatNewPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @minCharsRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get minCharsRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @veryWeak.
  ///
  /// In en, this message translates to:
  /// **'Very Weak'**
  String get veryWeak;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips'**
  String get securityTips;

  /// No description provided for @securityTipsMessage.
  ///
  /// In en, this message translates to:
  /// **'• Use at least 8 characters\n• Combine uppercase and lowercase letters\n• Add numbers and symbols (!@#\$)'**
  String get securityTipsMessage;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get savePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChanged;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'RECORDING'**
  String get recording;

  /// No description provided for @speakYourMind.
  ///
  /// In en, this message translates to:
  /// **'Speak your mind'**
  String get speakYourMind;

  /// No description provided for @captureThoughts.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts. This recording will be processed into private insights within your digital sanctuary.'**
  String get captureThoughts;

  /// No description provided for @liveSession.
  ///
  /// In en, this message translates to:
  /// **'LIVE SESSION'**
  String get liveSession;

  /// No description provided for @startRecordToSee.
  ///
  /// In en, this message translates to:
  /// **'Start recording to see emotions'**
  String get startRecordToSee;

  /// No description provided for @discardLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @discardRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Recording?'**
  String get discardRecordingTitle;

  /// No description provided for @discardRecordingMessage.
  ///
  /// In en, this message translates to:
  /// **'All voice data and emotion analysis from this session will be permanently deleted.'**
  String get discardRecordingMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @overallEmotionDistribution.
  ///
  /// In en, this message translates to:
  /// **'Overall Emotion Distribution'**
  String get overallEmotionDistribution;

  /// No description provided for @privacyCheck.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY CHECK'**
  String get privacyCheck;

  /// No description provided for @privacyCheckMessage.
  ///
  /// In en, this message translates to:
  /// **'Your voice is encrypted. Only your insights are shared with your future self.'**
  String get privacyCheckMessage;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @analyzingEmotions.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Emotions'**
  String get analyzingEmotions;

  /// No description provided for @compilingInsights.
  ///
  /// In en, this message translates to:
  /// **'Compiling your personal insights...'**
  String get compilingInsights;

  /// No description provided for @analysisResult.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResult;

  /// No description provided for @resultSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Summary of your latest recording analysis results.'**
  String get resultSummaryDesc;

  /// No description provided for @resultSummaryDefault.
  ///
  /// In en, this message translates to:
  /// **'Summary generated from your recording detection timeline.'**
  String get resultSummaryDefault;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @dominantEmotionLabel.
  ///
  /// In en, this message translates to:
  /// **'Dominant Emotion {emotion}'**
  String dominantEmotionLabel(String emotion);

  /// No description provided for @emotionComponent.
  ///
  /// In en, this message translates to:
  /// **'Emotion Components'**
  String get emotionComponent;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @retakeRecording.
  ///
  /// In en, this message translates to:
  /// **'Retake Recording'**
  String get retakeRecording;

  /// No description provided for @retakeRecordingSub.
  ///
  /// In en, this message translates to:
  /// **'(Redo Recording)'**
  String get retakeRecordingSub;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'*Note: This analysis is indicative and does not replace professional assessment.'**
  String get disclaimer;

  /// No description provided for @wantFullResults.
  ///
  /// In en, this message translates to:
  /// **'Want to see full results?'**
  String get wantFullResults;

  /// No description provided for @loginRegisterForFull.
  ///
  /// In en, this message translates to:
  /// **'Login / Register to view in full.'**
  String get loginRegisterForFull;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginRegister;

  /// No description provided for @recordingTimeline.
  ///
  /// In en, this message translates to:
  /// **'Recording Timeline'**
  String get recordingTimeline;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTimeLabel;

  /// No description provided for @noEmotionComponents.
  ///
  /// In en, this message translates to:
  /// **'No emotion components yet. Record or upload audio first.'**
  String get noEmotionComponents;

  /// No description provided for @appGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get appGuideTitle;

  /// No description provided for @stepsToStart.
  ///
  /// In en, this message translates to:
  /// **'{count} steps to start your journey'**
  String stepsToStart(int count);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @recordVoiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Record Voice'**
  String get recordVoiceGuide;

  /// No description provided for @recordVoiceGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the voice recording feature to express your feelings verbally. Our AI will analyze your tone and sentiment.'**
  String get recordVoiceGuideDesc;

  /// No description provided for @viewEmotionInsights.
  ///
  /// In en, this message translates to:
  /// **'View Emotion Insights'**
  String get viewEmotionInsights;

  /// No description provided for @viewInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'In the \"Insight\" tab, view your weekly emotion patterns and personalized self-care recommendations based on your tracking data.'**
  String get viewInsightsDesc;

  /// No description provided for @monitorCycle.
  ///
  /// In en, this message translates to:
  /// **'Monitor Cycle'**
  String get monitorCycle;

  /// No description provided for @monitorCycleDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect your emotions with your menstrual cycle. FemPsychMonitor helps recognize emotional patterns related to cycle phases so you can better understand yourself.'**
  String get monitorCycleDesc;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @termsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsSheetTitle;

  /// No description provided for @termsUpdatedDate.
  ///
  /// In en, this message translates to:
  /// **'Updated January 1, 2024'**
  String get termsUpdatedDate;

  /// No description provided for @termsReadCarefully.
  ///
  /// In en, this message translates to:
  /// **'Please read carefully before using this app.'**
  String get termsReadCarefully;

  /// No description provided for @termsAcceptance.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsAcceptance;

  /// No description provided for @termsAcceptanceContent.
  ///
  /// In en, this message translates to:
  /// **'By using the FemPsychMonitor application (\"App\"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.'**
  String get termsAcceptanceContent;

  /// No description provided for @termsUsage.
  ///
  /// In en, this message translates to:
  /// **'2. App Usage'**
  String get termsUsage;

  /// No description provided for @termsUsageContent.
  ///
  /// In en, this message translates to:
  /// **'This app is designed as a supportive emotional health monitoring tool, not a substitute for professional medical advice. Users must be at least 17 years old or have parental/guardian consent.'**
  String get termsUsageContent;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'3. Privacy and Data'**
  String get termsPrivacy;

  /// No description provided for @termsPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'We collect emotion data, voice recordings (optional), and cycle data that you input. This data is processed locally and/or on our servers with AES-256 encryption. We do not sell your data to third parties.'**
  String get termsPrivacyContent;

  /// No description provided for @termsAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'4. Account Security'**
  String get termsAccountSecurity;

  /// No description provided for @termsAccountSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials. Please notify us immediately if you suspect unauthorized access to your account.'**
  String get termsAccountSecurityContent;

  /// No description provided for @termsServiceLimitations.
  ///
  /// In en, this message translates to:
  /// **'5. Service Limitations'**
  String get termsServiceLimitations;

  /// No description provided for @termsServiceLimitationsContent.
  ///
  /// In en, this message translates to:
  /// **'FemPsychMonitor is not an emergency service. If you experience a mental crisis or thoughts of self-harm, please contact mental health services or hotline 119 ext 8 immediately.'**
  String get termsServiceLimitationsContent;

  /// No description provided for @termsUpdates.
  ///
  /// In en, this message translates to:
  /// **'6. Terms Updates'**
  String get termsUpdates;

  /// No description provided for @termsUpdatesContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to update these Terms and Conditions at any time. Significant changes will be notified through app notifications. Continued use after changes means you agree to the updated terms.'**
  String get termsUpdatesContent;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsMessage.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these terms and conditions, contact us at:\nsupport@fempsychmonitor.id'**
  String get contactUsMessage;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @voiceEmotionDetection.
  ///
  /// In en, this message translates to:
  /// **'Voice Emotion Detection'**
  String get voiceEmotionDetection;

  /// No description provided for @clearTimeline.
  ///
  /// In en, this message translates to:
  /// **'Clear timeline'**
  String get clearTimeline;

  /// No description provided for @startRecordToSeeTimeline.
  ///
  /// In en, this message translates to:
  /// **'Start recording to see emotion timeline'**
  String get startRecordToSeeTimeline;

  /// No description provided for @personalityType.
  ///
  /// In en, this message translates to:
  /// **'Personality Type'**
  String get personalityType;

  /// No description provided for @yesIKnow.
  ///
  /// In en, this message translates to:
  /// **'Yes, I know'**
  String get yesIKnow;

  /// No description provided for @notSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get notSure;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @failedToLoadQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Failed to load questionnaire.'**
  String get failedToLoadQuestionnaire;

  /// No description provided for @questionXOfY.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionXOfY(int current, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @finishAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Finish & Continue'**
  String get finishAndContinue;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// No description provided for @yourPersonalityType.
  ///
  /// In en, this message translates to:
  /// **'Your Personality Type'**
  String get yourPersonalityType;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @continueToMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'Continue to Mental Health Instrument'**
  String get continueToMentalHealth;

  /// No description provided for @mentalHealthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Assessment'**
  String get mentalHealthAssessment;

  /// No description provided for @finishAndGoToRecording.
  ///
  /// In en, this message translates to:
  /// **'Finish & Go to Recording'**
  String get finishAndGoToRecording;

  /// No description provided for @mentalHealthResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Result'**
  String get mentalHealthResultTitle;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @suggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestion:\n{suggestion}'**
  String suggestionLabel(String suggestion);

  /// No description provided for @tryVoiceTestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to try a voice test (recording) to detect your current emotions?'**
  String get tryVoiceTestQuestion;

  /// No description provided for @tryVoiceTest.
  ///
  /// In en, this message translates to:
  /// **'Try Voice Test'**
  String get tryVoiceTest;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @mulai.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mulai;

  /// No description provided for @sessionNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Note'**
  String get sessionNoteTitle;

  /// No description provided for @sessionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'How did this session feel? Write it here...'**
  String get sessionNoteHint;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with letters and numbers'**
  String get passwordTooWeak;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @noDetectionYet.
  ///
  /// In en, this message translates to:
  /// **'No detections yet'**
  String get noDetectionYet;

  /// No description provided for @noDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your voice to start understanding your emotions.'**
  String get noDetectionDesc;

  /// No description provided for @startRecordingCta.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecordingCta;

  /// No description provided for @currentAssessment.
  ///
  /// In en, this message translates to:
  /// **'Current Assessment'**
  String get currentAssessment;

  /// No description provided for @mentalHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Score'**
  String get mentalHealthScore;

  /// No description provided for @noAssessmentYet.
  ///
  /// In en, this message translates to:
  /// **'Complete onboarding to see your assessment.'**
  String get noAssessmentYet;

  /// No description provided for @noRecordingsYet.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get noRecordingsYet;

  /// No description provided for @unsupportedAudioFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported audio format. Please choose wav, pcm, mp3, m4a, or aac.'**
  String get unsupportedAudioFormat;

  /// No description provided for @audioDecodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decode this audio file.'**
  String get audioDecodeFailed;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @hotlineDesc.
  ///
  /// In en, this message translates to:
  /// **'The detected emotion is quite heavy. If you feel overwhelmed, don\'t hesitate to contact a nearby crisis service.'**
  String get hotlineDesc;

  /// No description provided for @emergencyHealthService.
  ///
  /// In en, this message translates to:
  /// **'Emergency Health'**
  String get emergencyHealthService;

  /// No description provided for @mentalHealthService.
  ///
  /// In en, this message translates to:
  /// **'Mental Health'**
  String get mentalHealthService;

  /// No description provided for @weeklyEmotionDistribution.
  ///
  /// In en, this message translates to:
  /// **'7-Day Emotion Distribution'**
  String get weeklyEmotionDistribution;

  /// No description provided for @noDataThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No data this week.'**
  String get noDataThisWeek;

  /// No description provided for @tipsForYou.
  ///
  /// In en, this message translates to:
  /// **'Tips for you'**
  String get tipsForYou;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get confirmLogout;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadFailed;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get profileSaveFailed;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get passwordChangeFailed;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaveSuccess;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChangeSuccess;

  /// No description provided for @hotlineLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer.'**
  String get hotlineLaunchFailed;

  /// No description provided for @vadListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get vadListening;

  /// No description provided for @vadSpeechDetected.
  ///
  /// In en, this message translates to:
  /// **'Speech detected'**
  String get vadSpeechDetected;

  /// No description provided for @noSpeechDetected.
  ///
  /// In en, this message translates to:
  /// **'No speech detected'**
  String get noSpeechDetected;

  /// No description provided for @noSpeechDetectedHint.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t hear any voice in your recording. Try again in a quieter place and speak clearly.'**
  String get noSpeechDetectedHint;

  /// No description provided for @tryRecordAgain.
  ///
  /// In en, this message translates to:
  /// **'Try recording again'**
  String get tryRecordAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
