part of dart_console.console;

/**
 * Adds linux-like completion to [ConsoleWrapper]
 *
 * Uses [Command] to get completion possibilities and to execute a console line
 */
class InteractiveConsole extends ConsoleWrapper {

  Map<int, List<String>> _currentCompletion;

  _CommandMap _commandsMap;

  Stdio stdio = new Stdio();

  InteractiveConsole() {
    onTab.listen(_waitCompletionDemand);
    onEnter.listen(_executeCommand);
    _commandsMap = new _CommandMap();
  }

  void _waitCompletionDemand(ConsoleLine line){
    bool tabPressed = false;
    var sub = onTab.listen((ConsoleLine line) {
      tabPressed = true;
      _listAutoCompletionPossibilities(line);
    });
    new Timer(new Duration(milliseconds: 100), (){
      sub.cancel();
      if (!tabPressed)
        _autoComplete(line);
    });
  }

  void _autoComplete(ConsoleLine line){
    if (_commandsMap[currentLine.command] == null) return;
    _currentCompletion = _commandsMap[currentLine.command].autoCompleteArg(currentLine.arg);
    if (_currentCompletion.keys.length == 0) return;
    String maxCommuneString = _currentCompletion[_currentCompletion.keys.first][0];
    for (int key in _currentCompletion.keys){
      for (String completion in _currentCompletion[key]){
        if (completion.length < maxCommuneString.length)
          maxCommuneString = maxCommuneString.substring(0, completion.length);
        for (int i = 0; i < maxCommuneString.length; i++){
          if (completion[i] != maxCommuneString[i]){
            maxCommuneString = maxCommuneString.substring(0, i);
            break;
          }
        }
      }
    }
    if (maxCommuneString.length <= line.arg.length) return;
    stdout.write(maxCommuneString.substring(line.arg.length));
    line.arg = maxCommuneString;
  }

  // TODO
  void _listAutoCompletionPossibilities(ConsoleLine line){
    stdout.writeln("Should have autocompletion list here");
  }

  void _executeCommand(ConsoleLine line){
    _CommandWrapper command;
    for (String key in _commandsMap.commands.keys){
      if (key == line.command){
        command = _commandsMap[key];
        break;
      }
    }
    if (command == null) return;
    command.executeCommand(line.arg, stdio);
  }

  /**
   * Register a [Command] to be executable
   */
  void registerCommand(Command command){
    _commandsMap.commands[command.command] = new _CommandWrapper(command);
  }

}

class _CommandMap {

  static _CommandMap _singleton;

  Map<String, _CommandWrapper> commands = new Map();

  _CommandMap._internal(){}

  factory _CommandMap(){
    if (_singleton == null) {
      _singleton = new _CommandMap._internal();
    }
    return _singleton;
  }

  _CommandWrapper operator [](String key) => commands[key];

  String toString(){
    return commands.toString();
  }

}

class _CommandWrapper {

  Command delegate;

  _CommandWrapper(this.delegate);

  Map<int, List<String>> autoCompleteArg([String arg = ""]){
    Map<int, List<String>> possibleCompletion = new Map();
    this.listPossibleArgs().forEach((String possibleArg){
      if (arg.length == 0){
        if (possibleCompletion[0] == null)
          possibleCompletion[0] = new List();
        possibleCompletion[0].add(possibleArg);
      } else if (arg.length > possibleArg.length) {
        return;
      } else {
        int score = calculateLikenessScore(arg, possibleArg);
        if (score >= 0) {
          if (possibleCompletion[score] == null)
            possibleCompletion[score] = new List();
          possibleCompletion[score].add(possibleArg);
        }
      }
    });
    return possibleCompletion;
  }

  List<String> listPossibleArgs() => delegate.listPossibleArgs();

  void executeCommand(String arg, Stdio io) => delegate.executeCommand(arg, io);

  static int calculateLikenessScore(String arg, String comparison){
    if (arg.length == 0) return 0;
    for (int i = 0; i < arg.length && i < comparison.length; i++){
      if (arg[i] != comparison[i]) {
        return -1;
      }
    }
    return 0;
  }

}