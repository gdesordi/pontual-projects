SELECT
    MAX(dbo.F_BR(I_N_S_D_T_))                                             AS LAST_IN,

    MAX(CASE WHEN ZAF_STAT = '4' 
             THEN dbo.F_BR(S_T_A_M_P_) END)                               AS LAST_SUCCESSFUL,

    MAX(CASE WHEN ZAF_STAT = '2' 
             THEN dbo.F_BR(S_T_A_M_P_) END)                               AS LAST_IGNORED,

    MAX(CASE WHEN ZAF_ERROR = '1' 
             THEN dbo.F_BR(S_T_A_M_P_) END)                               AS LAST_ERROR,

    MIN(CASE WHEN ZAF_STAT = '1' 
              AND I_N_S_D_T_ >= GETDATE() - 1
             THEN dbo.F_BR(S_T_A_M_P_) END)                               AS NEXT_,

    CONVERT(
        TIME,
        GETDATE() - MIN(CASE WHEN ZAF_STAT = '1' 
                              AND I_N_S_D_T_ >= GETDATE() - 1
                             THEN dbo.F_BR(S_T_A_M_P_) END)
    )                                                                     AS QUEUE_TIME_,

    COUNT(CASE WHEN ZAF_STAT = '1' 
                AND I_N_S_D_T_ >= GETDATE() - 1
               THEN 1 END)                                                AS QUEUE_

FROM ZAF010;

SELECT ZAE_IDZAE, ZAE_WINUS, dbo.F_BR(ZAE.I_N_S_D_T_) INS_, ZAF_STAT, COUNT(*) COUNT_
FROM ZAE010 ZAE
JOIN ZAF010 ZAF
ON ZAE_IDZAE = ZAF_IDZAE
WHERE ZAE_IDZAE IN (
	SELECT TOP 5 ZAE_IDZAE--TOP 5 *, DATEADD(HOUR, -3, I_N_S_D_T_)
	FROM ZAE010
	ORDER BY R_E_C_N_O_ DESC
)
GROUP BY ZAE_IDZAE, ZAE_WINUS, ZAE.I_N_S_D_T_, ZAF_STAT

SELECT TOP 5 dbo.F_BR(S_T_A_M_P_) ERROR_DATE_, ZAF_XFORMS, ZAF_MSG, ZAF_IDZAF, ZAF_IDZAE, CONVERT(VARCHAR(MAX), ZAF_LOG) LOG_
FROM ZAF010
WHERE ZAF_ERROR = '1'
ORDER BY R_E_C_N_O_ DESC