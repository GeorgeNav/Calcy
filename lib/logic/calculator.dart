import 'dart:math';
import 'dart:core';
import 'dart:collection';

class Calculator {
  String calculate(String input) {
    var stack = LinkedList<Token>();

    print('Converting input');
    return eval(input);
  }
  String eval(String input) {
    var op = true;
    var neg = false;
    var str = '';
    List<dynamic> t = []; // can take in any value type

    if(input == '')
      return '';

    print('> eval start');
    for(var i = 0; i < input.length; i++, print('Infix List: $t')) {
      if(isNumber(input[i])) { // check if character is a number
        var j = i;
        do { // convert numbers to a single double token
          str += input[j];
          j++;
        } while(j < input.length && isNumber(input[j]));        
        i = j - 1;
        var number = double.parse(str); str = '';
        neg ? t.add(-number) : t.add(number);
        op = false;
        neg = false;
      } else if(isOp(input[i])) {
        if(!op) { // check if previous character is an operator
          t.add(input[i]); // add to tokens
          op = true; // now the previous token is an operator
          neg = false;
        } else if(input[i] == '-' || input[i] == '+') {
          op = false;
          if(input[i] == '-')
            neg = true; // now the previous token is a negative neg
          else
            neg = false;
        } else
          return 'ERROR: too many operators';
      } else if(isWrapper(input[i])) {
        print(neg);
        if(isOpenWrapper(input[i]) && !neg) {
          if(t.length != 0 && !(t.last is double) && onlyAlpha(t.last) && valForWord(t.last).toString() == 'NaN') { // this is the start of a function's arg(s)
            t.last += input[i];
            var iComma = -1;
            var iWrapper = -1;
            var j = i+1;
            do { // find closing function wrapper (add comma if there exists one)
              if(input[j] == ',')
                iComma = j;
              if(isOpenWrapper(input[j]))
                iWrapper--;
              else if(isCloseWrapper(input[j]))
                iWrapper++;
              if(iWrapper == 0) {
                iWrapper = j; // now iWrapper is an function's close wrapper index rather than counting wrapper pairs
                break;
              }
              j++;
            } while(j < input.length);
            String funcAnswer = 'NaN';
            // calculate what's inside the function's arguments
            if(iComma != -1 && i != input.length-1) { // 2 arg function
              print('...func2');
              funcAnswer = func2arg(
                t.last,
                calculate(input.substring(i+1,iComma)),
                iWrapper != -1 ?
                  calculate(input.substring(iComma+1,iWrapper)) :
                  calculate(input.substring(iComma+1,input.length)) // forgiving that there is not a closing wrapper for function
              );
              iWrapper != -1 ? i = iWrapper : i = input.length;
              print('    funcAnswer: $funcAnswer');
              neg ?
                t.last = -double.parse(funcAnswer) :
                t.last = double.parse(funcAnswer);
            } else if(i != input.length-1) { // 1 arg function
              print('...func1');
              funcAnswer = func1arg(
                t.last,
                iWrapper != -1 ?
                  calculate(input.substring(i+1,iWrapper)) :
                  calculate(input.substring(i+1,input.length)) // forgiving that there is not a closing wrapper for function
              );
              iWrapper != -1 ? i = iWrapper : i = input.length;
              print('    funcAnswer: $funcAnswer');
              neg ?
                t.last = -double.parse(funcAnswer) :
                t.last = double.parse(funcAnswer); 
            } else { // Not a valid argument entry
              return 'ERROR: no closing wrapper for function';
            }
            op = false;
            neg = false;
          } else if(t.length != 0 && (t.last is double || t.last is String && onlyAlpha(t.last))) { // forgive no multiplication sign
            t.add('*');
            t.add(input[i]);
            print('lazy! i\'ll add a * for ya');
            op = true;
            neg = false;
          } else {
            t.add(input[i]);
            op = true;
            neg = false;
          }
        } else if(isOpenWrapper(input[i]) && neg) {
          print('-ANSWER');
          var iWrapper = -1;
          var j = i+1;
          do { // find closing function wrapper (add comma if there exists one)
            if(isOpenWrapper(input[j]))
              iWrapper--;
            else if(isCloseWrapper(input[j]))
              iWrapper++;
            if(iWrapper == 0) {
              iWrapper = j; // now iWrapper is an function's close wrapper index rather than counting wrapper pairs
              break;
            }
            j++;
          } while(j < input.length);
          String answer;
          if(iWrapper+1 <= input.length)
            answer = '-${calculate(input.substring(i, iWrapper+1))}';
          else
            answer = 'NaN';
          t.add(double.parse(answer));
          i = iWrapper;
          if(i+1 < input.length && (isNumber(input[i+1]) || onlyAlpha(input[i+1]))) {
            t.add('*');
            op = true;
            neg = false;
          } else {
            op = false;
            neg = false;
          }
        } else { // closed wrapper
          t.add(input[i]);
          if(i+1 < input.length && (isNumber(input[i+1]) || onlyAlpha(input[i+1]))) {
            t.add('*');
            op = true;
          } else {
            op = false;
            neg = false;
          }
        }
      } else if(onlyAlpha(input[i])) {
         if(t.length == 0 || op || t.length != 0 && isOpenWrapper(t.last)) { // might be a predetermined word value or function character
          if(neg) t.add('-${input[i]}');
          else t.add(input[i]);
        } else if(t.length != 0 && t.last is String)
          t.last += input[i];
        op = false; neg = false;
      } else if(input[i] == ' ') {
        // TODO: do nothing?
      } else {
        t.last = getUnitVal(input[i], t.last);
        op = false;
        neg = false;
      }
    }
    print('> Infix Tokens: $t');
    return t.length == 1 ? t[0].toString() : arithmetic(t);
  }

  String arithmetic(List<dynamic> t) {
    List<dynamic> postfix = infixToPostfix(t);
    var stack = LinkedList<Token>();
    var top;
    var next;
    print('postfix: $postfix');
    for(var i = 0; i < postfix.length; i++) {
      if(postfix[i] is double) { // double value
        stack.add(Token(postfix[i]));
      } else { // operator
        top = stack.last.toString();
        stack.remove(stack.last);
        next = stack.last.toString();
        stack.remove(stack.last);
        stack.add( Token(getVal(next, postfix[i], top)) );
      }
    }

    return stack.last.toString();
  }

  List<dynamic> infixToPostfix(List<dynamic> t) { // TODO: infix to postfix
    var stack = LinkedList<Token>();
    var output = [];

    print(t);    
    for(var i = 0; i < t.length; i++, print(' stack: $stack'),print('  output: $output')) {
      print('    ${t[i]}');
      if(t[i] is double) { // double value
        output.add(t[i]);
      } else if(t[i] is String && onlyAlpha(t[i])) { // predetermined word value
        output.add(valForWord(t[i]));
      } else if(isWrapper(t[i])) { // wrapper
        if(isOpenWrapper(t[i])) {
          stack.add(Token(t[i]));
        } else { // is closed wrapper
          while(!isOpenWrapper(stack.last.toString())) {
            output.add(stack.last.toString()); // get top value
            stack.remove(stack.last); // remove top
            if(stack.isEmpty)
              return ['ERROR: no opening wrapper found'];
          }
          stack.remove(stack.last); // discard wrapper from top
        }
      } else if(isOp(t[i])) { // *,/,+,-
        if(stack.isEmpty || isOpenWrapper(stack.last.toString())) {
          stack.add(Token(t[i]));
        } else {
          print('    do');
          var p = precedence(t[i], !stack.isEmpty ? stack.last.toString() : '');
          if(p == 0 || p == 2) { // t[i] precedence = top of stack (no matter how much the stack is popped, it'll never be higher then the current)
            do {
              output.add(stack.last.toString()); // get top value
              stack.remove(stack.last); // remove top
              p = precedence(t[i], !stack.isEmpty ? stack.last.toString() : '');
            } while(p != 1);
            stack.add(Token(t[i]));
          }
          else if(p == 1) // t[i] precedence > top of stack
            stack.add(Token(t[i]));
        }
      }  
    }

    while(!stack.isEmpty) {
      // popping top value
      output.add(stack.last.toString()); // get top value
      stack.remove(stack.last); // remove top
    }

    return output;
  }

  bool isNumber(c) =>
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

  bool isOp(c) =>
    c == '+' ||
    c == '-' ||
    c == '/' ||
    c == '*' ||
    c == '^';

  bool isWrapper(c) =>
    c == ')' ||
    c == '(' ||
    c == '[' ||
    c == ']' ||
    c == '{' ||
    c == '}';

  bool isOpenWrapper(c) =>
    c == '(' ||
    c == '[' ||
    c == '{';

  bool containsOpenWrapper(c) =>
    c.contains('(') ||
    c.contains('[') ||
    c.contains('{');


  bool isCloseWrapper(c) =>
    c == ')' ||
    c == ']' ||
    c == '}';

  bool onlyAlpha(c) =>
      RegExp(r'^[a-zA-Z]+$').hasMatch(c);

  int precedence(c1, c2) {
    var a;
    var b;

    if(c2 == '') // top of stack is a open wrapper
      return 1;

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
    var neg;

    print('$func -> $arg');
    if(isOpenWrapper(func[func.length-1]) && arg != '') {
      var val1 = double.parse(arg);

      if(func[0] == '-') {
        neg = '-';
        func = func.substring(1,func.length);
      }
      
      if(func == 'sqrt(')
        answer = sqrt( val1 );

      return answer == null ? 'NaN' :
        neg != null ? '-${answer.toString()}' : answer.toString();
    }
    return 'NaN'; // Cannot calculate
  }

  String func2arg(String func, String arg1, String arg2) {
    var answer;
    var neg;
    var val1;
    var val2;

    print('$func -> $arg1 , $arg2');
    if(isOpenWrapper(func[func.length-1]) && arg1 != '' && arg2 != '') {
      val1 = double.parse(arg1);
      val2 = double.parse(arg2);

      if(func[0] == '-') {
        neg = '-';
        func = func.substring(1,func.length);
      }

      if(func == 'root(') {
        answer = pow( val1, 1.0/val2 );
      } else if(func == 'pow(')
        answer = pow( val1, val2 );
      
      return answer == null ? 'NaN' :
        neg != null ? '-${answer.toString()}' : answer.toString();
    }
    return 'NaN'; // Cannot calculate
  }

  String getVal(next, op, top) {
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
    return 'ERROR: invalid operator';
  }

  double valForWord(word) {
    var val;
    if(word is double)
      return double.parse('NaN');

    // TODO: think of words that have values to put here
    if(word == 'pi' || word == 'pie')
      val = 3.1415926535897932;

    return val != null ? val : double.parse('NaN');
  }

  double getUnitVal(String unit, double value) {
    print('GET UNIT VAL: $unit , $value');
    if(unit == '%')
      return value/100.0;
    
    return double.parse('NaN');
  }
}

class Token<T> extends LinkedListEntry<Token> {
  var value;
  Token(this.value);
  String toString() => '$value';
}