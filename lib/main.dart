import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrPage(
            text: 'Firebase init error',
          );

        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyHomePage(
            title: 'Platespot',
          );
        }
        return CircularProgressIndicator();
      }
    );
  }

}

class ErrPage extends StatelessWidget {
  const ErrPage({Key key, this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('FEL: $text'),
        ),
      ),
    );

  }

}

class MyHomePage extends StatefulWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  //Loading counter value on start
  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    //final firebaseAuth = FirebaseAuth.instance;
    //var user = await firebaseAuth.currentUser;
    //print(user.toString());
    setState(() {
      _counter = (prefs.getInt('counter') ?? 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  void _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
      if (_counter == 1000) {
        _counter = 1;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(' FÄRDIG!!**!!**!!')));
      }
      prefs.setInt('counter', _counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  child: Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'Meny',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Ställ in nästa nummer'),
                  onTap: () {
                    Navigator.pop(context);
                    _setCounter();
                  },
                ),
                ListTile(
                  title: const Text('Om'),
                  onTap: () {
                    _showVersion();
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Nummer att leta efter:',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 30,
                )
              ),
              GestureDetector(
                onLongPress: _setCounter,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    getTextForCounter(_counter),
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
              TextButton(
                child: Text('Hittat'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 10,
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(10)),),
                   textStyle: TextStyle(
                     fontSize: 50,
                     fontWeight: FontWeight.w300,
                   ),
                ),
                onPressed: _incrementCounter,
              ),
            ],
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: SizedBox(
        //   width: 200,
        //   child: FittedBox(
        //     child: FloatingActionButton.extended(
        //       onPressed: _incrementCounter,
        //       tooltip: 'Hittat',
        //       icon: Icon(Icons.add),
        //       label: Text('Hittat'),
        //     ),
        //   ),
        //),
      ),
    );
  }

  void storeCounter(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', number);
  }

  void _setCounter() {
    final _controller = TextEditingController(
      text: '$_counter',
    );

    final alert = AlertDialog(
      title: Text('Vilket nummer skall hittas?'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onSubmitted: (String text) {
          int number = int.parse(text);
          setState(() {
            _counter = number;
            storeCounter(number);
          });
        },
      ),
      actions: [
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            final number = int.parse(_controller.text);
            setState(() {
              _counter = number;
              storeCounter(number);
            });
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  void _showVersion() async {
    final scaffoldMsngr = ScaffoldMessenger.of(context);
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = packageInfo.buildNumber;
    final buildVersion = packageInfo.version;
    final versionText = packageInfo.appName +
        " Ver: " +
        buildVersion +
        " Build: " +
        buildNumber;
    Navigator.of(context).pop();
    scaffoldMsngr.showSnackBar(
      SnackBar(
        content: Text(versionText),
      ),
    );
  }
}

String getTextForCounter(int counter) {
  var text = counter.toString();
  while (text.length < 3) text = '0' + text;
  return text;
}
