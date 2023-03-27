import base64
from binascii import unhexlify

def base64_encode(val):
    """
    Removes any `=` used as padding from the encoded string.
    """
    encoded = base64.urlsafe_b64encode(val)
    return encoded.rstrip(b"=")

def encode_int(i):
    extend = 0
    hexi = hex(i).rstrip("L").lstrip("0x")
    hexl = len(hexi)
    if extend > hexl:
        extend -= hexl
    else:
        extend = hexl % 2
    return base64_encode(unhexlify(extend * '0' + hexi)).decode('utf-8')
    