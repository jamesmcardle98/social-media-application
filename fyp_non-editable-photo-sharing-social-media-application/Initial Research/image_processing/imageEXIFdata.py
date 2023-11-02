import io
import os
import pyheif
import exifread
import whatimage
from PIL import Image, ImageCms
from PIL.ExifTags import TAGS

d = "resources"
for path in os.listdir(d):
    full_path = os.path.join(d, path)
    if os.path.isfile(full_path):
        # with open(full_path, 'rb') as f:
        #     file_data = f.read()
        #     fmt = whatimage.identify_image(file_data)
        #     if fmt in ['heic', 'avif']:
        #         i = pyheif.read_heif(file_data.read())
        #         s = io.BytesIO()
        #         pi = Image.frombytes(mode=i.mode, size=i.size, data=i.data)
        #         pi.save(s, format="jpeg")
        #         current_image = s
        #     else:
        #         current_image = full_path
        with open(full_path, 'rb') as f:
            file_data = f.read()
            fmt = whatimage.identify_image(file_data)
            print(fmt)
            if fmt in ['heic', 'avif']:
                heif_file = pyheif.read_heif(full_path)
                for metadata in heif_file.metadata:
                    if metadata['type'] == 'Exif':
                        fstream = io.BytesIO(metadata['data'][6:])

                    exifdata = exifread.process_file(fstream,details=False)
                    # example to get device model from heic file
                    make = str(exifdata.get("Image Make"))
                    if make != 'Apple' :
                        print("Somethign")
                    elif 'Screenshot' in exifdata :
                        print("something")
                    else:
                        print("lala")

                    for data in exifdata:
                        print(f"{data:35}: {exifdata.get(data)}")
            else:
                current_image = full_path
    # read the image data using PIL
    img = Image.open(current_image)

    # extract EXIF data
    exifdata = img.getexif()

    print(f"\n{current_image}\n")
    for tag_id in exifdata:
        # get the tag name from tag id
        tag = TAGS.get(tag_id, tag_id)
        data = exifdata.get(tag_id)
        # decode bytes
        if isinstance(data, bytes):
            # base-64
            data = data.decode(encoding='latin-1')
            # if "Screenshot" in data:
            #     return false
            # elif
            # #      print(f"\nREJECTED\n")
        print(f"{tag:25}: {data}")

    print(f"\n\n\n\n")
