# ======================================================================================
#       _   ______________   _____________   ____________  ___  __________  ____ 
#      / | / / ____/_  __/  / ____/ ____/ | / / ____/ __ \/   |/_  __/ __ \/ __ \
#     /  |/ / __/   / /    / / __/ __/ /  |/ / __/ / /_/ / /| | / / / / / / /_/ /
#  _ / /|  / /___  / /    / /_/ / /___/ /|  / /___/ _, _/ ___ |/ / / /_/ / _, _/ 
# (_)_/ |_/_____/ /_/     \____/_____/_/ |_/_____/_/ |_/_/  |_/_/  \____/_/ |_|  
#                                                                               
# ======================================================================================

# ------------------------
# POWERSHELL INTRODUCTION
# ------------------------

Write-Host ''
Write-Host ''
Write-Host '/-------------------------\'
Write-Host '|                         |'
Write-Host '| .NET GENERATOR SCRIPT   |'
Write-Host '|                         |'
Write-Host '\-------------------------/'
Write-Host ''
Write-Host ''

# ---------------------------
# GENERATION OF THE SOLUTION 
# ---------------------------

Write-Host 'CREATING SOLUTION OF THE PROJECT' -ForegroundColor Green
Write-Host ''
Write-Host ''
Write-Host 'Enter the Solution name (Ex: SolutionExample): '
$solutionName = Read-Host '> '

mkdir $solutionName # create the folder of the solution.
cd $solutionName # enter into the folder of the solution.
dotnet new sln --name $solutionName # create the solution file.

# ---------------------------
# GENERATION OF THE PROJECT
# ---------------------------

Write-Host 'CREATING PROJECT OF THE SOLUTION' -ForegroundColor Blue
Write-Host ''
Write-Host ''
Write-Host 'Enter the Project name (Ex: ProjectExample): '
$projectName = Read-Host '> '
dotnet new console -o $projectName # create the project on the Solution folder.

# --------------------------------
# GENERATION OF THE TEST PROJECT
# --------------------------------

Write-Host 'CREATING TEST PROJECT OF THE SOLUTION' -ForegroundColor Yellow
Write-Host ''
Write-Host ''
$testProjectName = $projectName + 'Tests'
dotnet new mstest -o $testProjectName # create the test project on the Solution folder.

# --------------------------------------------
# CONFIGURING THE PROJECTS INTO THE SOLUTION
# --------------------------------------------

Write-Host 'CONFIGURING THE PROJECTS INTO THE SOLUTION' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
dotnet sln add $projectName/$projectName.csproj # add the project into the solution.
dotnet sln add $testProjectName/$testProjectName.csproj # add the test project into the solution.

# ----------------------------------------------
# CONFIGURING THE PROJECT INTO THE TEST PROJECT
# ----------------------------------------------

Write-Host ''
Write-Host ''
Write-Host 'CONFIGURING THE PROJECT INTO THE TEST PROJECT' -ForegroundColor Magenta
Write-Host ''
Write-Host ''
dotnet add $testProjectName/$testProjectName.csproj reference $projectName/$projectName.csproj # add the project reference into the test project.

# ------------------------------------
# GENERATION OF THE HELLO WORLD CODE
# ------------------------------------

Write-Host ''
Write-Host ''
Write-Host 'ADDING TEMPLATE CODE INTO THE PROJECT' -ForegroundColor DarkYellow
Write-Host ''
Write-Host ''
$code = @"
namespace $projectName
{
    public class Program
    {
      public static string GetHelloWorld()
      {
          return `"Hello World!`";
      }

      public static void Main(string[] args)
      {
          string test = GetHelloWorld();
          Console.WriteLine(test);
      }
    }
}
"@

$code | Out-File -FilePath $projectName/Program.cs

# -----------------------------
# GENERATION OF THE TEST CODE
# -----------------------------

Write-Host 'ADDING TEMPLATE TESTS INTO THE TEST PROJECT' -ForegroundColor DarkYellow
Write-Host ''
Write-Host ''
$testCode = @"
using Microsoft.VisualStudio.TestTools.UnitTesting;
using $projectName;

namespace $testProjectName;

[TestClass]
public class UnitTest1
{
    [TestMethod]
    public void TestHelloWorld()
    {
        // Arrange
        //Program program = new Program();
        
        // Act
        string result = Program.GetHelloWorld();

        // Assert
        Assert.AreEqual("Hello World!", result);
    }
}
"@

$testCode | Out-File -FilePath $testProjectName/UnitTest1.cs

# ---------------------------------------
# TESTING THE PROJECT USING RUN COMMAND
# ---------------------------------------

Write-Host 'RUNNING THE PROJECT' -ForegroundColor Red
Write-Host ''
Write-Host ''
$projectCsproj = $projectName + '.csproj'
dotnet run --project $projectName/$projectCsproj

# ---------------------------------------
# TESTING THE TESTS USING TEST COMMAND
# ---------------------------------------

Write-Host ''
Write-Host ''
Write-Host 'RUNNING THE TESTS' -ForegroundColor Red
Write-Host ''
Write-Host ''
$testProjectCsproj = $testProjectName + '.csproj'
dotnet test $testProjectName/$testProjectCsproj

# -----------------------------------------------
# CREATING DOCKER FILE AND COMPOSE CONFIGURATION
# -----------------------------------------------

Write-Host ''
Write-Host ''
Write-Host 'CREATING DOCKER FILE AND COMPOSE CONFIGURATION' -ForegroundColor Magenta
Write-Host ''
Write-Host ''

dotnet publish -c Release # publish the project to use the dockerfile.

$dockercreation = @"
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["$projectName/$projectName.csproj", "$projectName/"]
RUN dotnet restore "$projectName/$projectName.csproj"
COPY . .
WORKDIR "/src/$projectName"
RUN dotnet build "$projectName.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "$projectName.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "$projectName.dll"]

"@

$dockercreation | Out-File -FilePath Dockerfile # create the dockerfile.

cd..

$dockercompose = @"
version: '3.4'
services:
  project:
    image: $projectName
    build:
      context: .
      dockerfile: $projectName/Dockerfile
"@

$dockercompose | Out-File -FilePath docker-compose.yml # create the docker-compose file.

$dockerignore = @"
**/.classpath
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/bin
**/charts
**/docker-compose*
**/compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
LICENSE
README.md
"@

$dockerignore | Out-File -FilePath .dockerignore # create the dockerignore file.

# -------------------------
# GITIGNORE FILE CREATION
# -------------------------

Write-Host ''
Write-Host ''
Write-Host 'CREATING GITIGNORE FILE' -ForegroundColor White
Write-Host ''
Write-Host ''

$gitignore = @"
## Ignore Visual Studio temporary files, build results, and
## files generated by popular Visual Studio add-ons.

# User-specific files
*.suo
*.user
*.userosscache
*.sln.docstates

# User-specific files (MonoDevelop/Xamarin Studio)
*.userprefs

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
x64/
x86/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/

# Visual Studio 2015 cache/options directory
.vs/

# MSTest test Results
[Tt]est [Rr]esult*/
[Bb]uild [Ll]og.*

# NUNIT
*.VisualState.xml
TestResult.xml

# .NET Core
project.lock.json
project.fragment.lock.json
artifacts/
**/Properties/launchSettings.json

# VS Code
.vscode/

# Others
*_i.c
*_p.c
*_i.h
*.ilk
*.meta
*.obj
*.pch
*.pdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*.log
*.vspscc
*.vssscc
*.builds
*.pidb
*.svclog
*.scc

# Chutzpah Test files
_Chutzpah*

# Visual C++ cache files
ipch/
*.aps
*.ncb
*.opendb
*.opensdf
*.sdf
*.cachefile
*.VC.db
*.VC.VC.opendb

# Visual Studio profiler
*.psess
*.vsp
*.vspx
*.sap

# TFS 2012 Local Workspace
$tf/

# Guidance Automation Toolkit
*.gpState

# ReSharper is a .NET coding add-in
_ReSharper*/
*. [Rr]e [Ss]harper
*.DotSettings.user

# JustCode is a .NET coding add-in
.JustCode

# TeamCity is a build add-in
_TeamCity*

# DotCover is a Code Coverage Tool
*.dotCover

# Visual Studio code coverage results
*.coverage
*.coveragexml

# NCrunch
_NCrunch_*
.*crunch*.local.xml
nCrunchTemp_*

# MightyMoose
*.mm.*
AutoTest.Net/

# Web workbench (sass)
.sass-cache/

# Installshield output folder
[Ee]xpress/

# DocProject is a documentation generator add-in
DocProject/buildhelp/
DocProject/Help/*.HxT
DocProject/Help/*.HxC
DocProject/Help/*.hhc
DocProject/Help/*.hhk
DocProject/Help/*.hhp
DocProject/Help/Html2
DocProject/Help/html

# Click-Once directory
publish/

# Publish Web Output
*. [Pp]ublish.xml
*.azurePubxml
# TODO: Comment the next line if you want to checkin your web deploy settings
# but database connection strings (with potential passwords) will be unencrypted
*.pubxml
*.publishproj

# Microsoft Azure Web App publish settings. Comment the next line if you want to
# checkin your Azure Web App publish settings, but sensitive information contained
# in these scripts will be unencrypted
PublishScripts/

# NuGet Packages
*.nupkg
# The packages folder can be ignored because of Package Restore
**/packages/*
# except build/, which is used as an MSBuild target.
!**/packages/build/
# Uncomment if necessary however generally it will be regenerated when needed
#!**/packages/repositories.config

# NuGet v3's project.json files produces more ignorable files
*.nuget.props
*.nuget.targets

# Microsoft Azure Build Output
csx/
*.build.csdef

# Microsoft Azure Emulator
ecf/
rcf/

# Windows Store app package directories and files
AppPackages/
BundleArtifacts/
Package.StoreAssociation.xml
_pkginfo.txt

# Visual Studio cache files
# files ending in .cache can be ignored
*.cache

"@

$gitignore | Out-File -FilePath .gitignore


# --------------------------
# GITHUB WORKFLOW CREATION
# --------------------------

Write-Host ''
Write-Host ''
Write-Host 'CREATING GITHUB WORKFLOW' -ForegroundColor White
Write-Host ''
Write-Host ''
cd .\.github\workflows\

$workflowScript = @"
name: $projectName - Testing Results

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]  

jobs:

  build:

    runs-on: windows-latest  # For a list of available runner types, refer to
                             # https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on

    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    # Install the .NET Core workload
    - name: Install .NET Core
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 8.0.x

    # Add  MSBuild to the PATH: https://github.com/microsoft/setup-msbuild
    - name: Setup MSBuild.exe
      uses: microsoft/setup-msbuild@v2

    # Execute all unit tests in the solution
    - name: Execute Unit Tests
      run: dotnet test --nologo --logger "console;verbosity=detailed" .\$solutionName\$testProjectName\$testProjectCsproj
"@

$projectNameYml = $projectName + '.yml'
$workflowScript | Out-File -FilePath $projectNameYml

# ----------------------------------
# COMPLETED AND BACK TO ROOT FOLDER
# ----------------------------------

Write-Host ''
Write-Host ''
Write-Host 'PROJECT CREATION COMPLETE! HAPPY CODING!!!'
Write-Host 'Script generated by: F4NT0 - rate me at https://github.com/F4NT0/CSharp-Template'

cd..
cd..