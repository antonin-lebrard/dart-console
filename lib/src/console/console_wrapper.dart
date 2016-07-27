part of dart_console.console;


/**
 * Direct console wrapper, dartifying the special keys events with [Stream]
 *
 * Replace the normal behavior of the console
 */
class ConsoleWrapper {

  StreamSubscription _subscription;

  ConsoleLine currentLine = new ConsoleLine();

  Stream<ConsoleLine> onEnter;
  StreamController _onEnter;
  Stream<ConsoleLine> onTab;
  StreamController _onTab;
  Stream<ConsoleLine> onSpace;
  StreamController _onSpace;
  Stream<ConsoleLine> onReturn;
  StreamController _onReturn;
  Stream<ConsoleLine> onChar;
  StreamController _onChar;

  Stream<ConsoleLine> onLine;

  ConsoleWrapper() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    _onEnter = new StreamController.broadcast();
    onEnter = _onEnter.stream;
    onLine = _onEnter.stream;
    _onTab = new StreamController.broadcast();
    onTab = _onTab.stream;
    _onSpace = new StreamController.broadcast();
    onSpace = _onSpace.stream;
    _onReturn = new StreamController.broadcast();
    onReturn = _onReturn.stream;
    _onChar = new StreamController.broadcast();
    onChar = _onChar.stream;
  }

  /**
   * Waits for a line to be typed and returns it
   *
   * Waits until Enter is pressed
   * For more complex handling use [beginInput]
   */
  Future<ConsoleLine> readLine() {
    Completer<ConsoleLine> completer = new Completer();
    if (_subscription == null)
      beginInput();
    onEnter.first.then((ConsoleLine line){
      stopInput();
      completer.complete(line);
    });
    return completer.future;
  }

  /**
   * Begins to listen for input
   *
   * Should be used with [onEnter], [onTab], [onSpace], [onReturn], and/or [onChar]
   */
  void beginInput(){
    _subscription = stdin.listen((List<int> codeUnits){
      if (codeUnits.contains(9)) {       /// TAB
        _onTab.add(currentLine);
      }
      else if (codeUnits.contains(13)) { /// Enter
        _subscription.cancel();
        _onEnter.add(currentLine);
        currentLine = new ConsoleLine();
        stdout.writeln();
      }
      else if (codeUnits.contains(32)) { /// Space
        if (!currentLine.commandComplete)
          currentLine.commandComplete = true;
        _onSpace.add(currentLine);
        stdout.write(' ');
      }
      else if (codeUnits.contains(8)) {  /// Return
        if (currentLine.commandComplete && currentLine.arg.length == 0)
          currentLine.commandComplete = false;
        else
          currentLine.deleteChar();
        stdout.write(LATIN1.decode(codeUnits));
        stdout.write(' ');
        stdout.write(LATIN1.decode(codeUnits));
        _onReturn.add(currentLine);
      }
      else {
        try {
          String char = LATIN1.decode(codeUnits);
          currentLine.addChar(char);
          stdout.write(char);
          _onChar.add(currentLine);
        } catch (e) {}
      }
    });
  }

  /**
   * Stop listening for input
   *
   * Complementary function to [beginInput]
   */
  void stopInput() {
    if (_subscription != null) {
      _subscription.cancel()?.then((_){
        _subscription = null;
      });
    }
  }

}

/**
 * Represent a line in the console
 *
 * does not support multiple arguments
 */
class ConsoleLine {

  String command = "";
  String arg = "";

  bool commandComplete = false;

  String toString(){
    if (arg.length > 0)
      return command + " " + arg;
    return command;
  }

  void deleteChar(){
    if (arg.length > 0)
      arg = arg.substring(0, arg.length - 1);
    else if (command.length > 0) {
      command = command.substring(0, command.length - 1);
      commandComplete = false;
    }
  }

  void addChar(String char){
    if (!commandComplete) command += char;
    else arg += char;
  }

}