-- Trigger pour intercepter l'insertion dans ALL_WORKERS_ELAPSED
CREATE OR REPLACE TRIGGER trg_insert_all_workers_elapsed
INSTEAD OF INSERT ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
  IF :NEW.factory_id = 1 THEN
    INSERT INTO WORKERS_FACTORY_1 (first_name, last_name, age, first_day)
    VALUES (:NEW.first_name, :NEW.last_name, :NEW.age, :NEW.start_date);
  ELSIF :NEW.factory_id = 2 THEN
    INSERT INTO WORKERS_FACTORY_2 (first_name, last_name, start_date)
    VALUES (:NEW.first_name, :NEW.last_name, :NEW.start_date);
  END IF;
END;
/

-- Trigger pour empêcher les opérations UPDATE et DELETE sur ALL_WORKERS_ELAPSED
CREATE OR REPLACE TRIGGER trg_update_delete_all_workers_elapsed
INSTEAD OF UPDATE OR DELETE ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20001, 'Operation not allowed');
END;
/

-- Trigger pour enregistrer la date d'ajout dans AUDIT_ROBOT
CREATE OR REPLACE TRIGGER trg_add_robot_date
AFTER INSERT ON ROBOTS
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_ROBOT (robot_id, created_at)
  VALUES (:NEW.id, SYSDATE);
END;
/

-- Trigger pour contrôler les modifications de ROBOTS_FACTORIES
CREATE OR REPLACE TRIGGER trg_check_factories
BEFORE INSERT OR UPDATE OR DELETE ON ROBOTS_FACTORIES
FOR EACH ROW
DECLARE
  nb_factories NUMBER;
  nb_worker_tables NUMBER;
BEGIN
  SELECT COUNT(*) INTO nb_factories FROM FACTORIES;
  SELECT COUNT(*) INTO nb_worker_tables FROM user_tables WHERE table_name LIKE 'WORKERS_FACTORY_%';
  
  IF nb_factories != nb_worker_tables THEN
    RAISE_APPLICATION_ERROR(-20002, 'Mismatch between number of factories and worker tables');
  END IF;
END;
/

-- Trigger pour calculer le temps passé dans l'usine
CREATE OR REPLACE TRIGGER trg_add_departure_date
BEFORE UPDATE OF end_date ON WORKERS_FACTORY_1
FOR EACH ROW
BEGIN
  :NEW.duration_in_factory := :NEW.end_date - :OLD.first_day;
END;
/

CREATE OR REPLACE TRIGGER trg_add_departure_date_factory2
BEFORE UPDATE OF end_date ON WORKERS_FACTORY_2
FOR EACH ROW
BEGIN
  :NEW.duration_in_factory := :NEW.end_date - :OLD.start_date;
END;
/
