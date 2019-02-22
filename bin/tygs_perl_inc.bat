

set tygs_dir=%userprofile%\tygs\
set db_dir=%userprofile%\db\

md %tygs_dir% if not exist %tygs_dir%
md %db_dir% if not exist %db_dir%

set tygs=%tygs_dir%\perl_inc.tygs
set db=%db_dir%\tygs_perl_inc.sqlite

set cmd=ty.bat --inc --db "%db%" --tfile "%tygs%"

cmd /c "%cmd%"
