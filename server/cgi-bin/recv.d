#!/bin/env rdmd

import std.base64 : Base64;
import std.file : read, FileException;
import std.process : environment;
import std.stdio : stderr;

import internal.utils : writeResp, checkEmail;

string readMail(string email) {
  const mailfile =
    "../../data/box/" ~
    cast(string)Base64.encode(cast(ubyte[])email) ~ '/' ~
    environment.get("HTTP_X_SGCC_FTS") ~ ".gpg";
  return cast(string)read(mailfile);
}

int main() {
  if (environment.get("REQUEST_METHOD") == "OPTIONS") {
    return writeResp("204 No Content", "", "");
  } else if (environment.get("REQUEST_METHOD") != "GET") {
    return writeResp("405 Method Not Allowed", "", "Method not allowed\n");
  }
  const email = environment.get("HTTP_X_SGCC_TO");
  if (!checkEmail(email))
    return writeResp("400 Bad Request", "", "X-SGCC-To in header fields is not an Email address\n");
  try {
    return writeResp("200 OK", "Content-Type: application/pgp-encrypted", readMail(email));
  } catch (FileException e) {
    stderr.writeln(e);
    return writeResp("404 Not Found", "", "Mail not found\n");
  }
}
