
import 'package:dart_console/dart_console.dart';



main() {

  InteractiveConsole console = new InteractiveConsole();
  console.registerCommand(new HelloWorld());

  console.readLine();

}


class HelloWorld extends Command {

  HelloWorld() : super("hello");

  void executeCommand(String arg, Stdio io) => io.writeLine("Hello $arg!");

  List<String> listPossibleArgs() => ["world"];
}