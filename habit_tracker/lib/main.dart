import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ───────────────────────── Languages ─────────────────────────
const _codes = ['en', 'ta', 'hi', 'te', 'es', 'fr'];
const _langNames = ['English', 'தமிழ்', 'हिन्दी', 'తెలుగు', 'Español', 'Français'];

// Order: en, ta, hi, te, es, fr
const Map<String, List<String>> _s = {
  'app': ['Habit Tracker', 'பழக்க கண்காணிப்பு', 'आदत ट्रैकर', 'అలవాటు ట్రాకర్', 'Rastreador de hábitos', 'Suivi d’habitudes'],
  'login': ['Login', 'உள்நுழை', 'लॉगिन', 'లాగిన్', 'Entrar', 'Connexion'],
  'register': ['Create account', 'கணக்கு உருவாக்கு', 'खाता बनाएँ', 'ఖాతా సృష్టించు', 'Crear cuenta', 'Créer un compte'],
  'haveAcc': ['I have an account', 'என்னிடம் கணக்கு உள்ளது', 'मेरे पास खाता है', 'నాకు ఖాతా ఉంది', 'Ya tengo cuenta', 'J’ai un compte'],
  'name': ['Name', 'பெயர்', 'नाम', 'పేరు', 'Nombre', 'Nom'],
  'email': ['Email', 'மின்னஞ்சல்', 'ईमेल', 'ఇమెయిల్', 'Correo', 'E-mail'],
  'password': ['Password', 'கடவுச்சொல்', 'पासवर्ड', 'పాస్‌వర్డ్', 'Contraseña', 'Mot de passe'],
  'language': ['Language', 'மொழி', 'भाषा', 'భాష', 'Idioma', 'Langue'],
  'hello': ['Hello', 'வணக்கம்', 'नमस्ते', 'హలో', 'Hola', 'Bonjour'],
  'home': ['Home', 'முகப்பு', 'होम', 'హోమ్', 'Inicio', 'Accueil'],
  'habits': ['Habits', 'பழக்கங்கள்', 'आदतें', 'అలవాట్లు', 'Hábitos', 'Habitudes'],
  'study': ['Study', 'படிப்பு', 'पढ़ाई', 'చదువు', 'Estudio', 'Études'],
  'settings': ['Settings', 'அமைப்புகள்', 'सेटिंग्स', 'సెట్టింగ్‌లు', 'Ajustes', 'Réglages'],
  'today': ['Today', 'இன்று', 'आज', 'నేడు', 'Hoy', 'Aujourd’hui'],
  'streak': ['Day streak', 'தொடர் நாட்கள்', 'लगातार दिन', 'వరుస రోజులు', 'Racha', 'Série'],
  'focusToday': ['Focus today (min)', 'இன்றைய கவனம் (நிமி)', 'आज फोकस (मिनट)', 'నేటి ఫోకస్ (నిమి)', 'Enfoque hoy (min)', 'Focus du jour (min)'],
  'week': ['This week', 'இந்த வாரம்', 'इस सप्ताह', 'ఈ వారం', 'Esta semana', 'Cette semaine'],
  'addHabit': ['New habit', 'புதிய பழக்கம்', 'नई आदत', 'కొత్త అలవాటు', 'Nuevo hábito', 'Nouvelle habitude'],
  'habitName': ['Habit name', 'பழக்கத்தின் பெயர்', 'आदत का नाम', 'అలవాటు పేరు', 'Nombre del hábito', 'Nom de l’habitude'],
  'days': ['Repeat on', 'நாட்கள்', 'दोहराएँ', 'రిపీట్', 'Repetir', 'Répéter'],
  'templates': ['Student plans', 'மாணவர் திட்டங்கள்', 'छात्र योजनाएँ', 'విద్యార్థి ప్లాన్లు', 'Planes de estudiante', 'Plans étudiants'],
  'save': ['Save', 'சேமி', 'सहेजें', 'సేవ్', 'Guardar', 'Enregistrer'],
  'cancel': ['Cancel', 'ரத்து', 'रद्द करें', 'రద్దు', 'Cancelar', 'Annuler'],
  'focus': ['Focus', 'கவனம்', 'फोकस', 'ఫోకస్', 'Enfoque', 'Focus'],
  'tasks': ['Tasks', 'பணிகள்', 'कार्य', 'పనులు', 'Tareas', 'Tâches'],
  'exams': ['Exams', 'தேர்வுகள்', 'परीक्षाएँ', 'పరీక్షలు', 'Exámenes', 'Examens'],
  'start': ['Start', 'தொடங்கு', 'शुरू', 'ప్రారంభం', 'Iniciar', 'Démarrer'],
  'pause': ['Pause', 'இடைநிறுத்து', 'रोकें', 'ఆపు', 'Pausa', 'Pause'],
  'reset': ['Reset', 'மீட்டமை', 'रीसेट', 'రీసెట్', 'Reiniciar', 'Réinitialiser'],
  'newTask': ['New task', 'புதிய பணி', 'नया कार्य', 'కొత్త పని', 'Nueva tarea', 'Nouvelle tâche'],
  'examName': ['Exam name', 'தேர்வு பெயர்', 'परीक्षा का नाम', 'పరీక్ష పేరు', 'Nombre del examen', 'Nom de l’examen'],
  'addExam': ['Add exam', 'தேர்வு சேர்', 'परीक्षा जोड़ें', 'పరీక్ష జోడించు', 'Añadir examen', 'Ajouter un examen'],
  'left': ['days left', 'நாட்கள் உள்ளன', 'दिन बाकी', 'రోజులు మిగిలి', 'días restantes', 'jours restants'],
  'logout': ['Log out', 'வெளியேறு', 'लॉग आउट', 'లాగ్ అవుట్', 'Cerrar sesión', 'Déconnexion'],
  'dark': ['Dark mode', 'இருள் பயன்முறை', 'डार्क मोड', 'డార్క్ మోడ్', 'Modo oscuro', 'Mode sombre'],
  'theme': ['Color theme', 'நிறத் தீம்', 'रंग थीम', 'రంగు థీమ్', 'Tema de color', 'Thème de couleur'],
  'themeHint': ['Pick a look you like', 'உங்களுக்குப் பிடித்த தோற்றம்', 'अपनी पसंद का लुक चुनें', 'మీకు నచ్చిన రూపం ఎంచుకోండి', 'Elige el aspecto que te guste', 'Choisissez un look'],
  'thOcean': ['Ocean', 'கடல்', 'महासागर', 'సముద్రం', 'Océano', 'Océan'],
  'thBlossom': ['Blossom', 'மலர்', 'पुष्प', 'పుష్పం', 'Flor', 'Floraison'],
  'thSunset': ['Sunset', 'அஸ்தமனம்', 'सूर्यास्त', 'సూర్యాస్తమయం', 'Atardecer', 'Coucher'],
  'thForest': ['Forest', 'காடு', 'वन', 'అడవి', 'Bosque', 'Forêt'],
  'thMidnight': ['Midnight', 'நள்ளிரவு', 'मध्यरात्रि', 'అర్ధరాత్రి', 'Medianoche', 'Minuit'],
  'thEmber': ['Ember', 'தணல்', 'अंगार', 'నిప్పు', 'Ascua', 'Braise'],
  'thAurora': ['Aurora', 'அரோரா', 'अरोरा', 'అరోరా', 'Aurora', 'Aurore'],
  'thGrape': ['Grape', 'திராட்சை', 'अंगूर', 'ద్రాక్ష', 'Uva', 'Raisin'],
  'thSlate': ['Slate', 'சாம்பல்', 'स्लेट', 'స్లేట్', 'Pizarra', 'Ardoise'],
  'thCrimson': ['Crimson', 'கிரிம்சன்', 'क्रिमसन', 'క్రిమ్సన్', 'Carmesí', 'Cramoisi'],
  'thCitrus': ['Citrus', 'சிட்ரஸ்', 'साइट्रस', 'సిట్రస్', 'Cítricos', 'Agrumes'],
  'thArctic': ['Arctic', 'ஆர்க்டிக்', 'आर्कटिक', 'ఆర్క్టిక్', 'Ártico', 'Arctique'],
  'invalid': ['Check your details', 'விவரங்களை சரிபார்க்கவும்', 'विवरण जाँचें', 'వివరాలు తనిఖీ చేయండి', 'Revisa tus datos', 'Vérifiez vos informations'],
  'wrong': ['Wrong email or password', 'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல்', 'गलत ईमेल या पासवर्ड', 'తప్పు ఇమెయిల్ లేదా పాస్‌వర్డ్', 'Correo o contraseña incorrectos', 'E-mail ou mot de passe incorrect'],
  'noHabits': ['No habits yet. Add one in the Habits tab!', 'இன்னும் பழக்கங்கள் இல்லை. பழக்கங்கள் தாவலில் சேர்க்கவும்!', 'अभी कोई आदत नहीं। आदतें टैब में जोड़ें!', 'ఇంకా అలవాట్లు లేవు. అలవాట్లు ట్యాబ్‌లో జోడించండి!', 'Aún no hay hábitos. ¡Añade uno en Hábitos!', 'Aucune habitude. Ajoutez-en une dans Habitudes !'],
  'tplRead': ['Read 30 min', '30 நிமி படி', '30 मिनट पढ़ें', '30 నిమి చదువు', 'Leer 30 min', 'Lire 30 min'],
  'tplRevise': ['Revise notes', 'குறிப்புகளை மீள்பார்', 'नोट्स दोहराएँ', 'నోట్స్ రివైజ్ చేయి', 'Repasar apuntes', 'Réviser les notes'],
  'tplWater': ['Drink water', 'தண்ணீர் குடி', 'पानी पिएँ', 'నీళ్లు తాగు', 'Beber agua', 'Boire de l’eau'],
  'tplSleep': ['Sleep early', 'சீக்கிரம் தூங்கு', 'जल्दी सोएँ', 'త్వరగా నిద్రపో', 'Dormir temprano', 'Dormir tôt'],
  'tplMove': ['Exercise', 'உடற்பயிற்சி', 'व्यायाम', 'వ్యాయామం', 'Ejercicio', 'Exercice'],
};

const _templates = [
  ['tplRead', 0],
  ['tplRevise', 5],
  ['tplWater', 2],
  ['tplSleep', 3],
  ['tplMove', 1],
];

const _icons = <IconData>[
  Icons.menu_book, Icons.fitness_center, Icons.water_drop, Icons.bedtime,
  Icons.self_improvement, Icons.edit_note, Icons.directions_run, Icons.code,
  Icons.music_note, Icons.restaurant,
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
  int icon;
  List<int> days;
  Set<String> done;
  Habit(this.id, this.name, this.icon, this.days, this.done);
  Map<String, dynamic> toJson() =>
      {'id': id, 'n': name, 'i': icon, 'd': days, 'x': done.toList()};
  factory Habit.fromJson(Map j) => Habit(j['id'], j['n'], j['i'],
      List<int>.from(j['d']), Set<String>.from(j['x']));
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

  String t(String k) => _s[k]![_codes.indexOf(lang)];
  AppTheme get palette =>
      _themes.firstWhere((e) => e.id == themeId, orElse: () => _themes.first);
  List<Color> get grad => [palette.a, palette.b];

  Future<void> load() async {
    p = await SharedPreferences.getInstance();
    final u = p.getString('user');
    user = u == null ? null : Map<String, dynamic>.from(jsonDecode(u));
    loggedIn = (p.getBool('in') ?? false) && user != null;
    lang = p.getString('lang') ?? 'en';
    dark = p.getBool('dark') ?? false;
    themeId = p.getString('theme') ?? 'ocean';
    List l(String k) => jsonDecode(p.getString(k) ?? '[]') as List;
    habits = l('habits').map((e) => Habit.fromJson(e as Map)).toList();
    tasks = l('tasks').map((e) => Task.fromJson(e as Map)).toList();
    exams = l('exams').map((e) => Exam.fromJson(e as Map)).toList();
    focus = Map<String, int>.from(jsonDecode(p.getString('focus') ?? '{}'));
  }

  void save() {
    p.setString('user', jsonEncode(user));
    p.setBool('in', loggedIn);
    p.setString('lang', lang);
    p.setBool('dark', dark);
    p.setString('theme', themeId);
    p.setString('habits', jsonEncode(habits.map((e) => e.toJson()).toList()));
    p.setString('tasks', jsonEncode(tasks.map((e) => e.toJson()).toList()));
    p.setString('exams', jsonEncode(exams.map((e) => e.toJson()).toList()));
    p.setString('focus', jsonEncode(focus));
    notifyListeners();
  }

  // Auth (local only – swap for Firebase/your API for real accounts)
  void register(String n, String e, String pw) {
    user = {'n': n, 'e': e, 'h': hashPw(pw)};
    loggedIn = true;
    save();
  }

  bool signIn(String e, String pw) {
    if (user != null && user!['e'] == e && user!['h'] == hashPw(pw)) {
      loggedIn = true;
      save();
      return true;
    }
    return false;
  }

  void logout() {
    loggedIn = false;
    save();
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
  }

  void setDark(bool v) {
    dark = v;
    save();
  }

  // Habits
  List<Habit> get todayHabits =>
      habits.where((h) => h.days.contains(DateTime.now().weekday)).toList();

  void toggle(Habit h) {
    final k = dayKey(DateTime.now());
    h.done.contains(k) ? h.done.remove(k) : h.done.add(k);
    save();
  }

  void addHabit(Habit h) {
    habits.add(h);
    save();
  }

  void removeHabit(Habit h) {
    habits.remove(h);
    save();
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

// ───────────────────────── App ─────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = AppState();
  await s.load();
  runApp(App(s));
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
    if (!em.contains('@') || pw.text.length < 4 || (reg && n.text.trim().isEmpty)) {
      setState(() => err = s.t('invalid'));
      return;
    }
    if (reg) {
      s.register(n.text.trim(), em, pw.text);
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
                            child:
                                Text(s.t(reg ? 'haveAcc' : 'register'))),
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
          NavigationDestination(icon: const Icon(Icons.dashboard), label: s.t('home')),
          NavigationDestination(icon: const Icon(Icons.checklist), label: s.t('habits')),
          NavigationDestination(icon: const Icon(Icons.school), label: s.t('study')),
          NavigationDestination(icon: const Icon(Icons.settings), label: s.t('settings')),
        ],
      ),
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
                Text(l, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.t('week'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      Text(_wd[d.weekday - 1], style: const TextStyle(fontSize: 12)),
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
      for (final h in today)
        Card(
          child: CheckboxListTile(
            value: h.done.contains(k),
            onChanged: (_) => s.toggle(h),
            secondary: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(_icons[h.icon], color: cs.primary)),
            title: Text(h.name),
          ),
        ),
    ]);
  }
}

// ───────────────────────── Habits ─────────────────────────
class HabitsPage extends StatelessWidget {
  final AppState s;
  const HabitsPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (s.habits.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(s.t('noHabits'), textAlign: TextAlign.center)));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
      for (final h in s.habits)
        Card(
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(_icons[h.icon], color: cs.primary)),
            title: Text(h.name),
            subtitle: Text(h.days.map((d) => _wd[d - 1]).join(' · ')),
            trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => s.removeHabit(h)),
          ),
        ),
    ]);
  }
}

void habitSheet(BuildContext ctx, AppState s) {
  final c = TextEditingController();
  int icon = 0;
  final days = <int>{1, 2, 3, 4, 5, 6, 7};
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sc) => StatefulBuilder(
      builder: (bc, set) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(bc).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t('templates'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(spacing: 6, children: [
                for (final t in _templates)
                  ActionChip(
                    avatar: Icon(_icons[t[1] as int], size: 18),
                    label: Text(s.t(t[0] as String)),
                    onPressed: () => set(() {
                      c.text = s.t(t[0] as String);
                      icon = t[1] as int;
                    }),
                  ),
              ]),
              const SizedBox(height: 14),
              TextField(
                  controller: c,
                  decoration: InputDecoration(labelText: s.t('habitName'))),
              const SizedBox(height: 14),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (int i = 0; i < _icons.length; i++)
                  ChoiceChip(
                    label: Icon(_icons[i], size: 20),
                    selected: icon == i,
                    onSelected: (_) => set(() => icon = i),
                  ),
              ]),
              const SizedBox(height: 14),
              Text(s.t('days'), style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(spacing: 6, children: [
                for (int d = 1; d <= 7; d++)
                  FilterChip(
                    label: Text(_wd[d - 1]),
                    selected: days.contains(d),
                    onSelected: (v) =>
                        set(() => v ? days.add(d) : days.remove(d)),
                  ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    if (c.text.trim().isEmpty || days.isEmpty) return;
                    s.addHabit(Habit(
                        DateTime.now().microsecondsSinceEpoch.toString(),
                        c.text.trim(),
                        icon,
                        days.toList()..sort(),
                        {}));
                    Navigator.pop(bc);
                  },
                  child: Text(s.t('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
              child: CheckboxListTile(
                value: x.done,
                onChanged: (_) => s.toggleTask(x),
                title: Text(x.title,
                    style: TextStyle(
                        decoration:
                            x.done ? TextDecoration.lineThrough : null)),
                subtitle: x.due == null ? null : Text(x.due!),
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
      s.addExam(Exam(now.microsecondsSinceEpoch.toString(), c.text.trim(), dayKey(d)));
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
            child: Text(((s.user?['n'] ?? '?') as String).characters.first.toUpperCase())),
        title: Text(s.user?['n'] ?? ''),
        subtitle: Text(s.user?['e'] ?? ''),
      ),
      const Divider(),
      Text(s.t('language'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          onPressed: s.logout,
          icon: const Icon(Icons.logout),
          label: Text(s.t('logout'))),
    ]);
  }
}
