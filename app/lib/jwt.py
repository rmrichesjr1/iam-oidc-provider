from lib.utils import base64_encode
import boto3
import os
import json

KMS_KEY_ARN = os.environ.get('KMS_KEY_ARN')

session = boto3.session.Session()
kms = session.client('kms')

def create_token(payload):
    headers = {
        'alg': "RS256",
        'typ': "JWT",
        'kid': KMS_KEY_ARN
    }

    token_components = {
        'header': base64_encode(json.dumps(headers, separators=(',', ':')).encode()).decode("utf-8"),
        'payload': base64_encode(json.dumps(payload, separators=(',', ':')).encode()).decode("utf-8"),
    }

    message_string = token_components['header'] + "." + token_components['payload']

    response = kms.sign(
        KeyId=KMS_KEY_ARN,
        Message=message_string.encode("utf-8"),
        MessageType='RAW',
        SigningAlgorithm='RSASSA_PKCS1_V1_5_SHA_256'
    )

    token_components['signature'] = base64_encode(response['Signature']).decode("utf-8")

    return token_components['header'] + "." + token_components['payload'] + "." + token_components['signature']
