CREATE OR REPLACE PACKAGE PKG_EXPORT_SOURCE_CODE AS
 K_CAMINHO                      CONSTANT VARCHAR2(200) := 'C:/home/netwin/migra_inventario';

 TYP_PACKAGE_BODY               CONSTANT VARCHAR2(30) := 'PACKAGE BODY';
 TYP_PACKAGE                    CONSTANT VARCHAR2(30) := 'PACKAGE';
 TYP_TYPE_BODY                  CONSTANT VARCHAR2(30) := 'TYPE BODY';
 TYP_TYPE                       CONSTANT VARCHAR2(30) := 'TYPE';
 TYP_PROCEDURE                  CONSTANT VARCHAR2(30) := 'PROCEDURE';
 TYP_FUNCTION                   CONSTANT VARCHAR2(30) := 'FUNCTION';
 TYP_UNKNOWN                    CONSTANT VARCHAR2(30) := 'XXX';

 FLD_PACKAGE_BODY               CONSTANT VARCHAR2(30) := 'PKB';
 FLD_PACKAGE                    CONSTANT VARCHAR2(30) := 'PKS';
 FLD_TYPE_BODY                  CONSTANT VARCHAR2(30) := 'TYB';
 FLD_TYPE                       CONSTANT VARCHAR2(30) := 'TYH';
 FLD_PROCEDURE                  CONSTANT VARCHAR2(30) := 'PRC';
 FLD_FUNCTION                   CONSTANT VARCHAR2(30) := 'FUNC';
 FLD_UNKNOWN                    CONSTANT VARCHAR2(30) := 'XXX';

 EXT_PACKAGE_BODY               CONSTANT VARCHAR2(30) := '.pkb';
 EXT_PACKAGE                    CONSTANT VARCHAR2(30) := '.pks';
 EXT_TYPE_BODY                  CONSTANT VARCHAR2(30) := '.tyb';
 EXT_TYPE                       CONSTANT VARCHAR2(30) := '.tyh';
 EXT_PROCEDURE                  CONSTANT VARCHAR2(30) := '.prc';
 EXT_FUNCTION                   CONSTANT VARCHAR2(30) := '.fnc';
 EXT_UNKNOWN                    CONSTANT VARCHAR2(30) := '.XXX';
 EXT_SQL                        CONSTANT VARCHAR2(30) := '.sql';

 SINGLE_FILE_NAME               CONSTANT VARCHAR2(30) := 'source_';
 CREATE_OR_REPLACE              CONSTANT VARCHAR2(30) := 'CREATE OR REPLACE ';

PROCEDURE GEN_ALL_MULTIPLE_FILES
(e_caminho IN VARCHAR2);

PROCEDURE GEN_ALL_SINGLE_FILE
(e_caminho IN VARCHAR2);

PROCEDURE GEN_FILE
(e_caminho IN VARCHAR2,
 e_type    IN VARCHAR2,
 e_name    IN VARCHAR2);

END PKG_EXPORT_SOURCE_CODE;
/
CREATE OR REPLACE PACKAGE BODY PKG_EXPORT_SOURCE_CODE AS

FUNCTION getFolderName
(e_type IN VARCHAR2)
RETURN VARCHAR2
IS
 v_result VARCHAR2(30);
BEGIN
   IF UPPER(e_type) = TYP_PACKAGE_BODY THEN
      v_result := FLD_PACKAGE_BODY;
   ELSIF UPPER(e_type) = TYP_PACKAGE THEN
      v_result := FLD_PACKAGE;
   ELSIF UPPER(e_type) = TYP_TYPE THEN
      v_result := FLD_TYPE;
   ELSIF UPPER(e_type) = TYP_TYPE_BODY THEN
      v_result := FLD_TYPE_BODY;
   ELSIF UPPER(e_type) = TYP_PACKAGE_BODY THEN
      v_result := FLD_TYPE;
   ELSIF UPPER(e_type) = TYP_FUNCTION THEN
      v_result := FLD_FUNCTION;
   ELSIF UPPER(e_type) = TYP_PROCEDURE THEN
      v_result := FLD_PROCEDURE;
   ELSE
      v_result := FLD_UNKNOWN;
   END IF;
   RETURN v_result;
END;

FUNCTION getExtensionName
(e_type IN VARCHAR2)
RETURN VARCHAR2
IS
 v_result VARCHAR2(30);
BEGIN
   IF UPPER(e_type) = TYP_PACKAGE_BODY THEN
      v_result := EXT_PACKAGE_BODY;
   ELSIF UPPER(e_type) = TYP_PACKAGE THEN
      v_result := EXT_PACKAGE;
   ELSIF UPPER(e_type) = TYP_TYPE THEN
      v_result := EXT_TYPE;
   ELSIF UPPER(e_type) = TYP_TYPE_BODY THEN
      v_result := EXT_TYPE_BODY;
   ELSIF UPPER(e_type) = TYP_PACKAGE_BODY THEN
      v_result := EXT_TYPE;
   ELSIF UPPER(e_type) = TYP_FUNCTION THEN
      v_result := EXT_FUNCTION;
   ELSIF UPPER(e_type) = TYP_PROCEDURE THEN
      v_result := EXT_PROCEDURE;
   ELSE
      v_result := EXT_UNKNOWN;
   END IF;
   RETURN v_result;
END;


PROCEDURE getColumnData
(e_owner      IN VARCHAR2,
 e_tableName  IN VARCHAR2,
 e_columnName IN VARCHAR2,
 s_datatype   OUT VARCHAR2,
 s_precision  OUT INTEGER,
 s_dataLength OUT INTEGER,
 s_scale      OUT INTEGER)
IS
BEGIN
   SELECT DATA_TYPE,  DATA_PRECISION, DATA_SCALE, DATA_LENGTH
   INTO   s_datatype, s_precision,    s_scale,    s_dataLength
   FROM   ALL_TAB_COLUMNS
   WHERE  UPPER(OWNER) = UPPER(e_owner)
   AND    UPPER(TABLE_NAME) = UPPER(e_tableName)
   AND    UPPER(COLUMN_NAME) = UPPER(e_columnName);
END;

PROCEDURE GEN_FILE
(e_caminho IN VARCHAR2,
 e_type    IN VARCHAR2,
 e_name    IN VARCHAR2)
IS
 CURSOR C_SRC IS
    SELECT LINE,TEXT
    FROM   USER_SOURCE
    WHERE  UPPER(NAME) = UPPER(e_name)
    AND    TYPE = e_type
    ORDER BY LINE;

 o_arq              C_ARQN;
 v_extension        VARCHAR2(30);
BEGIN
    v_extension := getFolderName(e_type);
    o_arq := C_ARQN(nmDir => NVL(e_caminho, K_CAMINHO) || '/' || v_extension,
                    nmArq => LOWER(e_name) || '.' || EXT_SQL,
                    tpArq => 'w',
                    nuTamReg => 32000);
    o_arq.ABRE;

    o_arq.grava(CREATE_OR_REPLACE);

    FOR R_SRC IN C_SRC LOOP
       o_arq.grava(F_CHOMP(R_SRC.TEXT));
    END LOOP;

    o_arq.grava('/');
    o_arq.grava('SHOW ERRORS;');


    o_arq.fecha;
EXCEPTION
    WHEN OTHERS THEN
       BEGIN
          o_arq.fecha;
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
END;

PROCEDURE GEN_FILE
(e_type    IN VARCHAR2,
 e_name    IN VARCHAR2,
 m_arq     IN OUT NOCOPY C_ARQN)
IS
 CURSOR C_SRC IS
    SELECT LINE,TEXT
    FROM   USER_SOURCE
    WHERE  UPPER(NAME) = UPPER(e_name)
    AND    TYPE = e_type
    ORDER BY LINE;
BEGIN
   m_arq.grava(CREATE_OR_REPLACE);

   FOR R_SRC IN C_SRC LOOP
      m_arq.grava(F_CHOMP(R_SRC.TEXT));
   END LOOP;

   m_arq.grava('/');
   m_arq.grava('SHOW ERRORS;');
END;

PROCEDURE GEN_ALL_MULTIPLE_FILES_SJOB
(e_caminho IN VARCHAR2)
IS
 CURSOR C_TYPE IS
    SELECT TYPE
    FROM   USER_SOURCE
    WHERE  LINE = 1
    ORDER BY TYPE;

 CURSOR C_PRC (XTYPE VARCHAR2) IS
    SELECT NAME
    FROM   USER_SOURCE
    WHERE  LINE = 1
    AND    TYPE = XTYPE
    ORDER BY NAME,TYPE;
BEGIN
    FOR R_TYP IN C_TYPE LOOP
       FOR R_PRC IN C_PRC(R_TYP.TYPE) LOOP
          GEN_FILE(e_caminho => e_caminho,
                   e_type => R_TYP.TYPE,
                   e_name => R_PRC.NAME);
       END LOOP;
    END LOOP;
END;


PROCEDURE GEN_ALL_MULTIPLE_FILES
(e_caminho IN VARCHAR2)
IS
 CURSOR C_TYPE IS
    SELECT TYPE
    FROM   USER_SOURCE
    WHERE  LINE = 1
    ORDER BY TYPE;

 CURSOR C_PRC (XTYPE VARCHAR2) IS
    SELECT NAME
    FROM   USER_SOURCE
    WHERE  LINE = 1
    AND    TYPE = XTYPE
    ORDER BY NAME,TYPE;

 v_sql         VARCHAR2(2000);
 v_jobNum      BINARY_INTEGER;
BEGIN
    FOR R_TYP IN C_TYPE LOOP
       FOR R_PRC IN C_PRC(R_TYP.TYPE) LOOP
          v_sql := 'BEGIN PKG_EXPORT_SOURCE_CODE.GEN_FILE(e_caminho => '''
                || e_caminho        || ''', e_type => '''
                || TRIM(R_TYP.TYPE) || ''', e_name => '''
                || TRIM(R_PRC.NAME) || '''); END;';

          DBMS_JOB.SUBMIT(v_jobNum, v_sql, SYSDATE, NULL, FALSE);
          COMMIT;
       END LOOP;
    END LOOP;
END;


PROCEDURE GEN_ALL_SINGLE_FILE
(e_caminho IN VARCHAR2)
IS
 CURSOR C_PRC IS
    SELECT NAME,TYPE
    FROM   USER_SOURCE
    WHERE  LINE = 1
    ORDER BY NAME,TYPE;

 o_arq              C_ARQN;
BEGIN
   o_arq := C_ARQN(nmDir => NVL(e_caminho, K_CAMINHO),
                   nmArq => 'fontes_' || TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') || '.sql',
                   tpArq => 'w',
                   nuTamReg => 32000);
   o_arq.ABRE;

   FOR R_PRC IN C_PRC LOOP
      GEN_FILE(e_type => R_PRC.type,
               e_name => R_PRC.NAME,
               m_arq => o_arq);
   END LOOP;

   o_arq.fecha;
EXCEPTION
   WHEN OTHERS THEN
      BEGIN
         o_arq.fecha;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
END;

END PKG_EXPORT_SOURCE_CODE;
/
