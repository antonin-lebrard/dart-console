library dart_console.command;

import 'dart:io';
import 'dart:convert';

part "stdio.dart";

/**
 * Represents a command to be executed
 */
abstract class Command {

  String command;

  Command(this.command);

  Command.empty();

  /**
   * Returns all possible args for this command
   */
  List<String> listPossibleArgs();

  /**
   * Execute command with [arg] and possibly print results with [io]
   */
  void executeCommand(String arg, Stdio io);

}