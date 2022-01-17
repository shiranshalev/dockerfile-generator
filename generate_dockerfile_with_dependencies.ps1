
# Param(
# [Parameter(Mandatory = $True)]
# [string]$mainProject,
# [Parameter(Mandatory=$True)]
# [string]$dll,
# [Parameter(Mandatory=$True)]
# [string]$maincsproj
# )

$mainProject = "ConsoleApp"
$maincsproj = "ConsoleApp.csproj"
$dll = $maincsproj.Replace('csproj','dll')
# trying to unify(-_-) the .net output/variable dependencies seems prone to issues
# using the `msbuild -r -p` to set the output dll name:
# https://github.com/dotnet/msbuild/issues/4696
# so we must pass explicitly .csproj name
# and it'll also be our entry dll name, unless csproj specified:
# <AssemblyName>Your.Project.Foo</AssemblyName>
# but this can be propogated from environment variables during build:
# <AssemblyName>$(SomeEnvironmentVariable)</AssemblyName> --- tested on linux+Windows
# added docker file and some test projects to on






$csprojFiles = gci . -Filter *.csproj -Recurse
$dockerFile = @"
FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

"@

$copyLine = @"
COPY ["{{filepath}}","{{fileDest}}"]

"@

$secondCopyLine = @"
COPY ["{{fileDest}}","{{fileDest}}"]

"@

$spaceLine = @"


"@

$content = @"
WORKDIR "/app/$($mainProject)"
RUN dotnet build "$($maincsproj)" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "$($maincsproj)" --no-restore -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "$($dll)"]
"@

foreach($csproj in $csprojFiles){
$currentPath = (pwd).Path
$fullname = $csproj.fullname.replace($currentPath+'\','').replace('\','/')
$dest = $fullname.Substring(0,$fullname.IndexOf('/'))
$line = $copyLine -replace "{{filepath}}",$fullname -replace '{{fileDest}}',($dest+'/')
$dockerFile+= $line 
}

$dockerFile+=$spaceLine

foreach($csproj in $csprojFiles){
$currentPath = (pwd).Path
$fullname = $csproj.fullname.replace($currentPath+'\','').replace('\','/')
$dest = $fullname.Substring(0,$fullname.IndexOf('/'))
$secondLine = $secondCopyLine -replace '{{fileDest}}',($dest+'/')
$dockerFile+=$secondLine
}

$dockerFile+=$spaceLine
$dockerFile+= $content

$dockerFile | Out-File -Encoding utf8 -FilePath "Dockerfile" -Force
