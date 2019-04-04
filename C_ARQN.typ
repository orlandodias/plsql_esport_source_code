CREATE OR REPLACE TYPE C_ARQN AS OBJECT
----------------------------------------------------------------------------------
-- ARQUIVOS TEXTO
----------------------------------------------------------------------------------
-- PROPRIEDADES
----------------------------------------------------------------------------------
(id         INTEGER,
 dataType   INTEGER,
 nmDir      VARCHAR2(250),    -- PASTA OU DIRETORIO DO ARQUIVO
 nmArq      VARCHAR2(250),    -- NOME DO ARQUIVO (INCLUINDO EXTENSAO)
 tpArq      VARCHAR2(001),    -- TIPO DO ARQUIVO: R->LEITURA, W->GRAVACAO
 nuTamReg   INTEGER,          -- TAMANHO MAXIMO DO REGISTRO
 nuLin      INTEGER,          -- NUMERO DA LINHA A SER LIDA OU GRAVADA
 deLin      VARCHAR2(32767),  -- LINHA A SER LIDA OU GRAVADA

----------------------------------------------------------------------------------
-- CONSTRUTOR SIMPLES
----------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION C_ARQN
RETURN SELF AS RESULT,

----------------------------------------------------------------------------------
-- CONSTRUTOR COMPLETO
----------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2,
 tpArq     VARCHAR2,
 nuTamReg  INTEGER)
RETURN SELF AS RESULT,

----------------------------------------------------------------------------------
-- DEFINE UM ARQUIVO COM TAMANHO DE 2000 BYTES
----------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2,
 tpArq     VARCHAR2)
RETURN SELF AS RESULT,

----------------------------------------------------------------------------------
-- DEFINE UM ARQUIVO DE LEITURA COM TAMANHO DE 2000 BYTES
----------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2)
RETURN SELF AS RESULT,

----------------------------------------------------------------------------------
-- METODOS
----------------------------------------------------------------------------------
MEMBER PROCEDURE abre_nchar,

MEMBER PROCEDURE abre,

MEMBER PROCEDURE le_nchar
(s_linha OUT VARCHAR2),

MEMBER PROCEDURE le
(s_linha OUT VARCHAR2),

MEMBER PROCEDURE le_nchar,

MEMBER PROCEDURE le,

MEMBER PROCEDURE grava_nchar
(e_linha IN VARCHAR2),

MEMBER PROCEDURE grava
(e_linha IN VARCHAR2),

MEMBER PROCEDURE grava_nchar,

MEMBER PROCEDURE grava,

MEMBER PROCEDURE fecha
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY C_ARQN AS
----------------------------------------------------------------------------------
-- CONSTRUTORES
----------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION C_ARQN
RETURN SELF AS RESULT
AS
BEGIN
    SELF.nmDir := NULL;
    SELF.nmArq := NULL;
    SELF.tpArq := NULL;
    SELF.nuTamReg := NULL;
    SELF.nuLin := 0;
    RETURN;
END;

CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2,
 tpArq     VARCHAR2,
 nuTamReg  INTEGER)
RETURN SELF AS RESULT
AS
BEGIN
    SELF.nmDir := nmDir;
    --SELF.nmArq := LOWER(nmArq);
    SELF.nmArq := nmArq;
    SELF.tpArq := tpArq;
    SELF.nuTamReg := nuTamReg;
    SELF.nuLin := 0;
    RETURN;
END;

CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2,
 tpArq     VARCHAR2)
RETURN SELF AS RESULT
AS
BEGIN
    SELF.nmDir := nmDir;
    --SELF.nmArq := LOWER(nmArq);
    SELF.nmArq := nmArq;
    SELF.tpArq := tpArq;
    SELF.nuTamReg := 2000;
    SELF.nuLin := 0;
    RETURN;
END;

CONSTRUCTOR FUNCTION C_ARQN
(nmDir     VARCHAR2,
 nmArq     VARCHAR2)
RETURN SELF AS RESULT
AS
BEGIN
    SELF.nmDir := nmDir;
    --SELF.nmArq := LOWER(nmArq);
    SELF.nmArq := nmArq;
    SELF.tpArq := 'R';
    SELF.nuTamReg := 2000;
    SELF.nuLin := 0;
    RETURN;
END;

----------------------------------------------------------------------------------
-- ABRE ARQUIVO SEQUENCIAL COM SUPORTE A CARACTERES INTERNACIONAIS (CHARSET)
----------------------------------------------------------------------------------
MEMBER PROCEDURE abre_nchar
IS
 ARQUIVO     SYS.UTL_FILE.FILE_TYPE;
 v_deMsgErro VARCHAR2(250);
BEGIN
   BEGIN
      ARQUIVO := SYS.UTL_FILE.FOPEN_NCHAR(SELF.nmDir, SELF.nmArq, SELF.tpArq, SELF.nuTamReg);
      SELF.id := ARQUIVO.id;
      SELF.dataType := ARQUIVO.dataType;
      SELF.nuLin := 0;
   EXCEPTION
      WHEN SYS.UTL_FILE.INVALID_PATH THEN
         v_deMsgErro := 'Caminho (' || SELF.nmDir
                     || ') ou Nome do arquivo ('
                     || SELF.nmArq || ') invalido';
         RAISE_APPLICATION_ERROR(-20305,v_deMsgErro);
   END;
END;

----------------------------------------------------------------------------------
-- ABRE ARQUIVO SEQUENCIAL
----------------------------------------------------------------------------------
MEMBER PROCEDURE abre
IS
 ARQUIVO     SYS.UTL_FILE.FILE_TYPE;
 v_deMsgErro VARCHAR2(250);
BEGIN
   BEGIN
      ARQUIVO := SYS.UTL_FILE.FOPEN(SELF.nmDir, SELF.nmArq, SELF.tpArq, SELF.nuTamReg);
      SELF.id := ARQUIVO.id;
      SELF.dataType := ARQUIVO.dataType;
      SELF.nuLin := 0;
   EXCEPTION
      WHEN SYS.UTL_FILE.INVALID_PATH THEN
         v_deMsgErro := 'Caminho (' || SELF.nmDir
                     || ') ou Nome do arquivo ('
                     || SELF.nmArq || ') invalido';
         RAISE_APPLICATION_ERROR(-20305,v_deMsgErro);
   END;
END;

MEMBER PROCEDURE le
IS
 ARQUIVO    SYS.UTL_FILE.FILE_TYPE;
BEGIN
   ARQUIVO.id := SELF.id;
   ARQUIVO.dataType := SELF.dataType;
   SYS.UTL_FILE.GET_LINE(ARQUIVO, SELF.deLin);
   SELF.nuLin := SELF.nuLin + 1;
END;

MEMBER PROCEDURE le_nchar
IS
 ARQUIVO    SYS.UTL_FILE.FILE_TYPE;
BEGIN
   ARQUIVO.id := SELF.id;
   ARQUIVO.dataType := SELF.dataType;
   SYS.UTL_FILE.GET_LINE_NCHAR(ARQUIVO, SELF.deLin);
   SELF.nuLin := SELF.nuLin + 1;
END;

MEMBER PROCEDURE le_nchar
(s_linha OUT VARCHAR2)
IS
BEGIN
   SELF.le_nchar;
   s_linha := SELF.deLin;
END;

MEMBER PROCEDURE le
(s_linha OUT VARCHAR2)
IS
BEGIN
   SELF.le;
   s_linha := SELF.deLin;
END;

MEMBER PROCEDURE grava_nchar
IS
 ARQUIVO    SYS.UTL_FILE.FILE_TYPE;
BEGIN
   ARQUIVO.id       := SELF.ID;
   ARQUIVO.dataType := SELF.dataType;
   SYS.UTL_FILE.PUT_LINE_NCHAR(ARQUIVO, SELF.deLin);
   SELF.nuLin := SELF.nuLin + 1;
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20225, sqlerrm);
END;

MEMBER PROCEDURE grava
IS
 ARQUIVO    SYS.UTL_FILE.FILE_TYPE;
BEGIN
   ARQUIVO.id       := SELF.ID;
   ARQUIVO.dataType := SELF.dataType;
   SYS.UTL_FILE.PUT_LINE(ARQUIVO, SELF.deLin);
   SELF.nuLin := SELF.nuLin + 1;
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20225, sqlerrm);
END;

MEMBER PROCEDURE grava
(e_linha IN VARCHAR2)
IS
BEGIN
   SELF.deLin := e_linha;
   SELF.grava;
END;

MEMBER PROCEDURE grava_nchar
(e_linha IN VARCHAR2)
IS
BEGIN
   SELF.deLin := e_linha;
   SELF.grava_nchar;
END;

MEMBER PROCEDURE fecha
IS
 ARQUIVO    SYS.UTL_FILE.FILE_TYPE;
BEGIN
   ARQUIVO.id       := SELF.ID;
   ARQUIVO.dataType := SELF.dataType;
   SYS.UTL_FILE.FCLOSE(ARQUIVO);
END;

END;
/
