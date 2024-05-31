-- Fonction GET_NB_WORKERS
CREATE OR REPLACE FUNCTION GET_NB_WORKERS(FACTORY_ID NUMBER) RETURN NUMBER IS
  nb_workers NUMBER;
BEGIN
  SELECT COUNT(*) INTO nb_workers
  FROM (
    SELECT 1 AS factory_id FROM WORKERS_FACTORY_1 WHERE last_day IS NULL
    UNION ALL
    SELECT 2 AS factory_id FROM WORKERS_FACTORY_2 WHERE end_date IS NULL
  )
  WHERE factory_id = FACTORY_ID;
  RETURN nb_workers;
END;
/

-- Fonction GET_NB_BIG_ROBOTS
CREATE OR REPLACE FUNCTION GET_NB_BIG_ROBOTS RETURN NUMBER IS
  nb_big_robots NUMBER;
BEGIN
  SELECT COUNT(DISTINCT robot_id) INTO nb_big_robots
  FROM ROBOTS_HAS_SPARE_PARTS
  GROUP BY robot_id
  HAVING COUNT(spare_part_id) > 3;
  RETURN nb_big_robots;
END;
/

-- Fonction GET_BEST_SUPPLIER
CREATE OR REPLACE FUNCTION GET_BEST_SUPPLIER RETURN VARCHAR2 IS
  best_supplier VARCHAR2(100);
BEGIN
  SELECT supplier_name INTO best_supplier
  FROM BEST_SUPPLIERS
  WHERE ROWNUM = 1;
  RETURN best_supplier;
END;
/

-- Fonction GET_OLDEST_WORKER
CREATE OR REPLACE FUNCTION GET_OLDEST_WORKER RETURN NUMBER IS
  oldest_worker_id NUMBER;
BEGIN
  SELECT id INTO oldest_worker_id
  FROM WORKERS_FACTORY_1
  WHERE first_day = (SELECT MIN(first_day) FROM WORKERS_FACTORY_1 WHERE last_day IS NULL)
  UNION ALL
  SELECT worker_id FROM WORKERS_FACTORY_2
  WHERE start_date = (SELECT MIN(start_date) FROM WORKERS_FACTORY_2 WHERE end_date IS NULL)
  FETCH FIRST 1 ROW ONLY;
  RETURN oldest_worker_id;
END;
/

-- Procédure SEED_DATA_WORKERS
CREATE OR REPLACE PROCEDURE SEED_DATA_WORKERS(NB_WORKERS NUMBER, FACTORY_ID NUMBER) IS
BEGIN
  FOR i IN 1..NB_WORKERS LOOP
    IF FACTORY_ID = 1 THEN
      INSERT INTO WORKERS_FACTORY_1 (first_name, last_name, first_day)
      VALUES ('worker_f_' || i, 'worker_l_' || i, 
              (SELECT TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2065-01-01','J'), 
                                                     TO_CHAR(DATE '2070-01-01','J'))), 'J') FROM DUAL));
    ELSIF FACTORY_ID = 2 THEN
      INSERT INTO WORKERS_FACTORY_2 (first_name, last_name, start_date)
      VALUES ('worker_f_' || i, 'worker_l_' || i, 
              (SELECT TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2065-01-01','J'), 
                                                     TO_CHAR(DATE '2070-01-01','J'))), 'J') FROM DUAL));
    END IF;
  END LOOP;
END;
/

-- Procédure ADD_NEW_ROBOT
CREATE OR REPLACE PROCEDURE ADD_NEW_ROBOT(MODEL_NAME VARCHAR2) IS
BEGIN
  INSERT INTO ROBOTS (model)
  VALUES (MODEL_NAME);
END;
/

-- Procédure SEED_DATA_SPARE_PARTS
CREATE OR REPLACE PROCEDURE SEED_DATA_SPARE_PARTS(NB_SPARE_PARTS NUMBER) IS
BEGIN
  FOR i IN 1..NB_SPARE_PARTS LOOP
    INSERT INTO SPARE_PARTS (name, color)
    VALUES ('part_' || i, 'gray'); -- ou autre couleur au choix
  END LOOP;
END;
/
