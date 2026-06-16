FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=https://revision-api.yoahn.me
ARG APP_BUILD_VERSION
RUN flutter build web --release --base-href=/ --dart-define=API_BASE_URL=${API_BASE_URL} \
  && BUILD_VERSION="${APP_BUILD_VERSION:-$(date +%s)}" \
  && sed -i "s|src=\"flutter_bootstrap.js\"|src=\"flutter_bootstrap.js?v=${BUILD_VERSION}\"|g" build/web/index.html \
  && sed -i "s|mainJsPath\":\"main.dart.js\"|mainJsPath\":\"main.dart.js?v=${BUILD_VERSION}\"|g" build/web/flutter_bootstrap.js

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
