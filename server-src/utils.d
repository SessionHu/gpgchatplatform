import std.conv : to;
import std.process : environment;
import std.regex : matchFirst, regex;

import core.sys.posix.unistd : write, STDOUT_FILENO;
import core.sys.posix.time : gmtime_r, time_t, time, tm, strftime;

@safe
string dateHeaderFieldNowWithCRLF() {
  char[96] buffer;
  size_t l;
  () @trusted @nogc {
    time_t epochSeconds = 0;
    time(&epochSeconds);
    tm timeStruct = {};
    gmtime_r(&epochSeconds, &timeStruct);
    l = strftime(buffer.ptr, buffer.length, "Date: %a, %d %b %Y %H:%M:%S GMT\r\n", &timeStruct);
  }();
  return to!string(buffer[0..l]);
}

int writeResp(string coderes, string headers, string payload, string allowheaders = "X-SGCC-To", int ret = 0) {
  const cl = payload.length * payload[0].sizeof;
  const h = environment.get("SERVER_PROTOCOL") ~ ' ' ~ coderes ~ "\r\n" ~
    "Access-Control-Allow-Origin: *\r\n" ~
    "Access-Control-Allow-Methods: GET, OPTIONS\r\n" ~
    "Access-Control-Allow-Headers: " ~ allowheaders ~ "\r\n" ~
    "Access-Control-Max-Age: 86400\r\n" ~
    "Cache-Control: max-age=0\r\n" ~
    "Allow: OPTIONS, GET\r\n" ~
    "Server: " ~ environment.get("SERVER_SOFTWARE") ~ ' ' ~ environment.get("GATEWAY_INTERFACE") ~ " (sgcc)\r\n" ~
    dateHeaderFieldNowWithCRLF() ~
    (headers.matchFirst(regex("content-type", "i")) ? "" : "Content-Type: text/plain\r\n") ~
    (headers.length != 0 ? (headers ~ "\r\n") : "") ~
    "Content-Length: " ~ cl.to!string ~ "\r\n\r\n";
  write(STDOUT_FILENO, h.ptr, h.length * h[0].sizeof);
  write(STDOUT_FILENO, payload.ptr, cl);
  return ret;
}
