part of dart_console.command;

/**
 * Helper to write to console
 */
class Stdio {

  /**
   * Prints [string] as it is
   */
  void writeString(String string) {
    stdout.write(string);
  }

  /**
   * Prints [line], with line-end inserted AFTER
   */
  void writeLine(String line) {
    stdout.writeln(line);
  }

  /**
   * Prints [line], with line-end inserted BEFORE and AFTER
   */
  void writeNewLine(String line) {
    stdout.writeln("");
    stdout.writeln(line);
  }

  /**
   * Remove [nb] chars from console
   */
  void removeChars(int nb){
    for (int i = 0; i < nb; i++){
      stdout.write(LATIN1.decode([8]));
      stdout.write(" ");
      stdout.write(LATIN1.decode([8]));
    }
  }

  /**
   * Wait for input from user
   */
  String readLine() {
    return stdin.readLineSync();
  }

  void clear() {
    for (int i = 0; i < stdout.terminalLines; i++){
      stdout.writeln("");
    }
  }


}

