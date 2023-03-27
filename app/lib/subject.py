from lib.exceptions import ValidationError

def get_subject(identity):
    user_arn = identity['userArn']
    account_id = identity['accountId']

    if 'assumed-role' in user_arn:
        role_name = user_arn.split('/')[1]
        sub = f'arn:{user_arn.split(":")[1]}:iam::{account_id}:role/{role_name}'
    elif len(user_arn.split(':')) > 5 and user_arn.split(':')[5].startswith('user/'):
        sub = user_arn
    else:
        raise ValidationError(f'This request was not signed using an IAM role or user identity. (identity = {user_arn})')
    
    return sub

