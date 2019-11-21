CREATE OR REPLACE PACKAGE PKG_EXPORT_SOURCE_CODE AS

 ONLY_ONE_FOLDER                CONSTANT BOOLEAN := TRUE;
 BASE_FOLDER                    CONSTANT VARCHAR2(30) := 'MIGRA_INVENTARIO';
 
 
 TYP_PACKAGE_BODY               CONSTANT VARCHAR2(30) := 'PACKAGE BODY';
 TYP_PACKAGE                    CONSTANT VARCHAR2(30) := 'PACKAGE';
 TYP_TYPE_BODY                  CONSTANT VARCHAR2(30) := 'TYPE BODY';
 TYP_TYPE                       CONSTANT VARCHAR2(30) := 'TYPE';
 TYP_PROCEDURE                  CONSTANT VARCHAR2(30) := 'PROCEDURE';
 TYP_FUNCTION                   CONSTANT VARCHAR2(30) := 'FUNCTION';
 TYP_TRIGGER                    CONSTANT VARCHAR2(30) := 'TRIGGER';
 TYP_UNKNOWN                    CONSTANT VARCHAR2(30) := 'XXX';

 FLD_PACKAGE_BODY               CONSTANT VARCHAR2(30) := 'PKB';
 FLD_PACKAGE                    CONSTANT VARCHAR2(30) := 'PKH';
 FLD_TYPE_BODY                  CONSTANT VARCHAR2(30) := 'TYB';
 FLD_TYPE                       CONSTANT VARCHAR2(30) := 'TYH';
 FLD_PROCEDURE                  CONSTANT VARCHAR2(30) := 'PRC';
 FLD_FUNCTION                   CONSTANT VARCHAR2(30) := 'FUNC';
 FLD_TRIGGER                    CONSTANT VARCHAR2(30) := 'TRG';
 FLD_UNKNOWN                    CONSTANT VARCHAR2(30) := 'XXX';

 EXT_PACKAGE_BODY               CONSTANT VARCHAR2(30) := '.pkb';
 EXT_PACKAGE                    CONSTANT VARCHAR2(30) := '.pkh';
 EXT_TYPE_BODY                  CONSTANT VARCHAR2(30) := '.tyb';
 EXT_TYPE                       CONSTANT VARCHAR2(30) := '.tyh';
 EXT_PROCEDURE                  CONSTANT VARCHAR2(30) := '.prc';
 EXT_FUNCTION                   CONSTANT VARCHAR2(30) := '.fnc';
 EXT_TRIGGER                    CONSTANT VARCHAR2(30) := '.trg';
 EXT_UNKNOWN                    CONSTANT VARCHAR2(30) := '.XXX';
 EXT_SQL                        CONSTANT VARCHAR2(30) := '.sql';

 SINGLE_FILE_NAME               CONSTANT VARCHAR2(30) := 'source_';

 CREATE_OR_REPLACE              CONSTANT VARCHAR2(30) := 'CREATE OR REPLACE ';
 SET_DEFINE_OFF                 CONSTANT VARCHAR2(30) := 'SET DEFINE OFF ';
 SET_DEFINE_ON                  CONSTANT VARCHAR2(30) := 'SET DEFINE ON ';
 SET_ECHO_OFF                   CONSTANT VARCHAR2(30) := 'SET ECHO OFF ';
 SET_ECHO_ON                    CONSTANT VARCHAR2(30) := 'SET ECHO ON ';
 SET_FEEDBACK_OFF               CONSTANT VARCHAR2(30) := 'SET FEEDBACK OFF ';
 SET_FEEDBACK_ON                CONSTANT VARCHAR2(30) := 'SET FEEDBACK ON ';
 SET_HEADING_OFF                CONSTANT VARCHAR2(30) := 'SET HEADING OFF ';
 SET_HEADING_ON                 CONSTANT VARCHAR2(30) := 'SET HEADING ON ';

 SPOOL_ON                       CONSTANT VARCHAR2(30) := 'SPOOL ''#'' ';
 SPOOL_OFF                      CONSTANT VARCHAR2(30) := 'SPOOL OFF ';

PROCEDURE GEN_ALL_MULTIPLE_FILES
(e_caminho IN VARCHAR2);

PROCEDURE GEN_ALL_MULTIPLE_FILES_SJOB
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
   v_result := BASE_FOLDER;
   IF ONLY_ONE_FOLDER = FALSE THEN
      IF UPPER(e_type) = TYP_PACKAGE_BODY THEN
         v_result := v_result || '\' || FLD_PACKAGE_BODY;
      ELSIF UPPER(e_type) = TYP_PACKAGE THEN
         v_result := v_result || '\' || FLD_PACKAGE;
      ELSIF UPPER(e_type) = TYP_TYPE THEN
         v_result := v_result || '\' || FLD_TYPE;
      ELSIF UPPER(e_type) = TYP_TYPE_BODY THEN
         v_result := v_result || '\' || FLD_TYPE_BODY;
      ELSIF UPPER(e_type) = TYP_PACKAGE_BODY THEN
         v_result := v_result || '\' || FLD_TYPE;
      ELSIF UPPER(e_type) = TYP_FUNCTION THEN
         v_result := v_result || '\' || FLD_FUNCTION;
      ELSIF UPPER(e_type) = TYP_PROCEDURE THEN
         v_result := v_result || '\' || FLD_PROCEDURE;
      ELSE
         v_result := v_result || '\' || FLD_UNKNOWN;
      END IF;
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
   ELSIF UPPER(e_type) = TYP_TRIGGER THEN
      v_result := EXT_TRIGGER;
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
    AND    TYPE = UPPER(e_type)
    ORDER BY LINE;

 o_arq              C_ARQN;
 v_extension        VARCHAR2(30);
BEGIN
    v_extension := getExtensionName(e_type);
    o_arq := C_ARQN(nmDir => NVL(TRIM(e_caminho), BASE_FOLDER),
                    nmArq => LOWER(e_name) || v_extension,
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
 V_DEMSG      VARCHAR2(2000);
 CURSOR C_SRC IS
    SELECT LINE,TEXT
    FROM   USER_SOURCE
    WHERE  UPPER(NAME) = UPPER(e_name)
    AND    TYPE = UPPER(e_type)
    ORDER BY LINE;
BEGIN
   m_arq.grava('PROMPT ' || e_type || ' - ' || e_name || ';');
   m_arq.grava(CREATE_OR_REPLACE);

   FOR R_SRC IN C_SRC LOOP
      BEGIN
         IF R_SRC.LINE = 5 THEN
            NULL;
         END IF;
         m_arq.grava(F_CHOMP(R_SRC.TEXT));
      EXCEPTION
         WHEN OTHERS THEN
            V_DEMSG := SQLERRM;
            V_DEMSG := R_SRC.LINE;
            V_DEMSG := LENGTH(R_SRC.TEXT);
            V_DEMSG := SUBSTR(R_SRC.TEXT,1,100);
      END;
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
    AND    NAME <> 'PKG_COM_STG_IMPORT'
    ORDER BY NAME,TYPE;

 o_arq              C_ARQN;
 v_deMsg            VARCHAR2(2000);
BEGIN
   o_arq := C_ARQN(nmDir => NVL(e_caminho, CONSTANTES.K_CAMINHO),
                   nmArq => 'fontes_' || TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') || '.sql',
                   tpArq => 'w',
                   nuTamReg => 32000);
   o_arq.ABRE;

   o_arq.GRAVA(SET_DEFINE_OFF);
   o_arq.GRAVA(SET_ECHO_OFF);
   o_arq.GRAVA(SET_HEADING_OFF);
   o_arq.GRAVA(SET_FEEDBACK_OFF);
   o_arq.GRAVA(REPLACE(SPOOL_ON,'#',NVL(e_caminho, CONSTANTES.K_CAMINHO)));

   FOR R_PRC IN C_PRC LOOP
      BEGIN
         GEN_FILE(e_type => R_PRC.type,
                  e_name => R_PRC.NAME,
                  m_arq => o_arq);
      EXCEPTION
         WHEN OTHERS THEN
            v_deMsg := R_PRC.type || ' ' || R_PRC.NAME;
            v_deMsg := SQLERRM;
      END;
   END LOOP;

   o_arq.GRAVA(SET_DEFINE_ON);
   o_arq.GRAVA(SET_ECHO_ON);
   o_arq.GRAVA(SET_HEADING_ON);
   o_arq.GRAVA(SET_FEEDBACK_ON);
   o_arq.GRAVA(SPOOL_OFF);
   o_arq.fecha;
EXCEPTION
   WHEN OTHERS THEN
      v_deMsg := SQLERRM;
      BEGIN
         o_arq.fecha;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
END;

END PKG_EXPORT_SOURCE_CODE;
/
