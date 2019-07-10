# plsql_esport_source_code
Com um usuário DBA comande: 
GRANT EXECUTE ON SYS.DBMS_JOB to seu usuário;
ALTER SYSTEM SET UTL_FILE_DIR='*' SCOPE=SPFILE;
Reinicie o ORACLE.
Voce pode alternativamente criar um diretório com o comando CREATE DIRECTORY e conceder acesso de leitura e gravção para ele.

With a DBA user, execute:
GRANT EXECUTE ON SYS.DBMS_JOB to your user;
ALTER SYSTEM SET UTL_FILE_DIR='*' SCOPE=SPFILE;
Restart the ORACLE Server.
Or you can create a directory with CREATE DIRECTORY COMMAND and grant it read and write access.
