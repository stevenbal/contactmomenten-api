# Stage 1 - Compile needed python dependencies
FROM python:3.7-alpine AS build
RUN apk --no-cache add \
    gcc \
    musl-dev \
    pcre-dev \
    linux-headers \
    postgresql-dev \
    python3-dev \
    # lxml dependencies
    libxslt-dev

WORKDIR /app

COPY ./requirements /app/requirements
RUN pip install pip setuptools -U
RUN pip install -r requirements/production.txt


# Stage 2 - build frontend
FROM mhart/alpine-node:10 AS frontend-build

WORKDIR /app

COPY ./*.json /app/
RUN npm install

COPY ./Gulpfile.js /app/
COPY ./build /app/build/

COPY src/contactmomenten/sass/ /app/src/contactmomenten/sass/
RUN npm run build

# Stage 3 - Build docker image suitable for execution and deployment
FROM python:3.7-alpine AS production
RUN apk --no-cache add \
    ca-certificates \
    mailcap \
    musl \
    pcre \
    postgresql \
    # lxml dependencies
    libxslt \
    # pillow dependencies
    jpeg \
    openjpeg \
    zlib

# Stage 3.1 - Set up dependencies
COPY --from=build /usr/local/lib/python3.7 /usr/local/lib/python3.7
COPY --from=build /usr/local/bin/uwsgi /usr/local/bin/uwsgi

# required for fonts,styles etc.
COPY --from=frontend-build /app/node_modules/font-awesome /app/node_modules/font-awesome

# Stage 3.2 - Copy source code
WORKDIR /app
COPY ./bin/docker_start.sh /start.sh
RUN mkdir /app/log

COPY --from=frontend-build /app/src/contactmomenten/static/css /app/src/contactmomenten/static/css
COPY ./src /app/src

ENV DJANGO_SETTINGS_MODULE=contactmomenten.conf.docker

ARG SECRET_KEY=dummy

# Run collectstatic, so the result is already included in the image
RUN python src/manage.py collectstatic --noinput

EXPOSE 8000
CMD ["/start.sh"]
