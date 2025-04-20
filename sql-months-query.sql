-- Запрос для вывода месяцев текущего года и количества дней в них
-- Работает в большинстве SQL-систем (MySQL, PostgreSQL, SQL Server, Oracle)

WITH months AS (
    SELECT 1 AS month_num UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10 UNION ALL
    SELECT 11 UNION ALL
    SELECT 12
)
SELECT 
    CASE month_num
        WHEN 1 THEN 'Январь'
        WHEN 2 THEN 'Февраль'
        WHEN 3 THEN 'Март'
        WHEN 4 THEN 'Апрель'
        WHEN 5 THEN 'Май'
        WHEN 6 THEN 'Июнь'
        WHEN 7 THEN 'Июль'
        WHEN 8 THEN 'Август'
        WHEN 9 THEN 'Сентябрь'
        WHEN 10 THEN 'Октябрь'
        WHEN 11 THEN 'Ноябрь'
        WHEN 12 THEN 'Декабрь'
    END AS Месяц,
    CASE month_num
        WHEN 1 THEN 31
        WHEN 2 THEN CASE 
                      WHEN (EXTRACT(YEAR FROM CURRENT_DATE) % 4 = 0 AND EXTRACT(YEAR FROM CURRENT_DATE) % 100 != 0) 
                           OR (EXTRACT(YEAR FROM CURRENT_DATE) % 400 = 0) THEN 29
                      ELSE 28
                    END
        WHEN 3 THEN 31
        WHEN 4 THEN 30
        WHEN 5 THEN 31
        WHEN 6 THEN 30
        WHEN 7 THEN 31
        WHEN 8 THEN 31
        WHEN 9 THEN 30
        WHEN 10 THEN 31
        WHEN 11 THEN 30
        WHEN 12 THEN 31
    END AS "Количество дней"
FROM months
ORDER BY month_num;

-- Альтернативный вариант для MS SQL Server
/*
WITH months AS (
    SELECT 1 AS month_num UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10 UNION ALL
    SELECT 11 UNION ALL
    SELECT 12
)
SELECT 
    CASE month_num
        WHEN 1 THEN 'Январь'
        WHEN 2 THEN 'Февраль'
        WHEN 3 THEN 'Март'
        WHEN 4 THEN 'Апрель'
        WHEN 5 THEN 'Май'
        WHEN 6 THEN 'Июнь'
        WHEN 7 THEN 'Июль'
        WHEN 8 THEN 'Август'
        WHEN 9 THEN 'Сентябрь'
        WHEN 10 THEN 'Октябрь'
        WHEN 11 THEN 'Ноябрь'
        WHEN 12 THEN 'Декабрь'
    END AS Месяц,
    CASE month_num
        WHEN 1 THEN 31
        WHEN 2 THEN CASE 
                      WHEN (YEAR(GETDATE()) % 4 = 0 AND YEAR(GETDATE()) % 100 != 0) 
                           OR (YEAR(GETDATE()) % 400 = 0) THEN 29
                      ELSE 28
                    END
        WHEN 3 THEN 31
        WHEN 4 THEN 30
        WHEN 5 THEN 31
        WHEN 6 THEN 30
        WHEN 7 THEN 31
        WHEN 8 THEN 31
        WHEN 9 THEN 30
        WHEN 10 THEN 31
        WHEN 11 THEN 30
        WHEN 12 THEN 31
    END AS [Количество дней]
FROM months
ORDER BY month_num;
*/ 