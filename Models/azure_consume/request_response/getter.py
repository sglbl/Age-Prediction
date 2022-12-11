import os
from flask import Flask, request, render_template

rx_file_listener = Flask(__name__)

# files_store = "/tmp"
@rx_file_listener.route("/upload", methods=['POST'])
def upload_file():
    # storage = os.path.join(files_store, "uploaded/")
    storage = "uploaded"
    print(storage)
    
    if not os.path.isdir(storage):
        os.mkdir(storage)

    try:
        print(request.files)
        print(request.files.getlist("file"))
        for file_rx in request.files.getlist("file"):
            name = file_rx.filename
            destination = "\\".join([storage, name])
            file_rx.save(destination)
        
        return "200"
    except Exception:
        return "500"

if __name__ == "__main__":
    rx_file_listener.run(port=54321, debug=True)