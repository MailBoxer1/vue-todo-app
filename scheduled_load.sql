-- Пример настройки расписания для регулярной инкрементальной загрузки
-- Предполагается использование синтаксиса, совместимого с большинством SQL-планировщиков

-- Объявление переменных для планировщика
DECLARE @job_name NVARCHAR(100) = 'Subscription_Data_Incremental_Load';
DECLARE @job_description NVARCHAR(200) = 'Регулярная инкрементальная загрузка данных о подписках с применением фильтров';
DECLARE @job_schedule_name NVARCHAR(100) = 'Daily_Load_Schedule';
DECLARE @start_time INT = 10000; -- 01:00 AM
DECLARE @frequency_type INT = 4; -- Daily
DECLARE @frequency_interval INT = 1; -- Every 1 day

-- SQL Server пример создания задания
USE msdb;
GO

-- Удаляем существующее задание, если оно есть
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @job_name)
BEGIN
    EXEC sp_delete_job @job_name = @job_name, @delete_unused_schedule = 1;
END

-- Создаем новое задание
EXEC sp_add_job 
    @job_name = @job_name,
    @description = @job_description,
    @enabled = 1;

-- Определяем шаги задания для каждого метода
EXEC sp_add_jobstep
    @job_name = @job_name,
    @step_name = 'Execute MERGE Method',
    @subsystem = 'TSQL',
    @command = 'EXEC sp_executesql N''USE YourDatabase; 
                EXECUTE master.dbo.sp_execute_external_script
                @language = N''SQL'',
                @script = N''
                -- Здесь вставляется содержимое файла merge_method.sql
                '';'',
    @database_name = 'YourDatabase',
    @retry_attempts = 3,
    @retry_interval = 5;
    
EXEC sp_add_jobstep
    @job_name = @job_name,
    @step_name = 'Log Job Completion',
    @subsystem = 'TSQL',
    @command = 'INSERT INTO job_execution_log (job_name, execution_time, status)
                VALUES (@job_name, GETDATE(), ''SUCCESS'');',
    @database_name = 'YourDatabase';

-- Настройка расписания
EXEC sp_add_jobschedule
    @job_name = @job_name,
    @name = @job_schedule_name,
    @enabled = 1,
    @freq_type = @frequency_type,
    @freq_interval = @frequency_interval,
    @active_start_time = @start_time;

-- Закрепление задания за SQL Server Agent
EXEC sp_add_jobserver
    @job_name = @job_name;

GO

-- Для Oracle (PL/SQL) - пример настройки задания в DBMS_SCHEDULER
/*
BEGIN
    -- Удаляем существующее задание, если оно существует
    BEGIN
        DBMS_SCHEDULER.DROP_JOB('SUBSCRIPTION_DATA_LOAD_JOB');
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    -- Создаем новое задание
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SUBSCRIPTION_DATA_LOAD_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            DECLARE
                v_batch_id VARCHAR2(50) := TO_CHAR(SYSDATE, ''YYYYMMDD_HH24MISS'');
            BEGIN
                -- Здесь вставляется адаптированный для Oracle код из timestamp_tracking_method.sql
                INSERT INTO etl_batch_log (batch_id, start_time, status)
                VALUES (v_batch_id, SYSDATE, ''RUNNING'');
                
                -- Основная логика загрузки
                
                UPDATE etl_batch_log
                SET 
                    end_time = SYSDATE,
                    status = ''COMPLETED''
                WHERE batch_id = v_batch_id;
                
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE etl_batch_log
                    SET 
                        end_time = SYSDATE,
                        status = ''FAILED: '' || SQLERRM
                    WHERE batch_id = v_batch_id;
                    COMMIT;
                    RAISE;
            END;
        ',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; BYHOUR=1; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Ежедневная инкрементальная загрузка данных о подписках'
    );
END;
/
*/

-- Для PostgreSQL - пример настройки с использованием pg_cron
/*
-- Установка расширения pg_cron, если еще не установлено
-- CREATE EXTENSION pg_cron;

-- Создание задания на ежедневное выполнение в 01:00
SELECT cron.schedule('subscription_data_load', '0 1 * * *', $$
    -- Начало транзакции
    BEGIN;
    
    -- Запись о начале задания
    INSERT INTO etl_batch_log (batch_id, start_time, status)
    VALUES (TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS'), NOW(), 'RUNNING');
    
    -- Здесь вставляется адаптированный для PostgreSQL код из insert_update_method.sql
    
    -- Завершение задания с обновлением статуса
    UPDATE etl_batch_log
    SET 
        end_time = NOW(),
        status = 'COMPLETED'
    WHERE batch_id = TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS');
    
    -- Коммит изменений
    COMMIT;
$$);
*/

-- Для Apache Hahn (пример использования Airflow DAG)
/*
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email': ['data_alerts@example.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'subscription_data_incremental_load',
    default_args=default_args,
    description='Инкрементальная загрузка данных о подписках',
    schedule_interval='0 1 * * *',  # Выполнение в 01:00 каждый день
    catchup=False
)

run_job = BashOperator(
    task_id='run_incremental_load',
    bash_command='hahn-cli execute --file=/path/to/timestamp_tracking_method.sql',
    dag=dag
)
*/ 