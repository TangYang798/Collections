@echo off
:: variable delay
setlocal enabledelayedexpansion
:: to file location
cd /d %~dp0
call mvn -q clean
mkdir target
if "%1" == "" (
   echo "build and pack changed things. dependencies are not included."
   echo "----- in eclipse, right click this file: Show in Local Terminal, then Terminal -----"
   echo "usage: .\build.bat [args]"
   echo "  eg: .\build.bat equals to .\build.bat HEAD..HEAD~   (default latest changes)"
   echo "      .\build.bat c223ae04 c48ab067 equals to .\build.bat c223ae04..c223ae04~ c48ab067..c48ab067~   (changes of input commits, be ware of windows args limit)"
   echo "      .\build.bat c223ae04..c48ab067 2ef43335 equals to .\build.bat c223ae04..c48ab067 2ef43335..2ef43335~    (changes between c223ae04 and c48ab067, and 2ef43335)"
   echo "----- default for latest change -----"
   git diff --name-status HEAD HEAD~ | grep -E '^[M,A].*src' | cut -f 2 >> target/files.txt
   git diff --name-status HEAD HEAD~ | grep -E '^[R].*src' | cut -f 3 >> target/files.txt
) else ( 
   for %%a in (%*) do (
    (
      echo %%a | find ".." > NUL
    ) && (
      git diff --name-status %%a | grep -E '^[M,A].*src' | cut -f 2 >> target/files.txt
      git diff --name-status %%a | grep -E '^[R].*src' | cut -f 3 >> target/files.txt
    ) || (
      git diff --name-status %%a %%a~ | grep -E '^[M,A].*src' | cut -f 2 >> target/files.txt
      git diff --name-status %%a %%a~ | grep -E '^[R].*src' | cut -f 3 >> target/files.txt
    )
   )
)
echo files.txt >> target/files.txt

:: find first artifactId in pom.xml
for /f "tokens=*" %%i in (
   'findstr "<artifactId>.*</artifactId>" pom.xml'
) do (
   set "s=%%i"
   goto outa
)

:outa
set "s=%s:"=''%"
for /f "delims=<" %%j in (
   "%s:*<artifactId>=%"
) do (
   set "artifactId=%%j"
)


set "artifactId=%artifactId:''="%"
:: find first version in pom.xml
for /f "tokens=*" %%i in (
   'findstr "<version>.*</version>" pom.xml'
) do (
   set "s=%%i"
   goto outb
)

:outb
set "s=%s:"=''%"
for /f "delims=<" %%j in (
   "%s:*<version>=%"
) do (
   set "version=%%j"
)
set "version=%version:''="%"
:: maven package name
set packname=%artifactId%-%version%

:: command window will exit when using mvn command directly.
call mvn package -DskipTests -q
cd target

:: get file location and pack them
cat files.txt | sed -e 's_\\.java_\\*.class_' -e 's_src/main/resources_%packname%/WEB-INF/classes_' -e 's_src/main/java_%packname%/WEB-INF/classes_' -e 's_src/main/webapp_%packname%_' | xargs tar rf %packname%.tar
echo package: %packname%.tar
start explorer .
exit 0
