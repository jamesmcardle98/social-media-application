import io
import os
import pyheif
import exifread
import whatimage
from PIL import Image, ImageCms
from PIL.ExifTags import TAGS

# Modified Image Recognition Algorithm:
# Core Algorithm for detecting whether or not an image has been edited or is coming from a different source other than the phone
# By James McArdle
class Mir():
    def mir_algoirthm( img ):
        # Try the following tests on image, if all pass then accept image otherwise reject
        current_image = img
        with open(img, 'rb') as f:
            file_data = f.read()
        try:
            # iPhone images are generally taken in .HEIC format, if image is in this format run the following tests, otherwise run .jpg tests
            fmt = whatimage.identify_image(file_data)
            if fmt in ['heic', 'avif']:
                heif_file = pyheif.read_heif(current_image)
                for metadata in heif_file.metadata:
                    if metadata['type'] == 'Exif':
                        fstream = io.BytesIO(metadata['data'][6:])

                    exifdata = exifread.process_file(fstream,details=False)
                    # ensure the make is coming from an apple product, might have to change this because could be coming from another camera and be non-edited
                    make = str(exifdata.get("Image Make"))
                    if make != 'Apple' :
                        return False
                    elif 'Screenshot' in exifdata :
                        return False
                    else:
                        return True
            else:
                image = Image.open(current_image)
                # extract ICC profile from image
                icc = image.info.get('icc_profile')
                f = io.BytesIO(icc)
                prf = ImageCms.ImageCmsProfile(f)
                icc_test = ImageCms.getProfileCopyright(prf)
                # test if the image source is coming from an apple product (i.e an iPhone), if not reject
                if "Apple" not in icc_test:
                    return False
                # extract EXIF data
                exifdata = image.getexif()
                for tag_id in exifdata:
                    # get the tag name from tag id
                    tag = TAGS.get(tag_id, tag_id)
                    data = exifdata.get(tag_id)
                    # decode bytes
                    if isinstance(data, bytes):
                        # base-64
                        data = data.decode(encoding='latin-1')
                        # has image been screenshotted from another source, if so reject
                        if "Screenshot" in data:
                            return False
                        # if image has passed all tests to here, accept image for posting
                        else:
                            return True
        except:
            # image has been modified or is in the wrong format -> REJECT IMAGE
            return False

    # Test the algorithm for the sample images in the resources folder
    d = "resources"
    for path in os.listdir(d):
        full_path = os.path.join(d, path)
        if os.path.isfile(full_path):
            if mir_algoirthm(full_path):
                print(f"Image Accepted: {full_path}\n")
            else:
                print(f"Image Rejected: {full_path}\n")
