import { IConnection } from "vscode-languageserver";

/**
 * for errors (and other logs in debug mode) we want to print
 * a stack trace showing where they were thrown. This uses an
 * Error's stack trace, removes the three frames regarding
 * this file (since they're useless) and returns the rest of the trace.
 */
const createAndTrimStackTrace = () => {
  let stack: string | undefined = new Error().stack;
  // remove the lines in the stack from _this_ function and the caller (in this file) and shorten the trace
  return stack && stack.split("\n").length > 2
    ? stack
        .split("\n")
        .slice(3, 7)
        .join("\n")
    : stack;
};

type Logger = (message?: any) => void;

export class Debug {
  private static connection?: IConnection;
  private static infoLogger: Logger = message =>
    console.log("[INFO] " + message);
  private static warningLogger: Logger = message =>
    console.warn("[WARNING] " + message);
  private static errorLogger: Logger = message =>
    console.error("[ERROR] " + message);

  /**
   * Setting a connection overrides the default info/warning/error
   * loggers to pass a notification to the connection
   */
  public static SetConnection(conn: IConnection) {
    Debug.connection = conn;
    Debug.infoLogger = message =>
      Debug.connection!.sendNotification("serverDebugMessage", {
        type: "info",
        message: message
      });
    Debug.warningLogger = message =>
      Debug.connection!.sendNotification("serverDebugMessage", {
        type: "warning",
        message: message
      });
    Debug.errorLogger = message =>
      Debug.connection!.sendNotification("serverDebugMessage", {
        type: "error",
        message: message
      });
  }

  /**
   * Allow callers to set their own error logging utils.
   * These will default to console.log/warn/error
   */
  public static SetLoggers({
    info,
    warning,
    error
  }: {
    info?: Logger;
    warning?: Logger;
    error?: Logger;
  }) {
    if (info) Debug.infoLogger = info;
    if (warning) Debug.warningLogger = warning;
    if (error) Debug.errorLogger = error;
  }

  public static info(message: string) {
    Debug.infoLogger(message);
  }

  public static error(message: string) {
    const stack = createAndTrimStackTrace();
    Debug.errorLogger(`${message}\n${stack}`);
  }

  public static warning(message: string) {
    Debug.warningLogger(message);
  }

  public static sendErrorTelemetry(message: string) {
    Debug.connection &&
      Debug.connection.sendNotification("serverDebugMessage", {
        type: "errorTelemetry",
        message: message
      });
  }
}
