import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcy/logic/calculator.dart';

String appName = 'Calcy';
var output = TextEditingController();
var input = TextEditingController();

class Calcy extends StatelessWidget {
  Widget build(BuildContext context) => Scaffold(
/*       bottomSheet: Container(
        color: Color.fromARGB(255, 37, 38, 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row( children: <Widget>[buildButton('7'), buildButton('8'), buildButton('9'), buildButton('/'),] ),
            Row( children: <Widget>[buildButton('4'), buildButton('5'), buildButton('6'), buildButton('*'),] ),
            Row( children: <Widget>[buildButton('1'), buildButton('2'), buildButton('3'), buildButton('-'),] ),
            Row( children: <Widget>[buildButton('.'), buildButton('0'), buildButton('00'), buildButton('+'),] ),
            Row( children: <Widget>[buildButton('CLEAR'), buildButton('='),] ),
          ],
        ),
      ), */
      backgroundColor: Color.fromARGB(255, 33, 34, 38),
      appBar: AppBar(
        actions: [
        ],
        backgroundColor: Color.fromARGB(255, 33, 34, 38),
        title: Text(
          appName,
          style: TextStyle(color: Color.fromARGB(255, 94, 94, 97))
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Input(),
              Output(),
              MaterialButton(
                color: Colors.blue,
                minWidth: 50,
                child: Text(
                  'Copy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: output.text));
                },
              ),
            ],
        ),
      )
  );

  Widget buildButton(String buttonText) {
    return new Expanded(
      child: new OutlineButton(
        padding: new EdgeInsets.all(24.0),
        child: new Text(
          buttonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
          ),
        onPressed: () { // TODO: when button is pressed do something
          if(buttonText != '=')
            input.text += '$buttonText';
          },
        ),
      );
  }
}

class Input extends StatefulWidget {
  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  var calcy = Calculator();
  Widget build(BuildContext context) => 
  Container(
    color: Color.fromARGB(255, 33, 34, 38),
    width: MediaQuery.of(context).size.width * 0.50,
    child: TextField(
      controller: input,
      decoration: InputDecoration(
        hintText: 'Type in here!',
      ),
      style: TextStyle(color: Colors.white),
      onTap: () {
        showBottomSheet();
      },
      onChanged: (input) => setState(() { // TODO: parse and calculate for output
        output.text = '';
        output.text = calcy.calculate(input);
      }),
    )
  );
}

class Output extends StatefulWidget {
  @override
  _OutputState createState() => _OutputState();
}

class _OutputState extends State<Output> {
  Widget build(BuildContext context) => Container(
    color: Color.fromARGB(255, 33, 34, 38),
    width: 100,
    child: TextField(
      focusNode: FocusNode(),
      controller: output,
      enabled: true,
      style: TextStyle(color: Colors.lightGreen),
      onTap: () {
        print('Copying to clipboard');
        Clipboard.setData(ClipboardData(text: output.text));
      },
      /* textDirection: TextDirection.rtl, */
    )
  );
}
