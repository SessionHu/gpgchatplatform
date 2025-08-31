#!/bin/env -S rdmd -I.

import internal.utils;

@safe
int main(string[] args) {
  return args.length < 2 || !args[1].checkEmail;
}
