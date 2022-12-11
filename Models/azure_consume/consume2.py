import urllib.request
import json
import os
import ssl
import base64

def allowSelfSignedHttps(allowed):
    # bypass the server certificate verification on client side
    if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
        ssl._create_default_https_context = ssl._create_unverified_context

allowSelfSignedHttps(True) # this line is needed if you use self-signed certificate in your scoring service.

# Request data goes here
# The example below assumes JSON formatting which may be updated
# depending on the format your endpoint expects.
# More information can be found here:
# https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script

def encoder(image_src):
    # with open(image_src, "rb") as image_file:
    with open(image_src, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read())
    return encoded_string

base64_bytes = encoder('dede.jpg')

def encoded_to_string_to_json(base64_bytes):
    # third: decode these bytes to text
    # result: string (in utf-8)
    base64_string = base64_bytes.decode("utf-8")

    # optional: doing stuff with the data
    # result here: some dict
    raw_data = {"image": base64_string}

    # now: encoding the data to json
    # result: string
    json_data = json.dumps(raw_data, indent=2)

    # finally: writing the json string to disk
    # note the 'w' flag, no 'b' needed as we deal with text here
    with open("outputfile.json", 'w') as json_file:
        json_file.write(json_data)
    return json_data

# body = str.encode(json.dumps(str(data)))
json_data = encoded_to_string_to_json(base64_bytes)
body = str.encode(json_data)
# body = json_data

url = 'https://ep-try3.southcentralus.inference.ml.azure.com/score'
# Replace this with the primary/secondary key or AMLToken for the endpoint
# api_key = ''
api_key = '54rcDiIWtOGoZHrpe84qbsBKj5zcjT6E'
if not api_key:
    raise Exception("A key should be provided to invoke the endpoint")

# The azureml-model-deployment header will force the request to go to a specific deployment.
# Remove this header to have the request observe the endpoint traffic rules
headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key), 'azureml-model-deployment': 'dep-try8' }

req = urllib.request.Request(url, body, headers)

try:
    response = urllib.request.urlopen(req)

    result = response.read()
    print(result)
except urllib.error.HTTPError as error:
    print("The request failed with status code: " + str(error.code))

    # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
    print(error.info())
    print(error.read().decode("utf8", 'ignore'))
