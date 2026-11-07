#!/usr/bin/env python3
"""Human OS, local web build: serves ./app on http://localhost:8765/ (this
computer only) and opens it in the browser. Needs only Python 3."""
import http.server, mimetypes, os, socketserver, sys, threading, webbrowser

PORT = 8765
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app")
mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("text/javascript", ".js")
mimetypes.add_type("text/javascript", ".mjs")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=ROOT, **k)

    def log_message(self, *args):  # quiet
        pass


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


if __name__ == "__main__":
    try:
        srv = Server(("127.0.0.1", PORT), Handler)
    except OSError:
        sys.exit(f"Port {PORT} is in use. Close the other Human OS and try again.")
    print(f"Human OS is running at http://localhost:{PORT}/  (Ctrl+C to stop)")
    threading.Timer(0.8, lambda: webbrowser.open(f"http://localhost:{PORT}/")).start()
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
