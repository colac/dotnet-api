FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
EXPOSE 80
EXPOSE 443
ENV ASPNETCORE_URLS "http://*:80"
# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore "MyFirstAzureWebApp.csproj"
# Build and publish a release
RUN dotnet build "MyFirstAzureWebApp.csproj" -c Release -o /app/build
# Build and publish a release
RUN dotnet publish "MyFirstAzureWebApp.csproj" -c Release -o /app/publish

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
#FROM ghcr.io/colac/ghcr-infra:latest
EXPOSE 80
EXPOSE 443

# Create user "app" to prevent the container from running as root
RUN groupadd -g 1000 app && useradd -u 1000 -g app -s /bin/sh app
# Define the user for container execution to be "app"
USER app
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "MyFirstAzureWebApp.dll"]