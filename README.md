# GPG Chat Platform - SGCC

A simple, stateless, and GPG-based chat platform with a CGI backend.

This project is an experimental platform that leverages the power of GPG for secure, end-to-end encrypted messaging. The backend is built using a simple Common Gateway Interface (CGI) architecture, making it lightweight and easy to deploy on any server with CGI support.

## Features

* **GPG-Based Encryption:** All messages are encrypted using the GNU Privacy Guard (GPG), a free implementation of the OpenPGP, ensuring end-to-end security and privacy.
* **Lightweight CGI Backend:** The server is written in D language, a high-performance C-like language. Its CGI-based design avoids complex server setups, making it easy to host.
* **Simple API Design:** A straightforward API allows for easy integration with various clients, from simple shell scripts to modern web applications.
* **UNIX Philosophy:** The project embraces the UNIX philosophy, using small, focused programs that do one thing and do it well.

## API Documentation

For detailed information on the available endpoints and how to use them, please refer to the [API documentation](docs/README.md).

## Development

This project is a work in progress. If you'd like to contribute, please feel free to fork the repository and submit a pull request. We welcome all contributions, big or small!

* **Requirements:** C compiler, D compiler, GnuPG, Busybox, GNU coreutils, GNU Make, GNU findutils, GNU bash
* **Compiling**: `make -j$(nproc)`
* **Running:** `./start_server.sh` with an optional port number (default is 8080)
* **Clients:** Example implementations of clients in various programming languages can be found in the [`client`](client) directory.

## License

This project is licensed under the **GPLv3** (GNU General Public License Version 3). Please see the [`LICENSE`](LICENSE) file for more details.

The documentation is licensed under the **CC-BY-NC-SA 4.0** (Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International).
