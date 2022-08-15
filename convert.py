import base64

def image_to_base64(filepath):
    with open(filepath, "rb") as img_file:
        base64string = base64.b64encode(img_file.read())

    return base64string.decode("utf-8")