import 'dart:math';
import 'dart:core';
import 'dart:collection';

enum Tt { // token type
  alpha,argument,number,op,function,wrapper
}

class Calculator {
  String calculate(String input) => eval(input);
    
  String eval(String input) {
    var t = <String>[]; // tokens
    var tType = <Tt>[];
    var number = false; // seen a number before?R
    var alpha = false;
    var func = false;
    var op = true;
    var sign = false;
    for(var i = 0; i < input.length; i++) {
      if(isNumber(input[i]) || input[i] == '.') {
        if(number) {
          if(  input[i] != '.' ||
              (input[i] == '.' && !t[t.length-1].contains('.'))
            )
            t[t.length-1] += input[i];
          else
            return 'ERROR: too many decimals for this token';
        } else {
          if(func) {
            if(tType.length != 0 && tType[tType.length-1] == Tt.argument) {
              t[t.length-1] += input[i];
            } else { // function is before
              t.add(input[i]);
              tType.add(Tt.argument);
            }
          } else if(sign && (t.length != 0 && (t[t.length-1] == '+' || t[t.length-1] == '-'))) {
            t[t.length-1] += input[i];
            tType[tType.length-1] = Tt.number;
          } else {
            t.add(input[i]);
            tType.add(Tt.number);
          }
        }
        number = true;
        func = false;
        alpha = false;
        sign = false;
        op = false;
        sign = false;
      } else if(isOp(input[i])) {
        t.add(input[i]);
        if(!func)
          tType.add(Tt.op);
        else if(tType.length != 0 && tType[tType.length-1] == Tt.argument)
          t[t.length-1] += input[i];
        number = false;
        alpha = false;
        func = false;
        if(op) {
          sign = true;
          op = false;
        } else {
          op = true;
          sign = false;
        }
      } else if(isWrapper(input[i])) {
        if(alpha && isOpenWrapper(input[i])) {
          t[t.length-1] += input[i];
          tType.length == 0 ? tType.add(Tt.function) : tType[tType.length-1] = Tt.function;
          func = true;
        } else {
          t.add(input[i]);
          tType.add(Tt.wrapper);
        }
        number = false;
        alpha = false;
        op = false;
        sign = false;
      } else if(isAlpha(input[i])) {
        if(alpha)
          t[t.length-1] += input[i];
        else if(sign && (t.length != 0 && (t[t.length-1] == '+' || t[t.length-1] == '-'))) {
          t[t.length-1] += input[i];
          tType[tType.length-1] = Tt.function;
        } else {
          t.add(input[i]);
          tType.add(Tt.alpha);
        }
        number = false;
        alpha = true;
        func = false;
        op = false;
        sign = false;
      } else if(input[i] == ' ') {
        number = false;
        alpha = false;
        func = false;
        op = true;
        sign = false;
      } else if(input[i] == ',') {
        t.add('');
        tType.add(Tt.argument);
        number = false;
        alpha = false;
        func = true;
        op = false;
        sign = false;
      }
    }
    print(t);
    print(tType);

    return infixToPostfix(t, tType);
  }

  String infixToPostfix(List<String> t, List<Tt> tType) { // TODO: calculate result from tokens -> postfix -> result
    var stack = LinkedList<Token>();
    var output = <String>[];

    print('infix');
    print('    $t');

    for(var i = 0; i < tType.length; i++) {
      if(tType[i] == Tt.number) {
        output.add(t[i]);
      }  else if(tType[i] == Tt.function) {
        // TODO: logic to calculate function immediately
        if((i+2) < tType.length && tType[i+2] == Tt.wrapper) {
          // output.add( func1arg(t[i] , t[i+1]) );
          output.add( func1arg(t[i] , eval(t[i+1])) );
          i = i + 2;
        } else if((i+3) < tType.length && tType[i+3] == Tt.wrapper) {
          // output.add( func2arg(t[i] , t[i+1] , t[i+2]) );
          output.add( func2arg(t[i] , eval(t[i+1]) , eval(t[i+2])) );
          i = i + 3;
        }
      } else if(tType[i] == Tt.wrapper) {
        if(isOpenWrapper(t[i])) {
          stack.add(Token(t[i]));
        } else { // is closed wrapper
          while(!isOpenWrapper(stack.last.toString())) {
            output.add(stack.last.toString()); // get top value
            stack.remove(stack.last); // remove top
            if(stack.isEmpty)
              return 'ERROR: no opening wrapper found';
          }
          stack.remove(stack.last); // discard wrapper from top
        }
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
            } while(!stack.isEmpty || !isOpenWrapper(stack.last.toString()));
            stack.add(Token(t[i]));
          }
        }
      }
    }

    while(!stack.isEmpty) {
      output.add(stack.last.toString()); // get top value
      stack.remove(stack.last); // remove top
    }

    return arithmetic(output);
  }

  String arithmetic(List<String> t) {
    var stack = LinkedList<Token>();
    var top;
    var next;
    print('postfix');
    print('    $t');
    for(var i = 0; i < t.length; i++) {
      if(isNumber(t[i])) {
        stack.add(Token(t[i]));
      } else {
        top = stack.last.toString();
        stack.remove(stack.last);
        next = stack.last.toString();
        stack.remove(stack.last);
        stack.add( Token(getVal(next, t[i], top)) );
      }
    }

    return stack.last.toString();
  }

  bool isNumber(String c) =>
    c.contains('.') ||
    c.contains('0') ||
    c.contains('1') ||
    c.contains('2') ||
    c.contains('3') ||
    c.contains('4') ||
    c.contains('5') ||
    c.contains('6') ||
    c.contains('7') ||
    c.contains('8') ||
    c.contains('9');

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

  bool containsOpenWrapper(String c) =>
    c.contains('(') ||
    c.contains('[') ||
    c.contains('{');


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
    else if(c2 == '+' || c2 == '-')
      b = 0;
    else if(isOpenWrapper(c2))
      b = -1;
    
    if(b == -1)
      print('a: $a , b: $b');

    if(a == b)
      return 0;
    else if(a > b)
      return 1;
    else // (a < b)
      return 2;
  }

  String func1arg(String func, String arg) {
    var answer;
    var sign;
    var val1 = double.parse(arg);
    print('$func -> $val1');

    if(func[0] == '-' || func[0] == '+') {
      sign = '-';
      func = func.substring(1,func.length);
    }
    
    if(func == 'sqrt(')
      answer = sqrt( val1 );

    return sign != null ? '-${answer.toString()}' : answer.toString();
  }

  String func2arg(String func, String arg1, String arg2) {
    var answer;
    var sign;
    var val1 = double.parse(arg1);
    var val2 = double.parse(arg2);
    print('$func -> $val1 , $val2');

    if(func[0] == '-' || func[0] == '+') {
      sign = '-';
      func = func.substring(1,func.length);
    }

    if(func == 'root(') {
      if(val2 == val2.round()) // int root number
        answer = pow( val1, 1.0/val2 ).round();
      else // double root number
        answer = pow( val1, 1.0/val2 );
    } else if(func == 'pow(')
      answer = pow( val1, val2 );

    return sign != null ? '-${answer.toString()}' : answer.toString();
  }

  String getVal(String next, String op, String top) {
    double n = double.parse(next);
    double t = double.parse(top);
    print(next + ' $op ' + top);

    if(op == '*')
      return (n*t).toString();
    else if(op == '/')
      return (n/t).toString();
    else if(op == '+')
      return (n+t).toString();
    else if(op == '-')
      return (n-t).toString();
  }
}

class Token<T> extends LinkedListEntry<Token> {
  var value;
  Token(this.value);
  String toString() => '$value';
}
