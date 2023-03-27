import json
from lib.logger import logger

def validation_error(msg):
    logger.warning(f'Validation error: {msg}')
    return response({'message': msg}, 400)

def success(body):
    return response(body, 200)

def internal_server_error():
    return response({
            'message': 'Unexpected error occurred'
        }, 500)

def response(body, status):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body),
        "isBase64Encoded": False
    }