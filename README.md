# dockerfile-generator
generates dockerfile with relevant references for .NET CORE applictaions

run the powershell script from the relevant project's folder path.
this script will generate a basic dockerfile with all of the project's dependencies.

please notice you'll need to provide 3 parameters: \
'mainProject': this will be the main project that the application is executing\
'maindll': the main dll that the application should use \
'maincsproj': the main csproj file that the application should use

