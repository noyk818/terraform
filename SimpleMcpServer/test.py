import requests
import json

url = "http://localhost:5000/mcp"

payload = {
    "jsonrpc": "2.0",
    "method": "tools/list",
    "params": {},
    "id": 1
}

# payload = {
#     "jsonrpc": "2.0",
#     "method": "tools/call",
#     "params": {
#         "name": "echo",
#         "arguments": {
#             "message": "Hello from Python"
#         }
#     },
#     "id": 1
# }

# payload = {
#     "jsonrpc": "2.0",
#     "method": "tools/call",
#     "params": {
#         "name": "add",
#         "arguments": {
#             "a": 3,
#             "b": 5
#         }
#     },
#     "id": 1
# }

# payload = {
#     "jsonrpc": "2.0",
#     "method": "tools/call",
#     "params": {
#         "name": "zone",
#         "arguments": {
#             # "timeZone": "Asia/Tokyo"
#             "timeZone": "America/New_York"
#         }
#     },
#     "id": 1
# }

headers = {"Content-Type": "application/json"}

response = requests.post(url, headers=headers, data=json.dumps(payload), verify=False)

lines = response.text.strip().split('\n')
for line in lines:
    if line.startswith('data: '):
        data = line[6:]
        parsed = json.loads(data)
        print(json.dumps(parsed, ensure_ascii=False, indent=2))
    else:
        print(line)
