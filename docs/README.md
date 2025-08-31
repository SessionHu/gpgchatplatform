# SGCC Platform API Documentation

The SGCC Platform API provides a set of simple, stateless CGI endpoints for a `gpg`-based chat application. It allows for sending and receiving encrypted messages.

## 1\. 发送消息 (Sending a Message)

This endpoint is used to send an encrypted message to a recipient.

  * **URI**: `/cgi-bin/send`

  * **Method**: `POST`

  * **Request Headers**:

      * `X-SGCC-To`: The recipient's email address (e.g., `ex@mple.com`).
      * `Content-Type`: `application/pgp-encrypted`

  * **Request Body**: The encrypted message content, as binary data. This is typically the output from a `gpg` command.

  * **Example (using `curl`)**:

    ```bash
    gpg -vesr "ex@mple.com" < my_message.txt | \
    curl "http://0:8080/cgi-bin/send" \
      -X POST \
      -H "X-SGCC-To: ex@mple.com" \
      -H "Content-Type: application/pgp-encrypted" \
      --data-binary @- \
      -vL
    ```

## 2\. 列出消息 (Listing Messages)

This endpoint is used to retrieve a list of message IDs for a specific recipient.

  * **URI**: `/cgi-bin/list.d`

  * **Method**: `GET`

  * **URL Querys** (Optional):

      * `offset`: The starting offset for the list (default: 0).

  * **Request Headers**:

      * `X-SGCC-To`: The recipient's email address (e.g., `ex@mple.com`).

  * **Response Body**: A list of message IDs, separated by spaces. A message ID is a nano-level timestamp.

  * **Example (using `curl`)**:

    ```bash
    curl "http://0:8080/cgi-bin/list.d" -H "X-SGCC-To: ex@mple.com" -vL
    ```

## 3\. 接收消息 (Receiving a Message)

This endpoint is used to retrieve a specific encrypted message by its ID.

  * **URI**: `/cgi-bin/recv.d`

  * **Method**: `GET`

  * **Request Headers**:

      * `X-SGCC-To`: The recipient's email address (e.g., `ex@mple.com`).
      * `X-SGCC-FTS`: The message ID (e.g., a nano-level timestamp like `1725114000000000000`).

  * **Response Body**: The encrypted message content, as binary data.

  * **Example (using `curl`)**:

    ```bash
    curl "http://0:8080/cgi-bin/recv.d" \
      -H "X-SGCC-To: ex@mple.com" \
      -H "X-SGCC-FTS: 1725114000000000000" \
      -vL | gpg -dv
    ```

---

Copyright (C) 2025 SessionHu
This document is licensed under the CC BY-NC-SA 4.0 International.
