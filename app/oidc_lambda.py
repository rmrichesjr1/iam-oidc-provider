import os
import boto3
from lib.logger import logger
from lib.response import success, internal_server_error
from lib.utils import base64_encode, encode_int
from cryptography.hazmat.primitives import serialization

ISSUER_URL = os.environ.get('ISSUER_URL')
KMS_KEY_ARN = os.environ.get('KMS_KEY_ARN')

session = boto3.session.Session()
kms = session.client('kms')

def handler(event, context):
    try:
        if "action" in event:
            return {'message': 'goodbye'}
        
        path = event['path']

        logger.info('path = ' + path)

        if path == '/.well-known/openid-configuration':
            return success({
                'issuer': ISSUER_URL,
                'token_endpoint': f'{ISSUER_URL}/token' ,
                'jwks_uri': f'{ISSUER_URL}/keys'
            })
        elif path == '/keys':
            response = kms.get_public_key(
                KeyId=KMS_KEY_ARN
            )

            key = serialization.load_der_public_key(response['PublicKey'])
            pn = key.public_numbers()

            return success({
                'keys': [
                    {
                        'kty': 'RSA',
                        'use': 'sig',
                        'kid': KMS_KEY_ARN,
                        'n': encode_int(pn.n),
                        'e': encode_int(pn.e),
                        'issuer': ISSUER_URL
                    }
                ]
            })
        else:
            logger.error(f'invalid path received {path}')
            return internal_server_error()
    except Exception as e:
        logger.exception(e)
        return internal_server_error()
