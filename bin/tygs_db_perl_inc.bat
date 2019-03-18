
@echo off

set tygs_dir=%userprofile%\tygs\
set db_dir=%userprofile%\db\

REM md %tygs_dir% if not exist "%tygs_dir%"
REM md %db_dir% if not exist "%db_dir%"

md %tygs_dir%
md %db_dir%

set tygs=%tygs_dir%\perl_inc.tygs
set db=%db_dir%\tygs_perl_inc.sqlite

set opts=
set opts=%opts% --inc --db "%db%" --tfile "%tygs%" --action generate_from_db
set opts=%opts% --files_limit 100
REM set opts=%opts% --redo

set cmd=ty.bat %opts%

cmd /c "%cmd%"
