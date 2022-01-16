
Param(
[Parameter(Mandatory = $True)]
[string]$mainProject,
[Parameter(Mandatory=$True)]
[string]$dll,
[Parameter(Mandatory=$True)]
[string]$maincsproj
)




$csprojFiles = gci . -Filter *.csproj -Recurse
$dockerFile = @"
FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build


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
WORKDIR "/src/$($mainProject)"
RUN dotnet build "$($maincsproj)" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "$($maincsproj)" -c Release -o /app/publish

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

echo $dockerfile
