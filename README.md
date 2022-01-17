# dockerfile-generator
generates a dockerfile with relevant references for .NET CORE applictaions

run the powershell script from the relevant project's folder path.
this script will generate a basic dockerfile with all of the project's dependencies.

please notice you'll need to provide 3 parameters: \
'mainProject': this will be the main project that the application is executing\
'maindll': the main dll that the application should use \
'maincsproj': the main csproj file that the application should use

to create a multi project dependency build:
```
dotnet new console -n ConsoleApp
dotnet new classlib -n SomeIntefrace
dotnet new classlib -n SomeLibrary
dotnet add ConsoleApp reference SomeIntefrace
dotnet add ConsoleApp reference SomeLibrary

```
same folder, powershell:
```
.\generate_dockerfile_with_dependencies.ps1

docker build . -t test:auto
docker run test:auto
```

