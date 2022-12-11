import requests

url = 'http://127.0.0.1:54321/upload'
# file_to_send = 'lab9_sol.pdf'
file_to_send = 'sglbl.jpg'

files = {'file': (file_to_send,
                  open(file_to_send, 'rb'),
                #   'application/pdf',
                'application/octet-stream',
                  {'Expires': '0'})}

reply = requests.post(url=url, files=files)
print(reply.text)