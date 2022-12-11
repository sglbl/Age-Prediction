# from PIL import Image
# import json

# #create sample file. You don't have to do this in your real code.
# # img = Image.new("RGB", (10,10), "red")
# image = Image.open("dede.jpg")        
# image = image.resize((48,48)).convert('L')
# # # image.show()
# # image_np = (255 - np.array(image.getdata())) / 255.0

# # return image_np.reshape(-1,48,48,1)

# #decode.
# s = image.tobytes().decode("latin1")

# #serialize.
# with open("outputfile.json", "w") as file:
#     json.dump(s, file)
    
    
    
import json
from PIL import Image
import numpy as np

filename = "dede.jpg"
image = Image.open(filename)
# json_data = json.dumps(np.array(image).tolist())
with open("outputfile.json", "w") as file:
    # json.dump(json_data, file)
    json.dump(np.array(image).tolist(), file)
# new_image = Image.fromarray(np.array(json.loads(json_data), dtype='uint8'))