# iam-oidc-provider

The iam-oidc-provider service uses KMS asymmetric keys to issue JWT tokens that can be used to authenticate with services that support OIDC federated authentication. The IAM OIDC provider uses AWS V4 signatures to verify a subjects identity. The `sub` field in the JWT token will be populated based on the IAM identity used when making the request to get a token. 

### Examples on how to request a token using curl
To create a token, you'll need to make a POST request to the token endpoint and pass the `aud` field via the request body.

#### IAM Role Identifier Type

`awscurl -X POST --region us-east-2 https://iam-oidc-provider.example.com/token -d 'aud=api'`

#### IAM User Identifier Type

`awscurl -X POST --region us-east-2 --access_key redacted --secret_key redacted https://iam-oidc-provider.example.com/token -d 'aud=api'`

## Token Identifier Types
* `iam_role`: arn:aws:iam::account-id:role/role-name
* `iam_user_arn`: arn:aws:iam::account-id:user/user-name

## Decoded JWT Token

```
{
  "aud": "api",
  "iss": "https://iam-oidc-auth.example.com",
  "sub": "arn:aws:iam:392491131356:role/some-role-name",
  "nbf": 1592330913,
  "iat": 1592330913,
  "exp": 1592334513,
  "amr": [
    "iam"
  ],
  "ipaddr": "95.16.83.222"
}
```
