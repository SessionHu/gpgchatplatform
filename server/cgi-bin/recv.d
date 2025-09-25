#!/bin/env rdmd

import std.file : read, FileException;
import std.process : environment;
import std.stdio : stderr;
import std.regex : match;

import internal.utils : writeResp;

string readMail(string keyfp, string fts) {
  const mailfile = "../../data/box/" ~ keyfp ~ '/' ~ fts ~ ".gpg";
  return cast(string)read(mailfile);
}

int main() {
  if (environment.get("REQUEST_METHOD") == "OPTIONS") {
    return writeResp("204 No Content", "", "");
  } else if (environment.get("REQUEST_METHOD") != "GET") {
    return writeResp("405 Method Not Allowed", "", "Method not allowed\n");
  }
  const fts = environment.get("HTTP_X_SGCC_FTS");
  const keyfp = environment.get("HTTP_X_SGCC_TO");
  if (!match(keyfp, `^[0-9A-F]{40}$`))
    return writeResp("400 Bad Request", "", "X-SGCC-To in header fields is not PGP key fingerprint\n");
  else if (!match(fts, `^\d+$`))
    return writeResp("400 Bad Request", "", "X-SGCC-FTS in header fields is not a number\n");
  try {
    return writeResp("200 OK", "Content-Type: application/pgp-encrypted", readMail(keyfp, fts));
  } catch (FileException e) {
    stderr.writeln(e);
    return writeResp("404 Not Found", "", "Mail not found\n");
  }
}
