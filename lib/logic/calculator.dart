import 'dart:math';
import 'dart:core';
import 'dart:collection';

enum Tt { // token type
  number,op,wrapper,alpha,function
}

class Calculator {
  String calculate(String input) => eval(input);
    
  String eval(String input) {
    var t = <String>[]; // tokens
    var tType = <Tt>[];
    var number = false; // seen a number before?
    var alpha = false;

    for(var i = 0; i < input.length; i++) {
      if(isnumber(input[i]) || input[i] == '.') {
        if(number) {
          if(  input[i] != '.' ||
              (input[i] == '.' && !t[t.length-1].contains('.'))
            )
            t[t.length-1] += input[i];
          else
            return 'ERROR: too many decimals for this token';
        } else {
          t.add(input[i]);
          tType.add(Tt.number);
        }
        number = true;
        alpha = false;
      } else if(isOp(input[i])) {
        t.add(input[i]);
        tType.add(Tt.op);
        number = false;
        alpha = false;
      } else if(isWrapper(input[i])) {
        if(alpha && isOpenWrapper(input[i])) {
          t[t.length-1] += input[i];
          tType.length == 0 ? tType.add(Tt.function) : tType[tType.length-1] = Tt.function;
        } else {
          t.add(input[i]);
          tType.add(Tt.wrapper);
        }
        number = false;
        alpha = false;
      } else if(isAlpha(input[i])) {
        if(alpha)
          t[t.length-1] += input[i];
        else {
          t.add(input[i]);
          tType.add(Tt.alpha);
        }
        number = false;
        alpha = true;
      } else if(input[i] == ' ' && alpha) {
        t[t.length-1] += ' ';
      }
    }
    print(t);
    print(tType);

    return infixToPostfix(t, tType);
  }

  String infixToPostfix(List<String> t, List<Tt> tType) { // TODO: calculate result from tokens -> postfix -> result
    var stack = LinkedList<Token>();
    var output = <String>[];

    for(var i = 0; i < tType.length; i++, print(stack)) {
      if(tType[i] == Tt.number) {
        output.add(t[i]);
      } else if(tType[i] == Tt.wrapper) {
        if(isOpenWrapper(t[i])) {
          stack.add(Token(t[i]));
        } else { // is closed wrapper
          do {
            output.add(stack.last.toString()); // get top value
            stack.remove(stack.last); // remove top
            if(stack.isEmpty)
              return 'ERROR: no closing wrapper';
          } while (!isCloseWrapper(stack.last.toString()));
          stack.remove(stack.last); // discard wrapper from top
        }
      } else if(tType[i] == Tt.function) {
        // TODO: logic to calculate function immediately

      } else if(tType[i] == Tt.op) {
        if(stack.isEmpty || isWrapper(stack.last.toString())) {
          stack.add(Token(t[i]));
        } else {
          var p = precedence(t[i],stack.last.toString());
          if(p == 0) {
            do {
              output.add(stack.last.toString()); // get top value
              stack.remove(stack.last); // remove top
              if(!stack.isEmpty)
                p = precedence(t[i],stack.last.toString()); 
            } while(p == 0 && !stack.isEmpty);
            stack.add(Token(t[i]));
          }
          else if(p == 1)
            stack.add(Token(t[i]));
          else if(p == 2) {
            do {
              output.add(stack.last.toString()); // get top value
              stack.remove(stack.last); // remove top
            } while(!stack.isEmpty);
            stack.add(Token(t[i]));
          }
        }
      }
    }
    // stack.add(Token(t[i]));
    while(!stack.isEmpty) {
      output.add(stack.last.toString()); // get top value
      stack.remove(stack.last); // remove top
    }

    return output.toString();
  }

  bool isnumber(String c) =>
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

  int precedence(String c1, String c2) {
    var a, b;

    if(c1 == '^')
      a = 2;
    else if(c1 == '*' || c1 == '/')
      a = 1;
    else // (c1 == '+' || c1 == '-')
      a = 0;

    if(c2 == '^')
      b = 2;
    else if(c2 == '*' || c2 == '/')
      b = 1;
    else // (c2 == '+' || c2 == '-')
      b = 0;

    if(a == b) {
      print('$c1 is    =    to $c2');
      return 0;
    } else if(a > b) {
      print('$c1 is    >    to $c2');
      return 1;
    } else { // (a < b)
      print('$c1 is    <    to $c2');
      return 2;
    }
  }
}

class Token<T> extends LinkedListEntry<Token> {
  var value;
  Token(this.value);
  String toString() => '$value';
}
