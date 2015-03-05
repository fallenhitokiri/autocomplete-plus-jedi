# -*- coding: utf-8 -*-
import os
import sys
import json
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

sys.path.append(os.path.realpath(__file__))

import jedi


class http_completion(BaseHTTPRequestHandler):
    """
    Completion handler which returns the completions for a given source,
    line and cursor positon.
    """
    def _set_headers(self):
        """set the standard headers for a JSON response"""
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

    def do_POST(self):
        """
        Payload to receive:
            source: whole source to parse
            line / column : current line and column

        Returns:
            array with dictionaries in it (name, description, docstring)
        """
        self._set_headers()

        length = int(self.headers.getheader('content-length', 0))
        read = self.rfile.read(length)
        read = json.loads(read)

        payload = completions(read["source"], read["line"], read["column"])
        payload = json.dumps(payload)

        self.wfile.write(payload)
        return


def run_server(port):
    """
    run the httpd

    Arguments:
        port: port to run the server on
    """
    address = ('', port)
    httpd = HTTPServer(address, http_completion)
    print "Starting httpd"
    httpd.serve_forever()


def completions(source, line, column):
    """
    generate list with completions for the line and column.

    Arguments:
        source: source code to generate completion for
        line, column: current cursor position in the source code

    Returns:
        list with dictionaries containing the name, docstring and description
        for all completions.
    """
    script = jedi.api.Script(
        source=source,
        line=line + 1,
        column=column,
    )

    completions = list()

    for completion in script.completions():
        completions.append({
            "name": completion.name,
            "description": completion.description,
            "docstring": completion.docstring(),
        })

    return completions


if __name__ == "__main__":
    project_path = sys.argv[1]
    sys.path.append(project_path)

    port = 7777

    # try to start the httpd on a port between 7777 and 7999
    while port < 7999:
        try:
            try:
                run_server(port)
            except KeyboardInterrupt:
                break
        except:
            port += 1
