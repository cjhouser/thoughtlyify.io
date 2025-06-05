FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /github.com/cjhouser/thoughtlyify.io/services/thought/
COPY Program.cs thought.csproj ./
RUN dotnet restore
RUN dotnet publish \
    --configuration Release \
    --disable-build-servers \
    --nologo \
    --no-restore \
    --output /build/app \
    --tl:off \
    --verbosity quiet

FROM mcr.microsoft.com/dotnet/runtime:9.0
WORKDIR /app
COPY --from=build --chown=10001:10001 --chmod=700 /build/app .
USER 10001
ENTRYPOINT ["dotnet", "thought.dll"]