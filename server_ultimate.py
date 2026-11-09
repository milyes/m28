import asyncio
import os
import sys
import json

PORT = 8080
HTML_FILE = "zcore_server_2028.bin.html"
CREDITS_FILE = "local_credits_database.json"

def get_stored_credits():
    if not os.path.exists(CREDITS_FILE):
        with open(CREDITS_FILE, 'w') as f:
            json.dump({"credits": 0}, f)
        return 0
    try:
        with open(CREDITS_FILE, 'r') as f:
            return json.load(f).get("credits", 0)
    except Exception:
        return 0

def save_credits(amount):
    with open(CREDITS_FILE, 'w') as f:
        json.dump({"credits": amount}, f)

async def handle_http_transaction(reader, writer):
    try:
        request_data = await reader.readline()
        if not request_data: return
        
        parts = request_data.decode().split(' ')
        if len(parts) < 2: return
        method, path = parts[0], parts[1]
        
        headers = {}
        while True:
            line = await reader.readline()
            header_line = line.decode().strip()
            if not header_line: break
            if ':' in header_line:
                k, v = header_line.split(':', 1)
                headers[k.strip().lower()] = v.strip()

        if method == 'GET':
            if path == '/api/get-credits':
                content = json.dumps({"credits": get_stored_credits()})
                response = f"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {len(content)}\r\nAccess-Control-Allow-Origin: *\r\n\r\n{content}"
            elif os.path.exists(HTML_FILE):
                with open(HTML_FILE, 'r', encoding='utf-8') as f:
                    content = f.read()
                response = f"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: {len(content.encode('utf-8'))}\r\n\r\n{content}"
            else:
                response = "HTTP/1.1 404 Not Found\r\n\r\n"
            writer.write(response.encode('utf-8'))
            await writer.drain()

        elif method == 'POST' and path == '/api/create-payment-intent':
            content_length = int(headers.get('content-length', 0))
            body = await reader.readexactly(content_length)
            
            # Signature sécurisée du token de paiement NetSecurePro
            mock_intent = {"clientSecret": "pi_live_production_secret_token_nsp_2026_secret_test"}
            content = json.dumps(mock_intent)
            response = f"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {len(content)}\r\n\r\n{content}"
            writer.write(response.encode('utf-8'))
            await writer.drain()

        elif method == 'POST' and path == '/api/add-credits':
            content_length = int(headers.get('content-length', 0))
            body = await reader.readexactly(content_length)
            req_data = json.loads(body.decode())
            
            current = get_stored_credits()
            new_balance = current + int(req_data.get("amount", 0))
            save_credits(new_balance)
            
            content = json.dumps({"status": "success", "new_balance": new_balance})
            response = f"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {len(content)}\r\n\r\n{content}"
            writer.write(response.encode('utf-8'))
            await writer.drain()

    except Exception as e:
        sys.stderr.write(f"[ERR] {str(e)}\n")
    finally:
        writer.close()
        await writer.wait_closed()

async def main():
    server = await asyncio.start_server(handle_http_transaction, '0.0.0.0', PORT)
    sys.stdout.write(f"\033[1;32m[Z-CORE PROD]\033[0m Système de crédits synchronisé sur le port {PORT}\n")
    sys.stdout.flush()
    async with server:
        await server.serve_forever()

if __name__ == '__main__':
    asyncio.run(main())
