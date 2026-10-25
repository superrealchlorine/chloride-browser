#!/usr/bin/env python3
import sys
import struct
import json
import socket
import base64

def read_message():
	raw_length = sys.stdin.buffer.read(4)
	if not raw_length or len(raw_length) < 4:
		sys.exit(0)
	message_length = struct.unpack('@I', raw_length)[0]
	message = sys.stdin.buffer.read(message_length).decode('utf-8')
	return json.loads(message)

def send_message(message_content):
	encoded_content = json.dumps(message_content).encode('utf-8')
	encoded_length = struct.pack('@I', len(encoded_content))
	sys.stdout.buffer.write(encoded_length)
	sys.stdout.buffer.write(encoded_content)
	sys.stdout.buffer.flush()

def main():
	try:
		msg = read_message()
		host = msg.get("host", "127.0.0.1")
		port = int(msg.get("port", 49130))

		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.settimeout(5.0)
		s.connect((host, port))

		data = bytearray()
		while True:
			chunk = s.recv(4096)
			if not chunk:
				break
			data.extend(chunk)
		s.close()

		b64_wasm = base64.b64encode(data).decode('utf-8')
		send_message({"status": "ok", "data": b64_wasm})

	except Exception as e:
		send_message({"status": "error", "error": str(e)})

if __name__ == "__main__":
	main()
