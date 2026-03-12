WITH RankedData AS (
    SELECT
        C5_OID,
        CASE
            WHEN ZAF_ERROR = 1 THEN 'E'
            WHEN ZAF_STAT = '4' THEN 'C'
            ELSE 'P'
        END AS STAT,
        CASE
            WHEN ZAF_ERROR = '1' THEN COALESCE(ZAF_MSG, '')
            WHEN ZAF_STAT = '4' THEN 'Pedido copiado'
            WHEN ZAF_STAT = '2' THEN 'Ignorado'
            WHEN ZAF_STAT = '1' THEN 'Processamento pendente'
            ELSE ''
        END AS MSG,
        CASE 
            WHEN ZAF_ERROR = '2' AND ZAF_STAT = '4' THEN 1
            ELSE 0
        END AS OK,
        ROW_NUMBER() OVER (
            PARTITION BY C5_OID
            ORDER BY
                CASE WHEN ZAF_STAT = '4' THEN 1 ELSE 2 END,
                R_E_C_N_O_ DESC
        ) AS rn
    FROM EXP_SC5
    JOIN TOP12_HOM2410.dbo.ZAF010 ZAF
        ON EXP_SC5.C5_FILIAL COLLATE Latin1_General_BIN = ZAF.ZAF_FILIAL
        AND EXP_SC5.C5_XFORMS = ZAF.ZAF_XFORMS
    WHERE API_STAT = 'P'
      --AND C5_EMISSAO >= DATEADD(DAY, -10, GETDATE())
      AND C5_OID >= (SELECT MAX(C5_OID) FROM EXP_SC5)-1000
)
UPDATE EXP_SC5
SET 
    API_STAT = RD.STAT,
    EXP_MSG = RD.MSG,
    F_REM = 1,
    F_RET = 1,
    F_OK = RD.OK
FROM EXP_SC5
JOIN RankedData RD ON EXP_SC5.C5_OID = RD.C5_OID
WHERE RD.rn = 1
  AND EXP_SC5.API_STAT = 'P'