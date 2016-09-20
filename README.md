# dart console

Commands oriented dart emulation of bash terminal

Try to emulate terminal behavior inside a dart program, through definition of commands with the listing of their parameter possibilities.

Usage :

```dart
import 'package:dart_console/dart_console.dart';

main() {
  // Console who works best with Commands, as it use Command definition to auto complete argument
  InteractiveConsole console = new InteractiveConsole();
  console.registerCommand(new HelloWorld());
  // Blocking call, wait user input through stdin
  console.readLine();
}


class HelloWorld extends Command {
  // define its command name, like as 'ls'
  HelloWorld() : super("hello");
  void executeCommand(String arg, Stdio io) => io.writeLine("Hello $arg!");
  // return the list of all arguments accepted by this command
  List<String> listPossibleArgs() => ["world"];
}
```
