import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ───────────────────────── Languages ─────────────────────────
const _codes = ['en', 'ta', 'hi', 'te', 'es', 'fr'];
const _langNames = [
  'English',
  'தமிழ்',
  'हिन्दी',
  'తెలుగు',
  'Español',
  'Français'
];
// Order: en, ta, hi, te, es, fr
const Map<String, List<String>> _s = {
  'app': [
    'Habit Tracker',
    'பழக்க கண்காணிப்பு',
    'आदत ट्रैकर',
    'అలవాటు ట్రాకర్',
    'Rastreador de hábitos',
    'Suivi d’habitudes'
  ],
  'login': ['Login', 'உள்நுழை', 'लॉगिन', 'లాగిన్', 'Entrar', 'Connexion'],
  'register': [
    'Create account',
    'கணக்கு உருவாக்கு',
    'खाता बनाएँ',
    'ఖాతా సృష్టించు',
    'Crear cuenta',
    'Créer un compte'
  ],
  'haveAcc': [
    'I have an account',
    'என்னிடம் கணக்கு உள்ளது',
    'मेरे पास खाता है',
    'నాకు ఖాతా ఉంది',
    'Ya tengo cuenta',
    'J’ai un compte'
  ],
  'name': ['Name', 'பெயர்', 'नाम', 'పేరు', 'Nombre', 'Nom'],
  'email': ['Email', 'மின்னஞ்சல்', 'ईमेल', 'ఇమెయిల్', 'Correo', 'E-mail'],
  'password': [
    'Password',
    'கடவுச்சொல்',
    'पासवर्ड',
    'పాస్‌వర్డ్',
    'Contraseña',
    'Mot de passe'
  ],
  'language': ['Language', 'மொழி', 'भाषा', 'భాష', 'Idioma', 'Langue'],
  'hello': ['Hello', 'வணக்கம்', 'नमस्ते', 'హలో', 'Hola', 'Bonjour'],
  'home': ['Home', 'முகப்பு', 'होम', 'హోమ్', 'Inicio', 'Accueil'],
  'habits': [
    'Habits',
    'பழக்கங்கள்',
    'आदतें',
    'అలవాట్లు',
    'Hábitos',
    'Habitudes'
  ],
  'study': ['Study', 'படிப்பு', 'पढ़ाई', 'చదువు', 'Estudio', 'Études'],
  'settings': [
    'Settings',
    'அமைப்புகள்',
    'सेटिंग्स',
    'సెట్టింగ్‌లు',
    'Ajustes',
    'Réglages'
  ],
  'today': ['Today', 'இன்று', 'आज', 'నేడు', 'Hoy', 'Aujourd’hui'],
  'streak': [
    'Day streak',
    'தொடர் நாட்கள்',
    'लगातार दिन',
    'వరుస రోజులు',
    'Racha',
    'Série'
  ],
  'focusToday': [
    'Focus today (min)',
    'இன்றைய கவனம் (நிமி)',
    'आज फोकस (मिनट)',
    'నేటి ఫోకస్ (నిమి)',
    'Enfoque hoy (min)',
    'Focus du jour (min)'
  ],
  'week': [
    'This week',
    'இந்த வாரம்',
    'इस सप्ताह',
    'ఈ వారం',
    'Esta semana',
    'Cette semaine'
  ],
  'addHabit': [
    'New habit',
    'புதிய பழக்கம்',
    'नई आदत',
    'కొత్త అలవాటు',
    'Nuevo hábito',
    'Nouvelle habitude'
  ],
  'habitName': [
    'Habit name',
    'பழக்கத்தின் பெயர்',
    'आदत का नाम',
    'అలవాటు పేరు',
    'Nombre del hábito',
    'Nom de l’habitude'
  ],
  'days': ['Repeat on', 'நாட்கள்', 'दोहराएँ', 'రిపీట్', 'Repetir', 'Répéter'],
  'templates': [
    'Student plans',
    'மாணவர் திட்டங்கள்',
    'छात्र योजनाएँ',
    'విద్యార్థి ప్లాన్లు',
    'Planes de estudiante',
    'Plans étudiants'
  ],
  'save': ['Save', 'சேமி', 'सहेजें', 'సేవ్', 'Guardar', 'Enregistrer'],
  'cancel': ['Cancel', 'ரத்து', 'रद्द करें', 'రద్దు', 'Cancelar', 'Annuler'],
  'focus': ['Focus', 'கவனம்', 'फोकस', 'ఫోకస్', 'Enfoque', 'Focus'],
  'tasks': ['Tasks', 'பணிகள்', 'कार्य', 'పనులు', 'Tareas', 'Tâches'],
  'exams': [
    'Exams',
    'தேர்வுகள்',
    'परीक्षाएँ',
    'పరీక్షలు',
    'Exámenes',
    'Examens'
  ],
  'start': ['Start', 'தொடங்கு', 'शुरू', 'ప్రారంభం', 'Iniciar', 'Démarrer'],
  'pause': ['Pause', 'இடைநிறுத்து', 'रोकें', 'ఆపు', 'Pausa', 'Pause'],
  'reset': [
    'Reset',
    'மீட்டமை',
    'रीसेट',
    'రీసెట్',
    'Reiniciar',
    'Réinitialiser'
  ],
  'newTask': [
    'New task',
    'புதிய பணி',
    'नया कार्य',
    'కొత్త పని',
    'Nueva tarea',
    'Nouvelle tâche'
  ],
  'examName': [
    'Exam name',
    'தேர்வு பெயர்',
    'परीक्षा का नाम',
    'పరీక్ష పేరు',
    'Nombre del examen',
    'Nom de l’examen'
  ],
  'addExam': [
    'Add exam',
    'தேர்வு சேர்',
    'परीक्षा जोड़ें',
    'పరీక్ష జోడించు',
    'Añadir examen',
    'Ajouter un examen'
  ],
  'left': [
    'days left',
    'நாட்கள் உள்ளன',
    'दिन बाकी',
    'రోజులు మిగిలి',
    'días restantes',
    'jours restants'
  ],
  'logout': [
    'Log out',
    'வெளியேறு',
    'लॉग आउट',
    'లాగ్ అవుట్',
    'Cerrar sesión',
    'Déconnexion'
  ],
  'dark': [
    'Dark mode',
    'இருள் பயன்முறை',
    'डार्क मोड',
    'డార్క్ మోడ్',
    'Modo oscuro',
    'Mode sombre'
  ],
  'theme': [
    'Color theme',
    'நிறத் தீம்',
    'रंग थीम',
    'రంగు థీమ్',
    'Tema de color',
    'Thème de couleur'
  ],
  'themeHint': [
    'Pick a look you like',
    'உங்களுக்குப் பிடித்த தோற்றம்',
    'अपनी पसंद का लुक चुनें',
    'మీకు నచ్చిన రూపం ఎంచుకోండి',
    'Elige el aspecto que te guste',
    'Choisissez un look'
  ],
  'thOcean': ['Ocean', 'கடல்', 'महासागर', 'సముద్రం', 'Océano', 'Océan'],
  'thBlossom': ['Blossom', 'மலர்', 'पुष्प', 'పుష్పం', 'Flor', 'Floraison'],
  'thSunset': [
    'Sunset',
    'அஸ்தமனம்',
    'सूर्यास्त',
    'సూర్యాస్తమయం',
    'Atardecer',
    'Coucher'
  ],
  'thForest': ['Forest', 'காடு', 'वन', 'అడవి', 'Bosque', 'Forêt'],
  'thMidnight': [
    'Midnight',
    'நள்ளிரவு',
    'मध्यरात्रि',
    'అర్ధరాత్రి',
    'Medianoche',
    'Minuit'
  ],
  'thEmber': ['Ember', 'தணல்', 'अंगार', 'నిప్పు', 'Ascua', 'Braise'],
  'thAurora': ['Aurora', 'அரோரா', 'अरोरा', 'అరోరా', 'Aurora', 'Aurore'],
  'thGrape': ['Grape', 'திராட்சை', 'अंगूर', 'ద్రాక్ష', 'Uva', 'Raisin'],
  'thSlate': ['Slate', 'சாம்பல்', 'स्लेट', 'స్లేట్', 'Pizarra', 'Ardoise'],
  'thCrimson': [
    'Crimson',
    'கிரிம்சன்',
    'क्रिमसन',
    'క్రిమ్సన్',
    'Carmesí',
    'Cramoisi'
  ],
  'thCitrus': [
    'Citrus',
    'சிட்ரஸ்',
    'साइट्रस',
    'సిట్రస్',
    'Cítricos',
    'Agrumes'
  ],
  'thArctic': [
    'Arctic',
    'ஆர்க்டிக்',
    'आर्कटिक',
    'ఆర్క్టిక్',
    'Ártico',
    'Arctique'
  ],
  'invalid': [
    'Check your details',
    'விவரங்களை சரிபார்க்கவும்',
    'विवरण जाँचें',
    'వివరాలు తనిఖీ చేయండి',
    'Revisa tus datos',
    'Vérifiez vos informations'
  ],
  'exists': [
    'This email already has an account. Please log in.',
    'இந்த மின்னஞ்சலுக்கு ஏற்கனவே கணக்கு உள்ளது. உள்நுழையவும்.',
    'इस ईमेल का खाता पहले से है। कृपया लॉगिन करें।',
    'ఈ ఇమెయిల్‌కు ఇప్పటికే ఖాతా ఉంది. దయచేసి లాగిన్ చేయండి.',
    'Este correo ya tiene una cuenta. Inicia sesión.',
    'Cet e-mail a déjà un compte. Connectez-vous.'
  ],
  'wrong': [
    'Wrong email or password',
    'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல்',
    'गलत ईमेल या पासवर्ड',
    'తప్పు ఇమెయిల్ లేదా పాస్‌వర్డ్',
    'Correo o contraseña incorrectos',
    'E-mail ou mot de passe incorrect'
  ],
  'noHabits': [
    'No habits yet. Add one in the Habits tab!',
    'இன்னும் பழக்கங்கள் இல்லை. பழக்கங்கள் தாவலில் சேர்க்கவும்!',
    'अभी कोई आदत नहीं। आदतें टैब में जोड़ें!',
    'ఇంకా అలవాట్లు లేవు. అలవాట్లు ట్యాబ్‌లో జోడించండి!',
    'Aún no hay hábitos. ¡Añade uno en Hábitos!',
    'Aucune habitude. Ajoutez-en une dans Habitudes !'
  ],
  'tplRead': [
    'Read 30 min',
    '30 நிமி படி',
    '30 मिनट पढ़ें',
    '30 నిమి చదువు',
    'Leer 30 min',
    'Lire 30 min'
  ],
  'tplRevise': [
    'Revise notes',
    'குறிப்புகளை மீள்பார்',
    'नोट्स दोहराएँ',
    'నోట్స్ రివైజ్ చేయి',
    'Repasar apuntes',
    'Réviser les notes'
  ],
  'tplWater': [
    'Drink water',
    'தண்ணீர் குடி',
    'पानी पिएँ',
    'నీళ్లు తాగు',
    'Beber agua',
    'Boire de l’eau'
  ],
  'tplSleep': [
    'Sleep early',
    'சீக்கிரம் தூங்கு',
    'जल्दी सोएँ',
    'త్వరగా నిద్రపో',
    'Dormir temprano',
    'Dormir tôt'
  ],
  'tplMove': [
    'Exercise',
    'உடற்பயிற்சி',
    'व्यायाम',
    'వ్యాయామం',
    'Ejercicio',
    'Exercice'
  ],
  'min': ['min', 'நிமி', 'मिनट', 'నిమి', 'min', 'min'],
  'askGym': [
    'How many minutes do you want to work out?',
    'எத்தனை நிமிடங்கள் உடற்பயிற்சி செய்ய விரும்புகிறீர்கள்?',
    'आप कितने मिनट वर्कआउट करना चाहते हैं?',
    'మీరు ఎన్ని నిమిషాలు వర్కౌట్ చేయాలనుకుంటున్నారు?',
    '¿Cuántos minutos quieres entrenar?',
    'Combien de minutes voulez-vous vous entraîner ?'
  ],
  'askTask': [
    'How many minutes will you spend on this?',
    'இதற்கு எத்தனை நிமிடங்கள் செலவிடுவீர்கள்?',
    'आप इसमें कितने मिनट लगाएँगे?',
    'దీనికి మీరు ఎన్ని నిమిషాలు కేటాయిస్తారు?',
    '¿Cuántos minutos le dedicarás?',
    'Combien de minutes allez-vous y consacrer ?'
  ],
  'studyFixed': [
    'Study session: 30 minutes',
    'படிப்பு அமர்வு: 30 நிமிடங்கள்',
    'पढ़ाई सत्र: 30 मिनट',
    'చదువు సెషన్: 30 నిమిషాలు',
    'Sesión de estudio: 30 minutos',
    'Session d’étude : 30 minutes'
  ],
  'lockedMsg': [
    'Finish the timer to unlock',
    'திறக்க டைமரை முடிக்கவும்',
    'अनलॉक करने के लिए टाइमर पूरा करें',
    'అన్‌లాక్ చేయడానికి టైమర్ పూర్తి చేయండి',
    'Termina el temporizador para desbloquear',
    'Terminez le minuteur pour déverrouiller'
  ],
  'unlockedMsg': [
    'Timer done – you can tick it now!',
    'டைமர் முடிந்தது – இப்போது டிக் செய்யலாம்!',
    'टाइमर पूरा – अब टिक कर सकते हैं!',
    'టైమర్ పూర్తయింది – ఇప్పుడు టిక్ చేయవచ్చు!',
    'Temporizador listo: ¡ya puedes marcarlo!',
    'Minuteur terminé : vous pouvez cocher !'
  ],
  'stayHint': [
    'Stay in the app – leaving stops the timer',
    'ஆப்பிலேயே இருங்கள் – வெளியேறினால் டைமர் நின்றுவிடும்',
    'ऐप में रहें – बाहर जाने पर टाइमर रुक जाएगा',
    'యాప్‌లోనే ఉండండి – బయటకు వెళ్తే టైమర్ ఆగుతుంది',
    'Quédate en la app: si sales, el temporizador se detiene',
    'Restez dans l’app : le minuteur s’arrête si vous la quittez'
  ],
  'timerStopped': [
    'Timer stopped because you left the app. Start again!',
    'ஆப்பை விட்டு வெளியேறியதால் டைமர் நிறுத்தப்பட்டது. மீண்டும் தொடங்கவும்!',
    'ऐप छोड़ने के कारण टाइमर रुक गया। फिर से शुरू करें!',
    'యాప్ వదిలివెళ్లడంతో టైమర్ ఆగింది. మళ్లీ ప్రారంభించండి!',
    'El temporizador se detuvo porque saliste de la app. ¡Inicia de nuevo!',
    'Le minuteur s’est arrêté car vous avez quitté l’app. Recommencez !'
  ],
  'greatJob': [
    'Great job!',
    'சிறப்பு!',
    'शाबाश!',
    'అద్భుతం!',
    '¡Buen trabajo!',
    'Bravo !'
  ],
  'markDone': [
    'Mark as done',
    'முடிந்ததாகக் குறி',
    'पूरा चिह्नित करें',
    'పూర్తయినట్లు గుర్తించు',
    'Marcar como hecho',
    'Marquer comme fait'
  ],
  'later': ['Later', 'பின்னர்', 'बाद में', 'తర్వాత', 'Más tarde', 'Plus tard'],
  'stopTimer': [
    'Stop',
    'நிறுத்து',
    'बंद करें',
    'ఆపివేయి',
    'Detener',
    'Arrêter'
  ],
  'tplWake': ['Wake up', 'எழுந்திரு', 'जागना', 'నిద్ర లేవడం', 'Despertar', 'Réveil'],
  'tplMeditate': ['Meditate', 'தியானம்', 'ध्यान', 'ధ్యానం', 'Meditar', 'Méditer'],
  'tplJournal': [
    'Write journal',
    'நாட்குறிப்பு எழுது',
    'डायरी लिखें',
    'డైరీ రాయి',
    'Escribir diario',
    'Écrire un journal'
  ],
  'tplWalk': ['Go for a walk', 'நடைப்பயிற்சி', 'सैर करें', 'వాకింగ్', 'Caminar', 'Marcher'],
  'tplVitamins': [
    'Take vitamins',
    'வைட்டமின் எடு',
    'विटामिन लें',
    'విటమిన్లు తీసుకో',
    'Tomar vitaminas',
    'Prendre ses vitamines'
  ],
  'tplTidy': ['Tidy up', 'சுத்தம் செய்', 'सफ़ाई करें', 'శుభ్రం చేయి', 'Ordenar', 'Ranger'],
  'tplLanguage': [
    'Learn a language',
    'மொழி கற்று',
    'भाषा सीखें',
    'భాష నేర్చుకో',
    'Aprender un idioma',
    'Apprendre une langue'
  ],
  'tplScreen': [
    'Screen-free time',
    'திரையில்லா நேரம்',
    'स्क्रीन-मुक्त समय',
    'స్క్రీన్ లేని సమయం',
    'Tiempo sin pantallas',
    'Temps sans écran'
  ],
  'tplPlan': [
    'Plan tomorrow',
    'நாளையை திட்டமிடு',
    'कल की योजना बनाएँ',
    'రేపటి ప్లాన్',
    'Planear el mañana',
    'Planifier demain'
  ],
  'tplStretch': [
    'Stretch',
    'நீட்சிப் பயிற்சி',
    'स्ट्रेचिंग',
    'స్ట్రెచింగ్',
    'Estirar',
    'S’étirer'
  ],
  'kTimer': ['Timer', 'டைமர்', 'टाइमर', 'టైమర్', 'Temporizador', 'Minuteur'],
  'kWater': ['Water', 'தண்ணீர்', 'पानी', 'నీళ్లు', 'Agua', 'Eau'],
  'kSleep': ['Sleep', 'தூக்கம்', 'नींद', 'నిద్ర', 'Sueño', 'Sommeil'],
  'kWake': ['Wake-up', 'விழிப்பு', 'जागना', 'మేల్కొలుపు', 'Despertar', 'Réveil'],
  'timerMin': [
    'Timer length',
    'டைமர் நீளம்',
    'टाइमर अवधि',
    'టైమర్ వ్యవధి',
    'Duración del temporizador',
    'Durée du minuteur'
  ],
  'remindEvery': [
    'Remind me every',
    'நினைவூட்டல் இடைவெளி',
    'रिमाइंडर अंतराल',
    'రిమైండర్ విరామం',
    'Recordar cada',
    'Me rappeler toutes les'
  ],
  'goalGlasses': [
    'Daily goal (glasses)',
    'தினசரி இலக்கு (கிளாஸ்)',
    'दैनिक लक्ष्य (गिलास)',
    'రోజువారీ లక్ష్యం (గ్లాసులు)',
    'Meta diaria (vasos)',
    'Objectif quotidien (verres)'
  ],
  'fromTime': ['From', 'முதல்', 'से', 'నుండి', 'Desde', 'De'],
  'toTime': ['Until', 'வரை', 'तक', 'వరకు', 'Hasta', 'Jusqu’à'],
  'bedtime': [
    'Bedtime reminder at',
    'தூக்க நினைவூட்டல் நேரம்',
    'सोने का रिमाइंडर',
    'నిద్ర రిమైండర్ సమయం',
    'Recordatorio de dormir a las',
    'Rappel du coucher à'
  ],
  'wakeTime': [
    'Alarm time',
    'அலாரம் நேரம்',
    'अलार्म का समय',
    'అలారం సమయం',
    'Hora de la alarma',
    'Heure de l’alarme'
  ],
  'setTime': [
    'Set time',
    'நேரம் அமை',
    'समय चुनें',
    'సమయం సెట్ చేయి',
    'Elegir hora',
    'Choisir l’heure'
  ],
  'needTime': [
    'Please set a time',
    'நேரத்தை அமைக்கவும்',
    'कृपया समय चुनें',
    'దయచేసి సమయం సెట్ చేయండి',
    'Elige una hora',
    'Choisissez une heure'
  ],
  'badRange': [
    'End time must be after start time',
    'முடிவு நேரம் தொடக்கத்துக்குப் பின் இருக்க வேண்டும்',
    'समाप्ति समय शुरुआत के बाद होना चाहिए',
    'ముగింపు సమయం ప్రారంభం తర్వాత ఉండాలి',
    'La hora final debe ser posterior a la inicial',
    'L’heure de fin doit suivre le début'
  ],
  'reminderOpt': [
    'Daily reminder',
    'தினசரி நினைவூட்டல்',
    'दैनिक रिमाइंडर',
    'రోజువారీ రిమైండర్',
    'Recordatorio diario',
    'Rappel quotidien'
  ],
  'editHabit': [
    'Edit habit',
    'பழக்கத்தை திருத்து',
    'आदत संपादित करें',
    'అలవాటు సవరించు',
    'Editar hábito',
    'Modifier l’habitude'
  ],
  'glasses': ['glasses', 'கிளாஸ்', 'गिलास', 'గ్లాసులు', 'vasos', 'verres'],
  'every': ['every', 'ஒவ்வொரு', 'हर', 'ప్రతి', 'cada', 'toutes les'],
  'unlocksAt': [
    'Unlocks at',
    'திறக்கும் நேரம்',
    'अनलॉक समय',
    'అన్‌లాక్ సమయం',
    'Se desbloquea a las',
    'Se déverrouille à'
  ],
  'timeReached': [
    'It’s time – tick when done!',
    'நேரம் வந்தது – முடிந்ததும் டிக் செய்யுங்கள்!',
    'समय हो गया – पूरा होने पर टिक करें!',
    'సమయం అయింది – పూర్తయ్యాక టిక్ చేయండి!',
    '¡Es la hora! Márcalo al terminar',
    'C’est l’heure : cochez une fois fait !'
  ],
  'progress': ['Progress', 'முன்னேற்றம்', 'प्रगति', 'పురోగతి', 'Progreso', 'Progrès'],
  'last30': [
    'Last 30 days',
    'கடந்த 30 நாட்கள்',
    'पिछले 30 दिन',
    'గత 30 రోజులు',
    'Últimos 30 días',
    '30 derniers jours'
  ],
  'totalDone': [
    'Completed',
    'முடிந்தவை',
    'पूरे किए',
    'పూర్తయినవి',
    'Completados',
    'Terminés'
  ],
  'weekRate': [
    '7-day rate',
    '7 நாள் விகிதம்',
    '7 दिन की दर',
    '7 రోజుల రేటు',
    'Tasa de 7 días',
    'Taux sur 7 jours'
  ],
  'testNotif': [
    'Send test reminder',
    'சோதனை நினைவூட்டல் அனுப்பு',
    'टेस्ट रिमाइंडर भेजें',
    'టెస్ట్ రిమైండర్ పంపు',
    'Enviar recordatorio de prueba',
    'Envoyer un rappel test'
  ],
  'notifOff': [
    'Reminders are not available. Check notification permission.',
    'நினைவூட்டல்கள் கிடைக்கவில்லை. அறிவிப்பு அனுமதியை சரிபார்க்கவும்.',
    'रिमाइंडर उपलब्ध नहीं हैं। नोटिफिकेशन अनुमति जाँचें।',
    'రిమైండర్లు అందుబాటులో లేవు. నోటిఫికేషన్ అనుమతిని తనిఖీ చేయండి.',
    'Los recordatorios no están disponibles. Revisa el permiso de notificaciones.',
    'Rappels indisponibles. Vérifiez l’autorisation des notifications.'
  ],
  'waterBody': [
    'Time to drink a glass of water! 💧',
    'ஒரு கிளாஸ் தண்ணீர் குடிக்க நேரம்! 💧',
    'एक गिलास पानी पीने का समय! 💧',
    'ఒక గ్లాసు నీళ్లు తాగే సమయం! 💧',
    '¡Hora de beber un vaso de agua! 💧',
    'C’est l’heure de boire un verre d’eau ! 💧'
  ],
  'wakeBody': [
    'Good morning! Time to wake up. ☀️',
    'காலை வணக்கம்! எழுந்திருக்கும் நேரம். ☀️',
    'सुप्रभात! जागने का समय। ☀️',
    'శుభోదయం! నిద్ర లేచే సమయం. ☀️',
    '¡Buenos días! Es hora de despertar. ☀️',
    'Bonjour ! C’est l’heure de se réveiller. ☀️'
  ],
  'sleepBody': [
    'Time to wind down and go to sleep. 🌙',
    'ஓய்வெடுத்து தூங்கச் செல்லும் நேரம். 🌙',
    'आराम करने और सोने का समय। 🌙',
    'విశ్రాంతి తీసుకుని నిద్రపోయే సమయం. 🌙',
    'Hora de relajarse e ir a dormir. 🌙',
    'C’est l’heure de se détendre et de dormir. 🌙'
  ],
  'remindBody': [
    'Time for your habit! ✅',
    'உங்கள் பழக்கத்துக்கான நேரம்! ✅',
    'आपकी आदत का समय! ✅',
    'మీ అలవాటు సమయం! ✅',
    '¡Es hora de tu hábito! ✅',
    'C’est l’heure de votre habitude ! ✅'
  ],
};

// Which habit icons count as "study" (fixed 30 min) or "gym" (ask minutes).
// Icon indexes refer to _icons below: 0 book, 5 notes, 7 code | 1 gym, 6 run.
const _studyIcons = {0, 5, 7};
const _gymIcons = {1, 6};
const _studyMinutes = 30;

class Tpl {
  final String key;
  final int icon, kind, mins, rt, goal;
  const Tpl(this.key, this.icon,
      {this.kind = 0, this.mins = 30, this.rt = -1, this.goal = 8});
}

// kind: 0 = timer task, 1 = water (reminders every N min), 2 = sleep reminder,
// 3 = wake-up alarm. mins = timer minutes (or reminder interval for water).
// rt = reminder/alarm time in minutes after midnight (-1 = none).
const _templates = <Tpl>[
  Tpl('tplRead', 0),
  Tpl('tplRevise', 5),
  Tpl('tplMove', 1),
  Tpl('tplWater', 2, kind: 1, mins: 30, rt: 8 * 60),
  Tpl('tplSleep', 3, kind: 2, rt: 22 * 60 + 30),
  Tpl('tplWake', 10, kind: 3),
  Tpl('tplMeditate', 11, mins: 10),
  Tpl('tplStretch', 19, mins: 10),
  Tpl('tplWalk', 13),
  Tpl('tplJournal', 12, mins: 10),
  Tpl('tplVitamins', 14, mins: 1, rt: 8 * 60),
  Tpl('tplLanguage', 16, mins: 15),
  Tpl('tplTidy', 15, mins: 15),
  Tpl('tplScreen', 17),
  Tpl('tplPlan', 18, mins: 5),
];

const _icons = <IconData>[
  Icons.menu_book,
  Icons.fitness_center,
  Icons.water_drop,
  Icons.bedtime,
  Icons.self_improvement,
  Icons.edit_note,
  Icons.directions_run,
  Icons.code,
  Icons.music_note,
  Icons.restaurant,
  Icons.wb_sunny, // 10 wake-up
  Icons.spa, // 11 meditate
  Icons.auto_stories, // 12 journal
  Icons.directions_walk, // 13 walk
  Icons.medication, // 14 vitamins
  Icons.cleaning_services, // 15 tidy
  Icons.translate, // 16 language
  Icons.phonelink_off, // 17 screen-free
  Icons.event_note, // 18 plan
  Icons.sports_gymnastics, // 19 stretch
  Icons.favorite, // 20
  Icons.brush, // 21
];

const _wd = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class AppTheme {
  final String id, nameKey;
  final Color a, b;
  const AppTheme(this.id, this.nameKey, this.a, this.b);
}

const _themes = <AppTheme>[
  AppTheme('ocean', 'thOcean', Color(0xFF1565C0), Color(0xFF00ACC1)),
  AppTheme('blossom', 'thBlossom', Color(0xFFD81B60), Color(0xFF8E24AA)),
  AppTheme('sunset', 'thSunset', Color(0xFFFF6D00), Color(0xFFE040FB)),
  AppTheme('forest', 'thForest', Color(0xFF2E7D32), Color(0xFF00BFA5)),
  AppTheme('midnight', 'thMidnight', Color(0xFF1A237E), Color(0xFF7C4DFF)),
  AppTheme('ember', 'thEmber', Color(0xFFBF360C), Color(0xFFFF8F00)),
  AppTheme('aurora', 'thAurora', Color(0xFF00897B), Color(0xFF651FFF)),
  AppTheme('grape', 'thGrape', Color(0xFF6A1B9A), Color(0xFFEC407A)),
  AppTheme('slate', 'thSlate', Color(0xFF455A64), Color(0xFF90A4AE)),
  AppTheme('crimson', 'thCrimson', Color(0xFFB71C1C), Color(0xFFFF5252)),
  AppTheme('citrus', 'thCitrus', Color(0xFFF9A825), Color(0xFF43A047)),
  AppTheme('arctic', 'thArctic', Color(0xFF0277BD), Color(0xFF4FC3F7)),
];

// ───────────────────────── Models ─────────────────────────
String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String hashPw(String s) {
  int h = 2166136261;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h.toRadixString(16);
}

class Habit {
  String id, name;
  int icon, kind, mins, rt, goal, re;
  List<int> days;
  Set<String> done;
  Map<String, int> cnt, md; // cnt: glasses per day, md: minutes done per day
  Habit(this.id, this.name, this.icon, this.days, this.done,
      {this.kind = 0,
      this.mins = 30,
      this.rt = -1,
      this.goal = 8,
      this.re = 22 * 60,
      Map<String, int>? cnt,
      Map<String, int>? md})
      : cnt = cnt ?? {},
        md = md ?? {};
  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'i': icon,
        'd': days,
        'x': done.toList(),
        'k': kind,
        'm': mins,
        'rt': rt,
        'g': goal,
        're': re,
        'c': cnt,
        'md': md,
      };
  factory Habit.fromJson(Map j) => Habit(
        j['id'],
        j['n'],
        j['i'],
        List<int>.from(j['d']),
        Set<String>.from(j['x']),
        kind: j['k'] ?? 0,
        mins: j['m'] ?? 30,
        rt: j['rt'] ?? -1,
        goal: j['g'] ?? 8,
        re: j['re'] ?? 22 * 60,
        cnt: Map<String, int>.from(j['c'] ?? {}),
        md: Map<String, int>.from(j['md'] ?? {}),
      );
  DateTime get created {
    final us = int.tryParse(id);
    return us == null
        ? DateTime(2000)
        : DateTime.fromMicrosecondsSinceEpoch(us);
  }
}

class Task {
  String id, title;
  bool done;
  String? due;
  Task(this.id, this.title, this.done, this.due);
  Map<String, dynamic> toJson() => {'id': id, 't': title, 'x': done, 'd': due};
  factory Task.fromJson(Map j) => Task(j['id'], j['t'], j['x'], j['d']);
}

class Exam {
  String id, name, date;
  Exam(this.id, this.name, this.date);
  Map<String, dynamic> toJson() => {'id': id, 'n': name, 'd': date};
  factory Exam.fromJson(Map j) => Exam(j['id'], j['n'], j['d']);
}

// ───────────────────────── State ─────────────────────────
class AppState extends ChangeNotifier {
  late SharedPreferences p;
  Map<String, dynamic>? user; // n=name, e=email, h=hash
  bool loggedIn = false, dark = false;
  String lang = 'en', themeId = 'ocean';
  List<Habit> habits = [];
  List<Task> tasks = [];
  List<Exam> exams = [];
  Map<String, int> focus = {};
  Set<String> unlocked = {}; // items whose timer was completed

  String t(String k) => _s[k]![_codes.indexOf(lang)];
  AppTheme get palette =>
      _themes.firstWhere((e) => e.id == themeId, orElse: () => _themes.first);
  List<Color> get grad => [palette.a, palette.b];

  // ── Local database ──────────────────────────────────────────────
  // Stored on the device (browser storage on web) with shared_preferences:
  //   users          -> { email: {n: name, e: email, s: salt, h: password hash} }
  //   session        -> email of the logged-in user (stay logged in)
  //   data:<email>   -> that user's habits, tasks, exams, focus, unlocked
  // Every account keeps its own data, so users only register once and then
  // simply log in.
  Map<String, dynamic> users = {};

  String _dk(String email) => 'data:$email';

  Future<void> load() async {
    p = await SharedPreferences.getInstance();
    lang = p.getString('lang') ?? 'en';
    dark = p.getBool('dark') ?? false;
    themeId = p.getString('theme') ?? 'ocean';

    _migrateLegacy();

    final raw = p.getString('users');
    users = raw == null ? {} : Map<String, dynamic>.from(jsonDecode(raw));
    final session = p.getString('session');
    if (session != null && users[session] != null) {
      user = Map<String, dynamic>.from(users[session]);
      loggedIn = true;
      _loadData(session);
    }
  }

  /// Older versions kept a single account in plain keys: move it over.
  void _migrateLegacy() {
    final old = p.getString('user');
    if (old == null || p.containsKey('users')) return;
    final u = Map<String, dynamic>.from(jsonDecode(old));
    final e = u['e'] as String;
    p.setString('users', jsonEncode({e: u}));
    p.setString(
        _dk(e),
        jsonEncode({
          'habits': jsonDecode(p.getString('habits') ?? '[]'),
          'tasks': jsonDecode(p.getString('tasks') ?? '[]'),
          'exams': jsonDecode(p.getString('exams') ?? '[]'),
          'focus': jsonDecode(p.getString('focus') ?? '{}'),
          'unlocked': jsonDecode(p.getString('unlocked') ?? '[]'),
        }));
    if (p.getBool('in') ?? false) p.setString('session', e);
    for (final k in ['user', 'in', 'habits', 'tasks', 'exams', 'focus', 'unlocked']) {
      p.remove(k);
    }
  }

  void _clearData() {
    habits = [];
    tasks = [];
    exams = [];
    focus = {};
    unlocked = {};
  }

  void _loadData(String email) {
    _clearData();
    final raw = p.getString(_dk(email));
    final m = raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(raw));
    List l(String k) => (m[k] as List?) ?? [];
    habits = l('habits').map((e) => Habit.fromJson(e as Map)).toList();
    tasks = l('tasks').map((e) => Task.fromJson(e as Map)).toList();
    exams = l('exams').map((e) => Exam.fromJson(e as Map)).toList();
    focus = Map<String, int>.from((m['focus'] as Map?) ?? {});
    unlocked = Set<String>.from((m['unlocked'] as List?) ?? []);
    // Habit unlocks are per-day: drop the ones from earlier days.
    final today = dayKey(DateTime.now());
    unlocked.removeWhere((k) => k.startsWith('h|') && !k.endsWith(today));
  }

  void save() {
    p.setString('lang', lang);
    p.setBool('dark', dark);
    p.setString('theme', themeId);
    p.setString('users', jsonEncode(users));
    if (loggedIn && user != null) {
      final e = user!['e'] as String;
      p.setString('session', e);
      p.setString(
          _dk(e),
          jsonEncode({
            'habits': habits.map((x) => x.toJson()).toList(),
            'tasks': tasks.map((x) => x.toJson()).toList(),
            'exams': exams.map((x) => x.toJson()).toList(),
            'focus': focus,
            'unlocked': unlocked.toList(),
          }));
    } else {
      p.remove('session');
    }
    notifyListeners();
  }

  // Auth (local only – use Firebase/your own API if you need cloud sync)
  /// Returns false when the email already has an account.
  bool register(String n, String e, String pw) {
    if (users.containsKey(e)) return false;
    final salt = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    user = {'n': n, 'e': e, 's': salt, 'h': hashPw('$salt:$pw')};
    users[e] = user;
    _clearData();
    loggedIn = true;
    save();
    syncReminders();
    return true;
  }

  bool signIn(String e, String pw) {
    final u = users[e];
    if (u == null) return false;
    final salt = (u['s'] ?? '') as String;
    final ok = salt.isEmpty ? u['h'] == hashPw(pw) : u['h'] == hashPw('$salt:$pw');
    if (!ok) return false;
    user = Map<String, dynamic>.from(u);
    _loadData(e);
    loggedIn = true;
    save();
    syncReminders();
    return true;
  }

  void logout() {
    loggedIn = false;
    user = null;
    _clearData();
    save();
    syncReminders(); // cancels this user's reminders
  }

  void setTheme(String id) {
    themeId = id;
    if (loggedIn) {
      save();
    } else {
      p.setString('theme', themeId);
      notifyListeners();
    }
  }

  void setLang(String l) {
    lang = l;
    p.setString('lang', l);
    notifyListeners();
    syncReminders();
  }

  void setDark(bool v) {
    dark = v;
    save();
  }

  // Timer-gated checkboxes
  bool isUnlocked(String key) => unlocked.contains(key);
  void unlock(String key) {
    unlocked.add(key);
    save();
  }

  // Habits
  List<Habit> get todayHabits =>
      habits.where((h) => h.days.contains(DateTime.now().weekday)).toList();

  void toggle(Habit h) {
    final k = dayKey(DateTime.now());
    if (h.done.contains(k)) {
      h.done.remove(k);
      h.md.remove(k);
    } else {
      h.done.add(k);
      if (h.kind == 0) h.md[k] = h.mins;
    }
    save();
  }

  // Water: +1 / -1 glass; the habit auto-completes at the daily goal.
  void addWater(Habit h, int d) {
    final k = dayKey(DateTime.now());
    final c = ((h.cnt[k] ?? 0) + d).clamp(0, 99).toInt();
    h.cnt[k] = c;
    c >= h.goal ? h.done.add(k) : h.done.remove(k);
    save();
  }

  void setHabitMins(Habit h, int m) {
    if (h.mins == m) return;
    h.mins = m;
    save();
  }

  void addHabit(Habit h) {
    habits.add(h);
    save();
    syncReminders();
  }

  void updateHabit(Habit h) {
    save();
    syncReminders();
  }

  void removeHabit(Habit h) {
    habits.remove(h);
    unlocked.removeWhere((k) => k.startsWith('h|${h.id}|'));
    save();
    syncReminders();
  }

  Future<void> syncReminders() => Notifier.sync(habits, t);

  // ── Progress ──
  int habitStreak(Habit h) {
    int n = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      if (!h.days.contains(d.weekday)) continue;
      if (h.done.contains(dayKey(d))) {
        n++;
      } else if (i > 0) {
        break;
      }
    }
    return n;
  }

  /// Share of scheduled days (since the habit was created) that were completed.
  double habitRate(Habit h, int span) {
    final start = DateTime(h.created.year, h.created.month, h.created.day);
    final now = DateTime.now();
    int sched = 0, ok = 0;
    for (int i = 0; i < span; i++) {
      final d = now.subtract(Duration(days: i));
      if (DateTime(d.year, d.month, d.day).isBefore(start)) continue;
      if (!h.days.contains(d.weekday)) continue;
      sched++;
      if (h.done.contains(dayKey(d))) ok++;
    }
    return sched == 0 ? 0 : ok / sched;
  }

  double overallRate(int span) {
    double sum = 0;
    int n = 0;
    for (final h in habits) {
      final r = habitRate(h, span);
      if (r > 0 || h.done.isNotEmpty) {
        sum += r;
        n++;
      }
    }
    return n == 0 ? 0 : sum / n;
  }

  double dayFrac(DateTime d) {
    final sch = habits.where((h) => h.days.contains(d.weekday)).toList();
    if (sch.isEmpty) return 0;
    return sch.where((h) => h.done.contains(dayKey(d))).length / sch.length;
  }

  int get streak {
    int s = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final sch = habits.where((h) => h.days.contains(d.weekday));
      if (sch.isEmpty) continue;
      if (sch.every((h) => h.done.contains(dayKey(d)))) {
        s++;
      } else if (i > 0) {
        break;
      }
    }
    return s;
  }

  // Study
  int get focusToday => focus[dayKey(DateTime.now())] ?? 0;
  void addFocus(int m) {
    final k = dayKey(DateTime.now());
    focus[k] = (focus[k] ?? 0) + m;
    save();
  }

  void addTask(Task x) {
    tasks.add(x);
    save();
  }

  void toggleTask(Task x) {
    x.done = !x.done;
    save();
  }

  void removeTask(String id) {
    tasks.removeWhere((e) => e.id == id);
    unlocked.remove('t|$id');
    save();
  }

  void addExam(Exam x) {
    exams.add(x);
    save();
  }

  void removeExam(String id) {
    exams.removeWhere((e) => e.id == id);
    save();
  }
}

// ───────────────────────── Reminders & alarms ─────────────────────────
class Notifier {
  static final _np = FlutterLocalNotificationsPlugin();
  static bool ready = false;

  static Future<void> init() async {
    if (kIsWeb) return; // reminders/alarms need Android or iOS
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      await _np.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      final a = _np.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await a?.requestNotificationsPermission();
      await a?.requestExactAlarmsPermission();
      ready = true;
    } catch (e) {
      debugPrint('Notifier init failed: $e');
    }
  }

  static NotificationDetails _details(bool alarm) => NotificationDetails(
        android: AndroidNotificationDetails(
          alarm ? 'habit_alarm' : 'habit_reminders',
          alarm ? 'Wake-up alarm' : 'Habit reminders',
          channelDescription:
              alarm ? 'Rings at your wake-up time' : 'Daily habit reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: alarm
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.reminder,
          fullScreenIntent: alarm,
          audioAttributesUsage:
              alarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
          // FLAG_INSISTENT (4): keep ringing until the user reacts.
          additionalFlags: alarm ? Int32List.fromList(<int>[4]) : null,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
            presentAlert: true, presentSound: true, presentBadge: true),
      );

  static tz.TZDateTime _next(int mod, int? weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, mod ~/ 60, mod % 60);
    while (d.isBefore(now) || (weekday != null && d.weekday != weekday)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  static Future<void> _at(int id, String title, String body, int mod,
      {int? weekday, bool alarm = false}) {
    return _np.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _next(mod, weekday),
      notificationDetails: _details(alarm),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: weekday == null
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancels everything and re-creates the reminders for all habits.
  static Future<void> sync(List<Habit> habits, String Function(String) t) async {
    if (!ready) return;
    try {
      await _np.cancelAll();
      for (final h in habits) {
        final base = (h.id.hashCode.abs() % 2000000) * 1000;
        final allDays = h.days.length == 7;
        if (h.kind == 1) {
          if (h.rt < 0) continue;
          final step = h.mins < 5 ? 5 : h.mins;
          final maxN = allDays ? 48 : 60 ~/ h.days.length;
          int i = 0;
          for (int m = h.rt; m <= h.re && i < maxN; m += step, i++) {
            if (allDays) {
              await _at(base + i * 8, '💧 ${h.name}', t('waterBody'), m);
            } else {
              for (final d in h.days) {
                await _at(base + i * 8 + d, '💧 ${h.name}', t('waterBody'), m,
                    weekday: d);
              }
            }
          }
        } else if (h.kind == 2 || h.kind == 3) {
          if (h.rt < 0) continue;
          final wake = h.kind == 3;
          for (final d in h.days) {
            await _at(base + d, '${wake ? '⏰' : '🌙'} ${h.name}',
                t(wake ? 'wakeBody' : 'sleepBody'), h.rt,
                weekday: d, alarm: wake);
          }
        } else if (h.rt >= 0) {
          for (final d in h.days) {
            await _at(base + d, '🔔 ${h.name}', t('remindBody'), h.rt,
                weekday: d);
          }
        }
      }
    } catch (e) {
      debugPrint('Reminder sync failed: $e');
    }
  }

  static Future<void> test(AppState s) async {
    if (!ready) return;
    try {
      await _np.show(
          id: 999,
          title: s.t('app'),
          body: s.t('remindBody'),
          notificationDetails: _details(false));
    } catch (e) {
      debugPrint('Test notification failed: $e');
    }
  }
}

// ───────────────────────── App ─────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = AppState();
  await s.load();
  runApp(App(s));
  await Notifier.init(); // asks for notification permission on first run
  s.syncReminders();
}

class App extends StatelessWidget {
  final AppState s;
  const App(this.s, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: s.t('app'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: s.grad[0],
              brightness: s.dark ? Brightness.dark : Brightness.light,
            ),
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)))),
          ),
          home: s.loggedIn ? Home(s) : Login(s),
        ),
      );
}

// ───────────────────────── Theme picker ─────────────────────────
class ThemePicker extends StatelessWidget {
  final AppState s;
  final bool labeled;
  const ThemePicker(this.s, {this.labeled = false, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final t in _themes)
          Tooltip(
            message: s.t(t.nameKey),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => s.setTheme(t.id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: labeled ? 104 : 44,
                  padding: labeled
                      ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: labeled
                        ? (s.themeId == t.id
                            ? cs.primaryContainer.withValues(alpha: 0.55)
                            : cs.surface)
                        : null,
                    border: Border.all(
                      color: s.themeId == t.id ? t.a : cs.outlineVariant,
                      width: s.themeId == t.id ? 2.5 : 1,
                    ),
                  ),
                  child: labeled
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _swatch(t, 28),
                            const SizedBox(height: 6),
                            Text(
                              s.t(t.nameKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: s.themeId == t.id
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : _swatch(t, 38),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _swatch(AppTheme t, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [t.a, t.b],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: s.themeId == t.id
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      );
}

// ───────────────────────── Login / Register ─────────────────────────
class Login extends StatefulWidget {
  final AppState s;
  const Login(this.s, {super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool reg = false, hide = true;
  final n = TextEditingController(),
      e = TextEditingController(),
      pw = TextEditingController();
  String? err;
  AppState get s => widget.s;

  void submit() {
    final em = e.text.trim().toLowerCase();
    if (!em.contains('@') ||
        pw.text.length < 4 ||
        (reg && n.text.trim().isEmpty)) {
      setState(() => err = s.t('invalid'));
      return;
    }
    if (reg) {
      if (!s.register(n.text.trim(), em, pw.text)) {
        setState(() => err = s.t('exists'));
      }
    } else if (!s.signIn(em, pw.text)) {
      setState(() => err = s.t('wrong'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: s.grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(children: [
                  const Icon(Icons.local_fire_department,
                      size: 64, color: Colors.white),
                  Text(s.t('app'),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 18),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Wrap(spacing: 6, children: [
                          for (int i = 0; i < 6; i++)
                            ChoiceChip(
                              label: Text(_langNames[i]),
                              selected: s.lang == _codes[i],
                              onSelected: (_) => s.setLang(_codes[i]),
                            )
                        ]),
                        const SizedBox(height: 16),
                        if (reg) ...[
                          TextField(
                              controller: n,
                              decoration: InputDecoration(
                                  labelText: s.t('name'),
                                  prefixIcon: const Icon(Icons.person))),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                            controller: e,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: s.t('email'),
                                prefixIcon: const Icon(Icons.email))),
                        const SizedBox(height: 12),
                        TextField(
                            controller: pw,
                            obscureText: hide,
                            onSubmitted: (_) => submit(),
                            decoration: InputDecoration(
                                labelText: s.t('password'),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                    icon: Icon(hide
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () =>
                                        setState(() => hide = !hide)))),
                        const SizedBox(height: 16),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(s.t('theme'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(height: 4),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(s.t('themeHint'),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant))),
                        const SizedBox(height: 10),
                        ThemePicker(s),
                        if (err != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(err!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                          ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                              onPressed: submit,
                              child: Text(s.t(reg ? 'register' : 'login'))),
                        ),
                        TextButton(
                            onPressed: () => setState(() {
                                  reg = !reg;
                                  err = null;
                                }),
                            child: Text(s.t(reg ? 'haveAcc' : 'register'))),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Home shell ─────────────────────────
class Home extends StatefulWidget {
  final AppState s;
  const Home(this.s, {super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;
  AppState get s => widget.s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(s.t('app'))),
      body: IndexedStack(index: i, children: [
        Dash(s),
        HabitsPage(s),
        ProgressPage(s),
        StudyPage(s),
        SettingsPage(s),
      ]),
      floatingActionButton: i == 1
          ? FloatingActionButton.extended(
              onPressed: () => habitSheet(context, s),
              icon: const Icon(Icons.add),
              label: Text(s.t('addHabit')))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.dashboard), label: s.t('home')),
          NavigationDestination(
              icon: const Icon(Icons.checklist), label: s.t('habits')),
          NavigationDestination(
              icon: const Icon(Icons.insights), label: s.t('progress')),
          NavigationDestination(
              icon: const Icon(Icons.school), label: s.t('study')),
          NavigationDestination(
              icon: const Icon(Icons.settings), label: s.t('settings')),
        ],
      ),
    );
  }
}

// ───────────────────────── Small shared widgets ─────────────────────────
String fmtTime(BuildContext c, int m) =>
    TimeOfDay(hour: m ~/ 60, minute: m % 60).format(c);

Future<int?> pickTime(BuildContext c, int? init) async {
  final v = init == null || init < 0 ? 8 * 60 : init;
  final t = await showTimePicker(
      context: c, initialTime: TimeOfDay(hour: v ~/ 60, minute: v % 60));
  return t == null ? null : t.hour * 60 + t.minute;
}

class _Stepper extends StatelessWidget {
  final int value, step, lo, hi;
  final String unit;
  final ValueChanged<int> onChanged;
  const _Stepper(
      {required this.value,
      required this.onChanged,
      this.step = 1,
      this.lo = 1,
      this.hi = 240,
      this.unit = ''});

  @override
  Widget build(BuildContext context) {
    final dec = value - step < lo ? lo : value - step;
    final inc = value + step > hi ? hi : value + step;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton.filledTonal(
          onPressed: value > lo ? () => onChanged(dec) : null,
          icon: const Icon(Icons.remove)),
      SizedBox(
          width: 104,
          child: Text('$value $unit'.trim(),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      IconButton.filledTonal(
          onPressed: value < hi ? () => onChanged(inc) : null,
          icon: const Icon(Icons.add)),
    ]);
  }
}

// ───────────────────────── Timer-gated checkbox ─────────────────────────
// A task can only be ticked after its timer has run to the end.
// Leaving the app (or switching to another app) stops the timer.
Future<bool?> showTimerDialog(BuildContext ctx, AppState s,
        {required String title,
        required String gateKey,
        required int initialMins,
        ValueChanged<int>? onMinsChosen,
        bool gym = false}) =>
    showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => TimerDialog(
          s: s,
          title: title,
          gateKey: gateKey,
          initialMins: initialMins,
          onMinsChosen: onMinsChosen,
          gym: gym),
    );

class TimerDialog extends StatefulWidget {
  final AppState s;
  final String title, gateKey;
  final int initialMins;
  final ValueChanged<int>? onMinsChosen; // remembers the user's timer length
  final bool gym;
  const TimerDialog(
      {required this.s,
      required this.title,
      required this.gateKey,
      required this.initialMins,
      this.onMinsChosen,
      this.gym = false,
      super.key});
  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

enum _Phase { pick, running, finished }

class _TimerDialogState extends State<TimerDialog> with WidgetsBindingObserver {
  _Phase phase = _Phase.pick;
  late int mins = widget.initialMins;
  int left = 0;
  bool interrupted = false;
  Timer? tm;
  AppState get s => widget.s;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tm?.cancel();
    super.dispose();
  }

  // App left the foreground -> stop the timer, the user must start again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (phase != _Phase.running) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      tm?.cancel();
      tm = null;
      setState(() {
        phase = _Phase.pick;
        interrupted = true;
      });
    }
  }

  void start() {
    widget.onMinsChosen?.call(mins);
    setState(() {
      phase = _Phase.running;
      left = mins * 60;
      interrupted = false;
    });
    tm = Timer.periodic(const Duration(seconds: 1), (_) {
      if (left <= 1) {
        tm?.cancel();
        tm = null;
        s.unlock(widget.gateKey);
        HapticFeedback.mediumImpact();
        setState(() {
          left = 0;
          phase = _Phase.finished;
        });
      } else {
        setState(() => left--);
      }
    });
  }

  String get clock =>
      '${(left ~/ 60).toString().padLeft(2, '0')}:${(left % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget body;
    List<Widget> actions;

    switch (phase) {
      case _Phase.pick:
        body = Column(mainAxisSize: MainAxisSize.min, children: [
          if (interrupted)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(s.t('timerStopped'),
                        style: TextStyle(color: cs.onErrorContainer))),
              ]),
            ),
          Text(s.t(widget.gym ? 'askGym' : 'askTask'),
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 14),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final m in [5, 10, 15, 20, 30, 45, 60, 90])
                  ChoiceChip(
                      label: Text('$m'),
                      selected: mins == m,
                      onSelected: (_) => setState(() => mins = m)),
              ]),
          const SizedBox(height: 10),
          _Stepper(
              value: mins,
              step: 5,
              unit: s.t('min'),
              onChanged: (v) => setState(() => mins = v)),
          const SizedBox(height: 12),
          Text(s.t('stayHint'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ]);
        actions = [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.t('cancel'))),
          FilledButton.icon(
              onPressed: start,
              icon: const Icon(Icons.play_arrow),
              label: Text(s.t('start'))),
        ];
        break;

      case _Phase.running:
        body = Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 190,
            height: 190,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                  value: 1 - left / (mins * 60), strokeWidth: 10),
              Center(
                  child: Text(clock,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold))),
            ]),
          ),
          const SizedBox(height: 16),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
                child: Text(s.t('stayHint'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
          ]),
        ]);
        actions = [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.t('stopTimer'))),
        ];
        break;

      case _Phase.finished:
        body = Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, size: 72, color: Colors.green),
          const SizedBox(height: 8),
          Text(s.t('greatJob'),
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(s.t('unlockedMsg'), textAlign: TextAlign.center),
        ]);
        actions = [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.t('later'))),
          FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check),
              label: Text(s.t('markDone'))),
        ];
        break;
    }

    return PopScope(
      canPop: phase != _Phase.running, // no accidental back-swipe mid-timer
      child: AlertDialog(
        title:
            Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        content: AnimatedSize(
            duration: const Duration(milliseconds: 200), child: body),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: actions,
      ),
    );
  }
}

/// A checkbox row that stays locked until the task's timer has finished.
class GatedTile extends StatelessWidget {
  final AppState s;
  final String gateKey, title;
  final bool done, gym;
  final int defaultMin;
  final ValueChanged<int>? onMinsChosen;
  final Widget? leading;
  final String? subtitle;
  final TextStyle? titleStyle;
  final VoidCallback onToggle;
  const GatedTile(
      {required this.s,
      required this.gateKey,
      required this.title,
      required this.done,
      required this.onToggle,
      required this.defaultMin,
      this.onMinsChosen,
      this.gym = false,
      this.leading,
      this.subtitle,
      this.titleStyle,
      super.key});

  Future<void> _runTimer(BuildContext context) async {
    final r = await showTimerDialog(context, s,
        title: title,
        gateKey: gateKey,
        initialMins: defaultMin,
        onMinsChosen: onMinsChosen,
        gym: gym);
    if (r == true) onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final open = done || s.isUnlocked(gateKey);
    return ListTile(
      leading: leading,
      title: Text(title, style: titleStyle),
      onTap: open ? onToggle : () => _runTimer(context),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (subtitle != null) Text(subtitle!),
        if (!done)
          Row(children: [
            Icon(open ? Icons.lock_open : Icons.lock_outline,
                size: 14, color: open ? Colors.green : cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
                child: Text(s.t(open ? 'unlockedMsg' : 'lockedMsg'),
                    style: TextStyle(
                        fontSize: 12,
                        color: open ? Colors.green : cs.onSurfaceVariant))),
          ]),
      ]),
      trailing: open
          ? Checkbox(value: done, onChanged: (_) => onToggle())
          : Row(mainAxisSize: MainAxisSize.min, children: [
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact),
                onPressed: () => _runTimer(context),
                icon: const Icon(Icons.timer, size: 18),
                label: Text('$defaultMin ${s.t('min')}'),
              ),
              const Checkbox(value: false, onChanged: null), // locked
            ]),
    );
  }
}

/// Water: tap + for every glass; the habit completes when the goal is reached.
class WaterTile extends StatelessWidget {
  final AppState s;
  final Habit h;
  final String k;
  final Widget leading;
  const WaterTile(
      {required this.s,
      required this.h,
      required this.k,
      required this.leading,
      super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = h.cnt[k] ?? 0;
    final done = c >= h.goal;
    return ListTile(
      leading: leading,
      title: Text(h.name),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            '$c / ${h.goal} ${s.t('glasses')} · ${s.t('every')} ${h.mins} ${s.t('min')}',
            style: TextStyle(
                fontSize: 12, color: done ? Colors.green : cs.onSurfaceVariant)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
            value: (c / h.goal).clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8)),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            onPressed: c > 0 ? () => s.addWater(h, -1) : null,
            icon: const Icon(Icons.remove_circle_outline)),
        IconButton.filled(
            onPressed: () => s.addWater(h, 1),
            icon: Icon(done ? Icons.check : Icons.add)),
      ]),
    );
  }
}

/// Sleep / wake-up: the checkbox unlocks once the set time has arrived.
class ClockTile extends StatefulWidget {
  final AppState s;
  final Habit h;
  final String k;
  final Widget leading;
  const ClockTile(
      {required this.s,
      required this.h,
      required this.k,
      required this.leading,
      super.key});
  @override
  State<ClockTile> createState() => _ClockTileState();
}

class _ClockTileState extends State<ClockTile> {
  Timer? tm;
  @override
  void initState() {
    super.initState();
    tm = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    tm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s, h = widget.h;
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final done = h.done.contains(widget.k);
    final open = done || now.hour * 60 + now.minute >= h.rt;
    final time = fmtTime(context, h.rt);
    return ListTile(
      leading: widget.leading,
      title: Text(h.name),
      onTap: open
          ? () => s.toggle(h)
          : () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${s.t('unlocksAt')} $time'))),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(h.kind == 3 ? Icons.alarm : Icons.bedtime_outlined,
              size: 14, color: cs.primary),
          const SizedBox(width: 4),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        if (!done)
          Text(open ? s.t('timeReached') : '${s.t('unlocksAt')} $time',
              style: TextStyle(
                  fontSize: 12,
                  color: open ? Colors.green : cs.onSurfaceVariant)),
      ]),
      trailing: Checkbox(
          value: done, onChanged: open ? (_) => s.toggle(h) : null),
    );
  }
}

Widget habitTile(BuildContext ctx, AppState s, Habit h, String k) {
  final cs = Theme.of(ctx).colorScheme;
  final lead = CircleAvatar(
      backgroundColor: cs.primaryContainer,
      child: Icon(_icons[h.icon], color: cs.primary));
  switch (h.kind) {
    case 1:
      return WaterTile(s: s, h: h, k: k, leading: lead);
    case 2:
    case 3:
      return ClockTile(s: s, h: h, k: k, leading: lead);
    default:
      return GatedTile(
        s: s,
        gateKey: 'h|${h.id}|$k',
        title: h.name,
        done: h.done.contains(k),
        defaultMin: h.mins,
        gym: _gymIcons.contains(h.icon),
        onMinsChosen: (m) => s.setHabitMins(h, m),
        onToggle: () => s.toggle(h),
        leading: lead,
        subtitle: h.rt >= 0 ? '🔔 ${fmtTime(ctx, h.rt)}' : null,
      );
  }
}

// ───────────────────────── Dashboard ─────────────────────────
class Dash extends StatelessWidget {
  final AppState s;
  const Dash(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = s.todayHabits;
    final k = dayKey(DateTime.now());
    final done = today.where((h) => h.done.contains(k)).length;
    final pct = today.isEmpty ? 0.0 : done / today.length;

    Widget stat(IconData ic, String v, String l) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                Icon(ic, color: cs.primary, size: 30),
                Text(v,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ),
        );

    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: s.grad),
            borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s.t('hello')}, ${s.user?['n'] ?? ''}!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${s.t('today')}: $done / ${today.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ]),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 8,
                  color: Colors.white,
                  backgroundColor: Colors.white24),
              Center(
                  child: Text('${(pct * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      Row(children: [
        stat(Icons.local_fire_department, '${s.streak}', s.t('streak')),
        stat(Icons.timer, '${s.focusToday}', s.t('focusToday')),
      ]),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.t('week'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 6; i >= 0; i--)
                  Builder(builder: (_) {
                    final d = DateTime.now().subtract(Duration(days: i));
                    final f = s.dayFrac(d);
                    return Column(children: [
                      Container(
                        width: 26,
                        height: 80,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(8)),
                        child: Container(
                            height: 4 + 76 * f,
                            decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(8))),
                      ),
                      const SizedBox(height: 4),
                      Text(_wd[d.weekday - 1],
                          style: const TextStyle(fontSize: 12)),
                    ]);
                  }),
              ],
            ),
          ]),
        ),
      ),
      if (s.habits.isEmpty)
        Padding(
            padding: const EdgeInsets.all(24),
            child: Text(s.t('noHabits'), textAlign: TextAlign.center)),
      for (final h in today) Card(child: habitTile(context, s, h, k)),
    ]);
  }
}

// ───────────────────────── Habits ─────────────────────────
class HabitsPage extends StatelessWidget {
  final AppState s;
  const HabitsPage(this.s, {super.key});

  String _detail(BuildContext c, Habit h) {
    switch (h.kind) {
      case 1:
        return '💧 ${h.goal} ${s.t('glasses')} · ${s.t('every')} ${h.mins} ${s.t('min')}';
      case 2:
        return '🌙 ${fmtTime(c, h.rt)}';
      case 3:
        return '⏰ ${fmtTime(c, h.rt)}';
      default:
        return '⏱ ${h.mins} ${s.t('min')}${h.rt >= 0 ? '  ·  🔔 ${fmtTime(c, h.rt)}' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (s.habits.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(s.t('noHabits'), textAlign: TextAlign.center)));
    }
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          for (final h in s.habits)
            Card(
              child: ListTile(
                onTap: () => habitSheet(context, s, h),
                leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(_icons[h.icon], color: cs.primary)),
                title: Text(h.name),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.days.map((d) => _wd[d - 1]).join(' · ')),
                      Text(_detail(context, h),
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant)),
                    ]),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => s.removeHabit(h)),
              ),
            ),
        ]);
  }
}

/// Add a habit, or edit [edit] when given.
void habitSheet(BuildContext ctx, AppState s, [Habit? edit]) {
  final c = TextEditingController(text: edit?.name ?? '');
  int icon = edit?.icon ?? 0,
      kind = edit?.kind ?? 0,
      mins = edit?.mins ?? 30,
      rt = edit?.rt ?? -1,
      goal = edit?.goal ?? 8,
      re = edit?.re ?? 22 * 60;
  final days = <int>{...(edit?.days ?? [1, 2, 3, 4, 5, 6, 7])};
  String? err;

  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sc) => StatefulBuilder(
      builder: (bc, set) {
        final cs = Theme.of(bc).colorScheme;

        void setKind(int k) => set(() {
              if (k == kind) return;
              kind = k;
              err = null;
              if (k == 0) {
                mins = 30;
                rt = -1;
              } else if (k == 1) {
                mins = 30;
                rt = 8 * 60;
                re = 22 * 60;
                goal = 8;
              } else if (k == 2) {
                rt = 22 * 60 + 30;
              } else {
                rt = -1; // wake-up: the user must choose
              }
            });

        void applyTpl(Tpl t) => set(() {
              c.text = s.t(t.key);
              icon = t.icon;
              kind = t.kind;
              mins = t.mins;
              rt = t.rt;
              goal = t.goal;
              re = 22 * 60;
              err = null;
            });

        Widget timeButton(String label, int value, ValueChanged<int> on,
                {bool required = false}) =>
            OutlinedButton.icon(
              onPressed: () async {
                final v = await pickTime(bc, value);
                if (v != null) set(() => on(v));
              },
              icon: const Icon(Icons.access_time),
              label: Text(value < 0
                  ? s.t('setTime')
                  : '$label  ${fmtTime(bc, value)}'),
              style: required && value < 0
                  ? OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error))
                  : null,
            );

        Widget label(String key) => Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(s.t(key),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            );

        void save() {
          final name = c.text.trim();
          if (name.isEmpty || days.isEmpty) {
            set(() => err = s.t('invalid'));
            return;
          }
          if ((kind == 2 || kind == 3) && rt < 0) {
            set(() => err = s.t('needTime'));
            return;
          }
          if (kind == 1 && re <= rt) {
            set(() => err = s.t('badRange'));
            return;
          }
          if (edit != null) {
            edit
              ..name = name
              ..icon = icon
              ..kind = kind
              ..mins = mins
              ..rt = rt
              ..goal = goal
              ..re = re
              ..days = (days.toList()..sort());
            s.updateHabit(edit);
          } else {
            s.addHabit(Habit(
                DateTime.now().microsecondsSinceEpoch.toString(),
                name,
                icon,
                days.toList()..sort(),
                {},
                kind: kind,
                mins: mins,
                rt: rt,
                goal: goal,
                re: re));
          }
          Navigator.pop(bc);
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.of(bc).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t(edit == null ? 'addHabit' : 'editHabit'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                if (edit == null) ...[
                  label('templates'),
                  Wrap(spacing: 6, runSpacing: 4, children: [
                    for (final t in _templates)
                      ActionChip(
                        avatar: Icon(_icons[t.icon], size: 18),
                        label: Text(s.t(t.key)),
                        onPressed: () => applyTpl(t),
                      ),
                  ]),
                ],
                const SizedBox(height: 14),
                TextField(
                    controller: c,
                    decoration: InputDecoration(labelText: s.t('habitName'))),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final k in [0, 1, 2, 3])
                    ChoiceChip(
                      avatar: Icon([
                        Icons.timer,
                        Icons.water_drop,
                        Icons.bedtime,
                        Icons.alarm
                      ][k], size: 18),
                      label: Text(s.t(['kTimer', 'kWater', 'kSleep', 'kWake'][k])),
                      selected: kind == k,
                      onSelected: (_) => setKind(k),
                    ),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (int i = 0; i < _icons.length; i++)
                    ChoiceChip(
                      label: Icon(_icons[i], size: 20),
                      selected: icon == i,
                      onSelected: (_) => set(() => icon = i),
                    ),
                ]),

                // ── type-specific settings ──
                if (kind == 0) ...[
                  label('timerMin'),
                  Center(
                      child: _Stepper(
                          value: mins,
                          step: 5,
                          unit: s.t('min'),
                          onChanged: (v) => set(() => mins = v))),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.t('reminderOpt')),
                    value: rt >= 0,
                    onChanged: (v) => set(() => rt = v ? 8 * 60 : -1),
                  ),
                  if (rt >= 0)
                    timeButton('🔔', rt, (v) => rt = v),
                ],
                if (kind == 1) ...[
                  label('remindEvery'),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final m in [15, 30, 45, 60, 90, 120])
                      ChoiceChip(
                          label: Text('$m ${s.t('min')}'),
                          selected: mins == m,
                          onSelected: (_) => set(() => mins = m)),
                  ]),
                  const SizedBox(height: 8),
                  Center(
                      child: _Stepper(
                          value: mins,
                          step: 5,
                          lo: 5,
                          hi: 240,
                          unit: s.t('min'),
                          onChanged: (v) => set(() => mins = v))),
                  label('goalGlasses'),
                  Center(
                      child: _Stepper(
                          value: goal,
                          lo: 1,
                          hi: 20,
                          onChanged: (v) => set(() => goal = v))),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    timeButton(s.t('fromTime'), rt, (v) => rt = v),
                    timeButton(s.t('toTime'), re, (v) => re = v),
                  ]),
                ],
                if (kind == 2) ...[
                  label('bedtime'),
                  timeButton('🌙', rt, (v) => rt = v, required: true),
                ],
                if (kind == 3) ...[
                  label('wakeTime'),
                  timeButton('⏰', rt, (v) => rt = v, required: true),
                ],

                label('days'),
                Wrap(spacing: 6, children: [
                  for (int d = 1; d <= 7; d++)
                    FilterChip(
                      label: Text(_wd[d - 1]),
                      selected: days.contains(d),
                      onSelected: (v) =>
                          set(() => v ? days.add(d) : days.remove(d)),
                    ),
                ]),
                if (err != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(err!, style: TextStyle(color: cs.error)),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                      onPressed: save, child: Text(s.t('save'))),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ───────────────────────── Progress ─────────────────────────
class ProgressPage extends StatelessWidget {
  final AppState s;
  const ProgressPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (s.habits.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(s.t('noHabits'), textAlign: TextAlign.center)));
    }
    final total = s.habits.fold<int>(0, (a, h) => a + h.done.length);

    Widget stat(IconData ic, String v, String l) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Column(children: [
                Icon(ic, color: cs.primary, size: 28),
                const SizedBox(height: 4),
                Text(v,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ),
        );

    final now = DateTime.now();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        stat(Icons.local_fire_department, '${s.streak}', s.t('streak')),
        stat(Icons.percent, '${(s.overallRate(7) * 100).round()}%',
            s.t('weekRate')),
        stat(Icons.task_alt, '$total', s.t('totalDone')),
      ]),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.t('last30'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (int i = 29; i >= 0; i--)
                Builder(builder: (_) {
                  final d = now.subtract(Duration(days: i));
                  final f = s.dayFrac(d);
                  final sched = s.habits.any((h) => h.days.contains(d.weekday));
                  return Tooltip(
                    message: dayKey(d),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: !sched
                            ? cs.surfaceContainerHighest
                            : Color.lerp(cs.primaryContainer, cs.primary, f),
                      ),
                    ),
                  );
                }),
            ]),
          ]),
        ),
      ),
      for (final h in s.habits)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(_icons[h.icon], color: cs.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(h.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                Text('${(s.habitRate(h, 30) * 100).round()}%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: cs.primary)),
              ]),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                  value: s.habitRate(h, 30),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 8),
              Wrap(spacing: 14, children: [
                Text('🔥 ${s.habitStreak(h)} ${s.t('streak')}',
                    style: const TextStyle(fontSize: 12)),
                Text('✅ ${h.done.length} ${s.t('totalDone')}',
                    style: const TextStyle(fontSize: 12)),
                if (h.kind == 0)
                  Text(
                      '⏱ ${h.md.values.fold<int>(0, (a, b) => a + b)} ${s.t('min')}',
                      style: const TextStyle(fontSize: 12)),
                if (h.kind == 1)
                  Text(
                      '💧 ${h.cnt[dayKey(now)] ?? 0}/${h.goal} ${s.t('glasses')}',
                      style: const TextStyle(fontSize: 12)),
              ]),
            ]),
          ),
        ),
    ]);
  }
}

// ───────────────────────── Study (students & learners) ─────────────────────────
class StudyPage extends StatelessWidget {
  final AppState s;
  const StudyPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Column(children: [
          TabBar(tabs: [
            Tab(icon: const Icon(Icons.timer), text: s.t('focus')),
            Tab(icon: const Icon(Icons.task_alt), text: s.t('tasks')),
            Tab(icon: const Icon(Icons.event), text: s.t('exams')),
          ]),
          Expanded(
            child: TabBarView(children: [
              FocusTab(s),
              TasksTab(s),
              ExamsTab(s),
            ]),
          ),
        ]),
      );
}

class FocusTab extends StatefulWidget {
  final AppState s;
  const FocusTab(this.s, {super.key});
  @override
  State<FocusTab> createState() => _FocusTabState();
}

class _FocusTabState extends State<FocusTab> {
  int mins = 25;
  late int left = mins * 60;
  Timer? tm;
  AppState get s => widget.s;

  void toggle() {
    if (tm != null) {
      tm!.cancel();
      setState(() => tm = null);
      return;
    }
    tm = Timer.periodic(const Duration(seconds: 1), (_) {
      if (left <= 1) {
        tm?.cancel();
        s.addFocus(mins);
        setState(() {
          tm = null;
          left = mins * 60;
        });
      } else {
        setState(() => left--);
      }
    });
    setState(() {});
  }

  void reset() {
    tm?.cancel();
    setState(() {
      tm = null;
      left = mins * 60;
    });
  }

  @override
  void dispose() {
    tm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (left ~/ 60).toString().padLeft(2, '0');
    final ss = (left % 60).toString().padLeft(2, '0');
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Wrap(spacing: 8, children: [
            for (final m in [15, 25, 45])
              ChoiceChip(
                label: Text('$m'),
                selected: mins == m,
                onSelected: tm != null
                    ? null
                    : (_) => setState(() {
                          mins = m;
                          left = m * 60;
                        }),
              ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                  value: 1 - left / (mins * 60), strokeWidth: 12),
              Center(
                  child: Text('$mm:$ss',
                      style: const TextStyle(
                          fontSize: 46, fontWeight: FontWeight.bold))),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisSize: MainAxisSize.min, children: [
            FilledButton.icon(
                onPressed: toggle,
                icon: Icon(tm != null ? Icons.pause : Icons.play_arrow),
                label: Text(s.t(tm != null ? 'pause' : 'start'))),
            const SizedBox(width: 12),
            OutlinedButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh),
                label: Text(s.t('reset'))),
          ]),
          const SizedBox(height: 20),
          Text('${s.t('focusToday')}: ${s.focusToday}'),
        ]),
      ),
    );
  }
}

class TasksTab extends StatefulWidget {
  final AppState s;
  const TasksTab(this.s, {super.key});
  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final c = TextEditingController();
  DateTime? due;
  AppState get s => widget.s;

  void add() {
    if (c.text.trim().isEmpty) return;
    s.addTask(Task(DateTime.now().microsecondsSinceEpoch.toString(),
        c.text.trim(), false, due == null ? null : dayKey(due!)));
    c.clear();
    setState(() => due = null);
  }

  Future<void> pick() async {
    final now = DateTime.now();
    final d = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now.subtract(const Duration(days: 1)),
        lastDate: now.add(const Duration(days: 3650)));
    if (d != null) setState(() => due = d);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
              child: TextField(
                  controller: c,
                  onSubmitted: (_) => add(),
                  decoration: InputDecoration(
                      hintText: s.t('newTask'),
                      helperText: due == null ? null : dayKey(due!)))),
          IconButton(onPressed: pick, icon: const Icon(Icons.event)),
          IconButton.filled(onPressed: add, icon: const Icon(Icons.add)),
        ]),
      ),
      Expanded(
        child: ListView(children: [
          for (final x in s.tasks)
            Dismissible(
              key: ValueKey(x.id),
              onDismissed: (_) => s.removeTask(x.id),
              background: Container(color: Colors.redAccent),
              child: GatedTile(
                s: s,
                gateKey: 't|${x.id}',
                title: x.title,
                done: x.done,
                defaultMin: _studyMinutes, // study tasks: 30 min, adjustable in the timer
                subtitle: x.due,
                onToggle: () => s.toggleTask(x),
                titleStyle: TextStyle(
                    decoration: x.done ? TextDecoration.lineThrough : null),
              ),
            ),
        ]),
      ),
    ]);
  }
}

class ExamsTab extends StatelessWidget {
  final AppState s;
  const ExamsTab(this.s, {super.key});

  Future<void> add(BuildContext ctx) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dc) => AlertDialog(
        title: Text(s.t('addExam')),
        content: TextField(
            controller: c,
            autofocus: true,
            decoration: InputDecoration(labelText: s.t('examName'))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dc, false),
              child: Text(s.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(dc, true),
              child: Text(s.t('save'))),
        ],
      ),
    );
    if (ok != true || c.text.trim().isEmpty || !ctx.mounted) return;
    final now = DateTime.now();
    final d = await showDatePicker(
        context: ctx,
        initialDate: now.add(const Duration(days: 30)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 3650)));
    if (d != null) {
      s.addExam(Exam(
          now.microsecondsSinceEpoch.toString(), c.text.trim(), dayKey(d)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    final list = [...s.exams]..sort((a, b) => a.date.compareTo(b.date));
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
              onPressed: () => add(context),
              icon: const Icon(Icons.add),
              label: Text(s.t('addExam'))),
        ),
      ),
      Expanded(
        child: ListView(children: [
          for (final x in list)
            Dismissible(
              key: ValueKey(x.id),
              onDismissed: (_) => s.removeExam(x.id),
              background: Container(color: Colors.redAccent),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(x.name),
                  subtitle: Text(x.date),
                  trailing: Chip(
                      label: Text(
                          '${DateTime.parse(x.date).difference(base).inDays} ${s.t('left')}')),
                ),
              ),
            ),
        ]),
      ),
    ]);
  }
}

// ───────────────────────── Settings ─────────────────────────
class SettingsPage extends StatelessWidget {
  final AppState s;
  const SettingsPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ListTile(
        leading: CircleAvatar(
            child: Text(((s.user?['n'] ?? '?') as String)
                .characters
                .first
                .toUpperCase())),
        title: Text(s.user?['n'] ?? ''),
        subtitle: Text(s.user?['e'] ?? ''),
      ),
      const Divider(),
      Text(s.t('language'),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [
        for (int i = 0; i < 6; i++)
          ChoiceChip(
              label: Text(_langNames[i]),
              selected: s.lang == _codes[i],
              onSelected: (_) => s.setLang(_codes[i])),
      ]),
      const SizedBox(height: 16),
      Text(s.t('theme'), style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(s.t('themeHint'),
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      ThemePicker(s, labeled: true),
      SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s.t('dark')),
          value: s.dark,
          onChanged: s.setDark),
      const SizedBox(height: 12),
      OutlinedButton.icon(
          onPressed: () async {
            await Notifier.test(s);
            if (!context.mounted || Notifier.ready) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(s.t('notifOff'))));
          },
          icon: const Icon(Icons.notifications_active),
          label: Text(s.t('testNotif'))),
      const SizedBox(height: 8),
      OutlinedButton.icon(
          onPressed: s.logout,
          icon: const Icon(Icons.logout),
          label: Text(s.t('logout'))),
    ]);
  }
}
