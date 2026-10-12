# Build context is the repo root: the site reads Design/ and Apps/*/fastlane/metadata.
# Coolify: Dockerfile build pack, base directory /, Dockerfile location /Site/Dockerfile, port 80.
FROM node:24-alpine AS build
WORKDIR /repo
COPY Site/package.json Site/package-lock.json Site/
RUN cd Site && npm ci
COPY Design Design
COPY Apps Apps
COPY Site Site
RUN cd Site && npm run build

FROM nginx:1.29-alpine
COPY Site/nginx.conf /etc/nginx/conf.d/default.conf
COPY Site/headers.inc /etc/nginx/conf.d/headers.inc
COPY --from=build /repo/Site/dist /usr/share/nginx/html
