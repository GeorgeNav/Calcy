import 'dart:math';
import 'dart:core';
import 'package:calcy/logic/stack.dart';
import 'dart:collection';

class Calculator {
  String calculate(String input) => arithmetic(tokenize(input));
    
  List<String> tokenize(String input) {
    var t = <String>['']; // tokens
    var digit = true; // seen a digit before?
    var alpha = true;

    for(var i = 0; i < input.length; i++) {
      if(isDigit(input[i]) || input[i] == '.' || input[i] == '^') {
        if(digit) {
          if(input[i] != '.' || (input[i] == '.' && !t[t.length-1].contains('.')) )
            t[t.length-1] += input[i];
          else {
            print('ERROR: too many decimals for this token');
            return['ERROR: too many decimals for this token'];
          }
        } else t.add(input[i]);
        digit = true;
        alpha = false;
      } else if(isOp(input[i])) {
        digit = false;
        alpha = false;
        t.add(input[i]);
      } else if(isWrapper(input[i])) {
        digit = false;
        alpha = false;
        t.add(input[i]);
      } else { // TODO: is digit?
        if(alpha) t[t.length-1] += input[i];
        else if(input[i] != ' ') t.add(input[i]);
        digit = false;
        alpha = true;
      }
    }
    return t;
  }

  String arithmetic(List<String> t) { // TODO: calculate result from t
    var l = LinkedList<Token>();
    l.addFirst(t[i]);

    return t.toString();
  }

  bool isDigit(String c) =>
    c == "0" ||
    c == "1" ||
    c == "2" ||
    c == "3" ||
    c == "4" ||
    c == "5" ||
    c == "6" ||
    c == "7" ||
    c == "8" ||
    c == "9";

  bool isOp(String c) =>
    c == '+' ||
    c == '-' ||
    c == '/' ||
    c == '*';

  bool isWrapper(String c) =>
    c == ')' ||
    c == '(' ||
    c == '[' ||
    c == ']' ||
    c == '{' ||
    c == '}';
}

class Token<String> extends LinkedListEntry<Token> {
  var token;
  Token(this.token);
}