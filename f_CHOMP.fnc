CREATE OR REPLACE FUNCTION f_CHOMP
/** RETIRA ULTIMO CARACTERE SE ELE FOR UM LINE FEED (LF) OU CARRIAGE RETURN (CR).
    IDENTICA A FUNCAO CHOMP DO PERL.
 %complex MUITO BAIXA
 %param  e_deLinha TEXTO PARA AVALIAC?O
 %return TEXTO SEM O CARACTER LF OU CR */
(e_deLinha  IN VARCHAR2) RETURN VARCHAR2
IS
 v_tam    INTEGER;
 v_linha  VARCHAR2(4000);
 v_ultcar CHAR(1);
BEGIN
   v_linha  := RTRIM(e_deLinha);
   v_tam    := LENGTH(v_linha);
   v_ultcar := SUBSTR(v_linha,v_tam,1);
   IF v_ultCar IN (CHR(10),CHR(12),CHR(13)) THEN
      v_linha  := SUBSTR(v_linha,1,v_tam-1);
   END IF;
   v_tam    := LENGTH(v_linha);
   v_ultcar := SUBSTR(v_linha,v_tam,1);
   IF v_ultCar IN (CHR(10),CHR(12),CHR(13)) THEN
      v_linha  := SUBSTR(v_linha,1,v_tam-1);
   END IF;
   RETURN v_linha;
END;
/
