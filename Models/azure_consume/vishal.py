import base64
import requests
from PIL import Image
import numpy as np
import json

def preprocess(image_bytes):
    image = Image.open(image_bytes)        
    image = image.resize((48,48)).convert('L')
    # image.show()
    image_np = (255 - np.array(image.getdata())) / 255.0

    return image_np.reshape(-1,48,48,1)

def encoder(image_src):
    # with open(image_src, "rb") as image_file:
    with open(image_src, "rb") as image_file:
        image_bytes = image_file.read()
    encoded_string = base64.b64encode(image_bytes)
    return encoded_string

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
    return raw_data['image']
    # return json_data


## Put your own REST endpoint
# url = "ägmekmva.com"
url = "https://ep-try3.southcentralus.inference.ml.azure.com/score"
payload={}

files=[
    # ('image',('file', preprocess('dede.jpg') ,'image/jpg'))
    # ('image',('file', preprocess('dede.jpg') ,'image/jpg'))
  ('image', ('file', encoded_to_string_to_json(encoder('dede.jpg')), 'application/octet-stream'))
]

headers = {
  'Authorization': 'Bearer 54rcDiIWtOGoZHrpe84qbsBKj5zcjT6E',
  'Content-Type':'application/json', 
  'azureml-model-deployment': 'dep-try13' 
}

response = requests.request("POST", url, headers=headers, files=files)
print(response.text)