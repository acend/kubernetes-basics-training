ARG HUGO_VERSION=0.76.5

FROM acend/hugo:${HUGO_VERSION} AS builder

ARG HUGO_ENV=default

EXPOSE 8080

RUN mkdir -p /opt/app/src/static && \
    chmod -R og+rwx /opt/app

WORKDIR /opt/app/src

COPY . /opt/app/src

RUN npm install -D --save autoprefixer postcss postcss-cli

RUN hugo --environment ${HUGO_ENV} --minify

FROM nginxinc/nginx-unprivileged:alpine

COPY --from=builder  /opt/app/src/public /usr/share/nginx/html
