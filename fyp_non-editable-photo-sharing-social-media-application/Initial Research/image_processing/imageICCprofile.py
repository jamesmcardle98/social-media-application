import io

from PIL import Image
from PIL import ImageCms

image_list = ['unedited', 'edited', 'screenshot', 'editedEXIF', 'online']

for image in image_list:
    current_image = "sample_" + image + ".jpg"
    try:
        image = Image.open(current_image)
        icc = image.info.get('icc_profile')
        f = io.BytesIO(icc)
        prf = ImageCms.ImageCmsProfile(f)
        print(f"{current_image}\n{ImageCms.getProfileCopyright(prf)}\n{ImageCms.getProfileName(prf)}\n")
    except:
        print(f"{current_image} wasnt able to load icc profile")


        # byte_str = f.getvalue()
        # text = byte_str.decode('latin-1')
        # print("\nTrying to decode byte string:\n")
        # print(text)
    #print(f"\n1: {ImageCms.getProfileInfo(prf)} \n")
    #print(f"2: {ImageCms.getProfileName(prf)} \n")
        #print(f"3: {ImageCms.getDefaultIntent(prf)} \n")
        #print(f"4: {ImageCms.getProfileDescription(prf)} \n")


# for tag_id in prf:
#     # get the tag name from tag id
#     tag = TAGS.get(tag_id, tag_id)
#     data = prf.get(tag_id)
#     # decode bytes
#     if isinstance(data, bytes):
#         data = data.decode(encoding='latin-1')

#     print(f"{tag:25}: {data}")
