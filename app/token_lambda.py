from datetime import datetime, timedelta

import os
import json
import base64
from lib.logger import logger
from lib.response import success, validation_error, internal_server_error
from lib.exceptions import ValidationError
from lib.subject import get_subject
from lib.jwt import create_token

ISSUER_URL = os.environ.get('ISSUER_URL')
JWT_EXPIRATION_SECONDS = int(os.environ.get('JWT_EXPIRATION_SECONDS', '3600'))
VALID_AUDIENCES = json.loads(os.environ.get('VALID_AUDIENCES'))

def handler(event, context):
    try:
        if "action" in event:
            return {'message': 'goodbye'}

        body = event.get('body')
        if not body:
            raise ValidationError('Missing request body. The following fields are required ["aud"]')

        body_attributes = [component.split('=') for component in body.split('&')]
        parsed_body = { attribute[0]: attribute[1] for attribute in body_attributes }

        aud = parsed_body.get('aud')

        if aud not in VALID_AUDIENCES:
            raise ValidationError(f'The field "aud" is required. Supported values are {VALID_AUDIENCES}')

        request = event['requestContext']

        subject = get_subject(request['identity'])

        logger.info(f'Issuing token for subject {subject}')

        current_time = int(datetime.utcnow().timestamp())
        token = create_token({
            'aud': aud,
            'iss': ISSUER_URL,
            'sub': subject,
            'nbf': current_time,
            'iat': current_time,
            'exp': int(current_time + JWT_EXPIRATION_SECONDS),
            'amr': [ 'iam' ],
            'ipaddr': request['identity']['sourceIp']
        })

        return success({
            'access_token': token,
            'expires_in': JWT_EXPIRATION_SECONDS
        })
    except ValidationError as e:
        return validation_error(str(e))
    except Exception as e:
        logger.exception(e)
        return internal_server_error()
