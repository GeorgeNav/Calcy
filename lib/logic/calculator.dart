import 'dart:math';
import 'dart:core';
import 'dart:collection';

enum Tt { // token type
  digit,op,wrapper,alpha,function
}

class Calculator {
  String calculate(String input) => eval(input);
    
  String eval(String input) {
    var t = <String>['']; // tokens
    var tType = <Tt>[];
    var digit = true; // seen a digit before?
    var alpha = true;

    for(var i = 0; i < input.length; i++) {
      if(isDigit(input[i]) || input[i] == '.') {
        if(digit) {
          if(  input[i] != '.' ||
              (input[i] == '.' && !t[t.length-1].contains('.'))
            )
            t[t.length-1] += input[i];
          else
            return 'ERROR: too many decimals for this token';
        } else {
          t.add(input[i]);
          tType.add(Tt.digit);
        }
        digit = true;
        alpha = false;
      } else if(isOp(input[i])) {
        t.add(input[i]);
        tType.add(Tt.op);
        digit = false;
        alpha = false;
      } else if(isWrapper(input[i])) {
        if(alpha && isOpenWrapper(input[i])) {
          t[t.length-1] += input[i];
          tType.length == 0 ? tType.add(Tt.function) : tType[tType.length-1] = Tt.function;
        } else {
          t.add(input[i]);
          tType.add(Tt.wrapper);
        }
        digit = false;
        alpha = false;
      } else if(isAlpha(input[i])) {
        if(alpha)
          t[t.length-1] += input[i];
        else {
          t.add(input[i]);
          tType.add(Tt.alpha);
        }
        digit = false;
        alpha = true;
      } else if(input[i] == ' ' && alpha) {
        t[t.length-1] += ' ';
      }
    }

    return arithmetic(t, tType);
  }

  String arithmetic(List<String> t, List<Tt> tType) { // TODO: calculate result from tokens -> postfix -> result
    var stack = LinkedList<Token>();
    var output = LinkedList<Token>();
/*
    for(var i = 0; i < t.length; i++, print(stack)) {
      if(tType[i] == Tt.wrapper) {
        if(isOpenWrapper(t[i])) {
          stack.add(Token(t[i]));
        } else {
          do {
            output.add(stack.last);
            stack.remove(stack.last);
            if(stack.isEmpty) return 'ERROR: unequal amount of wrappers';
          } while (!isCloseWrapper(stack.last.toString()));
        }
      }
    }
    // stack.add(Token(t[i]));
*/
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
    c == '*' ||
    c == '^';

  bool isWrapper(String c) =>
    c == ')' ||
    c == '(' ||
    c == '[' ||
    c == ']' ||
    c == '{' ||
    c == '}';

  bool isOpenWrapper(String c) =>
    c == '(' ||
    c == '[' ||
    c == '{';

  bool isCloseWrapper(String c) =>
    c == ')' ||
    c == ']' ||
    c == '}';
  bool isAlpha(String c) =>
    c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f' || c == 'g' || c == 'h' || c == 'i' || c == 'j' || c == 'k' || c == 'l' || c == 'm' || c == 'n' || c == 'o' || c == 'p' || c == 'q' || c == 'r' || c == 's' || c == 't' || c == 'u' || c == 'v' || c == 'w' || c == 'x' || c == 'y' || c == 'z' ||
    c == 'A' || c == 'B' || c == 'C' || c == 'D' || c == 'E' || c == 'F' || c == 'G' || c == 'H' || c == 'I' || c == 'J' || c == 'K' || c == 'L' || c == 'M' || c == 'N' || c == 'O' || c == 'P' || c == 'Q' || c == 'R' || c == 'S' || c == 'T' || c == 'U' || c == 'V' || c == 'W' || c == 'X' || c == 'Y' || c == 'Z';
}

class Token<T> extends LinkedListEntry<Token> {
  var value;
  Token(this.value);
  String toString() => '$value';
}
