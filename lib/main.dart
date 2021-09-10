import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Platespotter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  //Loading counter value on start
  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0);
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
      prefs.setInt('counter', _counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _setCounter();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nummer att leta efter:',
            ),
            GestureDetector(
              onLongPress: _setCounter,
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 200,
        child: FittedBox(
            child: FloatingActionButton.extended(
              onPressed: _incrementCounter,
              tooltip: 'Hittat',
              icon: Icon(Icons.add),
              label: Text('Hittat'),

            ),
          ),
        ),
    );
  }

  void storeCounter(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', number);
  }

  void _setCounter( ) {
    final _controller = TextEditingController(
      text: '$_counter',
    );

    final alert = AlertDialog(
      title: Text('Vilket nummer skall hittas?'),
      content: TextField(
        controller: _controller,
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
            final number = int.parse( _controller.text);
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
}
