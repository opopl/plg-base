
@echo off

set Bin=%~dp0

call vars_perl_c_strawberry.bat
perl %Bin%\install_deps.pl %*
