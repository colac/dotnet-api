FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS "http://*:8080"
# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
#FROM ghcr.io/colac/ghcr-infra:latest
# Create user "app" to prevent the container from running as root
RUN groupadd -g 1000 app && useradd -u 1000 -g app -s /bin/sh app
# Define the user for container execution to be "app"
USER app
WORKDIR /app
COPY --from=build-env /app/out .

ENTRYPOINT ["dotnet", "MyFirstAzureWebApp.dll"]