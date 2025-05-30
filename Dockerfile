## Build docker image
FROM python:3.9-alpine3.13
LABEL maintainer='Sealaholic'

# Make sure the output is unbuffered, it will be directly printed on terminal to reduce latency
ENV PYTHONUNBUFFERED=1

# Copy dependencies
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Decide working directory
WORKDIR /app

# Decide port
EXPOSE 8000

ARG DEV=false
# Run setup script
# 1. Define virtual env
# 2. Upgrade pip
# 3. Intsall dependencies
# 4. Remove useless documents (/tmp here)
# 5. Add docker user: DON'T use root user to run the app for security reason!!!
# (Disable password to log-in, don't create home directory, name = django-user)
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = 'true' ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Update env variable inside the docker image
ENV PATH='/py/bin:$PATH'

# Switch user: All above are run under root user
USER django-user