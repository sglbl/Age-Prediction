import urllib.request
import json
import os
import ssl

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
data = {}

# Open the image file and read its contents
with open('dede.jpg', 'rb') as image_file:
    image_data = image_file.read()

# The image data is already a binary string, so no need to encode it
# body = image_data
body = str.encode('dede.jpg')

url = 'https://ep-try3.southcentralus.inference.ml.azure.com/score'
# Replace this with the primary/secondary key or AMLToken for the endpoint
# api_key = ''
api_key = '54rcDiIWtOGoZHrpe84qbsBKj5zcjT6E'
if not api_key:
    raise Exception("A key should be provided to invoke the endpoint")

# The azureml-model-deployment header will force the request to go to a specific deployment.
# Remove this header to have the request observe the endpoint traffic rules
headers = {'Content-Type':'application/octet-stream', 'Authorization':('Bearer '+ api_key), 'azureml-model-deployment': 'dep-try7' }

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
