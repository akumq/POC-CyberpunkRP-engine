FROM mcr.microsoft.com/dotnet/sdk:8.0.404-bookworm-slim-amd64 AS build
WORKDIR /app
ENV XMAKE_ROOT=y

# Dépôts de paquets xmake figés à la date du lock (2024-11-21). Sans ça, les
# dépendances non versionnées suivent la dernière version publiée et cassent
# (abseil, entt et cryptopp de 2026 ne compilent plus avec g++ 12 / CMake 3.25).
# Le fichier « updated » empêche xmake de les remettre à jour au configure.
ARG XMAKE_REPO_COMMIT=fe18a6cedc7e530c290e8c31db68eddbc87c120e

RUN echo 'deb http://deb.debian.org/debian bookworm-backports main' >> /etc/apt/sources.list
RUN apt-get update \
  && apt-get install -y --no-install-recommends xmake g++ git unzip ca-certificates make cmake pkg-config perl nodejs npm \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && npm install -g pnpm@9

RUN git clone https://github.com/xmake-io/xmake-repo.git /root/.xmake/repositories/xmake-repo \
  && git -C /root/.xmake/repositories/xmake-repo checkout --quiet ${XMAKE_REPO_COMMIT} \
  && git clone --depth=1 https://github.com/xmake-mirror/build-artifacts.git /root/.xmake/repositories/build-artifacts \
  && touch /root/.xmake/repositories/xmake-repo/updated /root/.xmake/repositories/build-artifacts/updated

COPY . .

RUN --mount=type=cache,target=/root/.xmake/packages xmake f -m release -y \
  && xmake -y

# RELEASE STAGE
FROM mcr.microsoft.com/dotnet/runtime:8.0.11-bookworm-slim-amd64 AS release
WORKDIR /app

COPY --from=build /app/build/linux/x86_64/release/ /app/

EXPOSE 11778
CMD [ "/app/Server.Loader" ]
