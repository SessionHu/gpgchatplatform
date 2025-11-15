import std.stdio;
import std.process;
import std.file;
import std.path;
import std.regex;
import std.array;
import std.algorithm;
import std.base64;
import std.bigint;
import std.conv;
import std.typecons;

import utils;

extern(C) int wait_for_new_file(const char* dir_path, int timeout_ms);

@safe
BigInt getOffsetFromEnv() {
  const envvar = environment.get("QUERY_STRING");
  if (!envvar || envvar.length == 0) return BigInt(0);
  auto m = match(envvar, `^(?:.+&)?offset=(\d+)(?:&.+?)?`);
  if (!m || !m.captures[1]) return BigInt(0);
  return BigInt(m.captures[1]);
}

BigInt[] getCleanBoxFullList(string dirPath, size_t maxCount = 128) {
  if (!dirPath.exists) return [];
  auto allFiles = dirEntries(dirPath, SpanMode.shallow)
    .map!(e => tuple(BigInt(e.name.baseName().replace(regex(`\.gpg$`), "")), e.name))
    .array.sort!((a, b) => a[0] < b[0]);
  if (allFiles.length <= maxCount)
    return allFiles.map!(f => f[0]).array;
  auto filesToRemove = allFiles.length - maxCount;
  // remove oldest
  try {
    foreach (fileInfo; allFiles[0 .. filesToRemove])
      remove(fileInfo[1]);
  } catch (Exception e) {
    stderr.writeln(e);
  }
  // return
  return allFiles[filesToRemove .. $].map!(f => f[0]).array;
}

string getBoxItems(string keyfp, bool retry = false) {
  const boxdir = "../../data/box/" ~ keyfp;
  if (!boxdir.exists) return "\n";
  const tss = getCleanBoxFullList(boxdir);
  const off = getOffsetFromEnv();
  const lzt = tss.filter!(e => e > off).map!(to!string).array;
  return lzt.length == 0 && retry && wait_for_new_file(boxdir.ptr, 10_000) == 1 ?
    getBoxItems(keyfp) : (lzt.join("\n") ~ '\n');
}

int main() {
  if (environment.get("REQUEST_METHOD") == "OPTIONS") {
    return writeResp("204 No Content", "", "");
  } else if (environment.get("REQUEST_METHOD") != "GET") {
    return writeResp("405 Method Not Allowed", "", "Method not allowed\n");
  }
  const keyfp = environment.get("HTTP_X_SGCC_TO");
  if (!match(keyfp, `^[0-9A-F]{40}$`))
    return writeResp("400 Bad Request", "", "X-SGCC-To in header fields is not PGP key fingerprint\n");
  try {
    return writeResp("200 OK", "", getBoxItems(keyfp, true));
  } catch (Exception e) {
    return writeResp("500 Internal Server Error", "", to!string(e));
  }
}
