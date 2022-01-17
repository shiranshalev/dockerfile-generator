FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app
COPY ["ConsoleApp/ConsoleApp.csproj","ConsoleApp/"]
COPY ["SomeIntefrace/SomeIntefrace.csproj","SomeIntefrace/"]
COPY ["SomeLibrary/SomeLibrary.csproj","SomeLibrary/"]

COPY ["ConsoleApp/","ConsoleApp/"]
COPY ["SomeIntefrace/","SomeIntefrace/"]
COPY ["SomeLibrary/","SomeLibrary/"]

WORKDIR "/app/ConsoleApp"
# under <PropertyGroup> add:
# <AssemblyName>$(ASPASP_ENVVAR)</AssemblyName>
# assembly output will be dotnetfoo.dll
# but the docker file environment variable does not persist after this RUN command.
# maybe too much hassle to automate everything.
ENV ASPASP_ENVVAR="dotnet" 
RUN dotnet build "ConsoleApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ConsoleApp.csproj" --no-restore -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]
