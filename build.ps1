


mkdir ./temp | out-null

#TODO: Work out if this is the right thing to do or if we should just bake one in. I suspect we need to download it and need a reasonable way to pick the right branch.
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dotnet/cli/release/2.0.0/scripts/obtain/dotnet-install.ps1" -outfile "./temp/dotnet-install.ps1"

$version = Invoke-WebRequest "https://dotnetcli.blob.core.windows.net/dotnet/Sdk/release/2.0.0/latest.version" | 
            Select-Object -ExpandProperty Content
$version = $version.Split([Environment]::NewLine) | Select-Object -First 1 -Skip 1
Write-Host("Building package for: $version")

#On Antares we only ever install x86 right now, so by using x86 for this we are more accurately representing what we will
#eventually install.
./temp/dotnet-install.ps1 -version $version -Architecture "x86" -InstallDir ./build/dotnet -NoPath

Copy-Item applicationHost.xdt ./build/applicationHost.xdt
Copy-Item TestDotnetExtension.nuspec ./build/TestDotnetExtension.nuspec

Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -outfile "./temp/nuget.exe"
#nopackageanalysis stops a stream of warnings about dlls being outside the lib directory.
./temp/nuget.exe pack ./build/TestDotnetExtension.nuspec -OutputDirectory ./output -Version $version -nopackageanalysis
Remove-Item -r ./temp
Remove-Item -r ./build
