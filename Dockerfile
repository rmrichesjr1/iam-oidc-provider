ARG handlername
# The handlername argument should be either "oidc_lambda.py" or "token_lambda.py".

# To build:
#   docker build --build-arg handlername=oidc_lambda.py  -t tharsis/iam-oidc-provider-oidc  .
#   docker build --build-arg handlername=token_lambda.py -t tharsis/iam-oidc-provider-token .

FROM public.ecr.aws/lambda/python:3.9

WORKDIR /

COPY requirements.txt  .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

WORKDIR app
COPY app/* .

CMD ["${LAMBDA_TASK_ROOT}/${handlername}"]

# The End.
