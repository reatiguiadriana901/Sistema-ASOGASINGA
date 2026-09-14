USE ASOGASINGA;

-- 1. CREACIÓN DE ROLES 
CREATE ROLE IF NOT EXISTS 
    'administrador_del_sistema', 
    'personal_de_salud_animal', 
    'encargado_de_Finca', 
    'recurso_humanos', 
    'auditor_externo';

-- 2. ASIGNACIÓN DE PRIVILEGIOS A LOS ROLES

-- Privilegios: Administrador del Sistema
GRANT ALL PRIVILEGES ON ASOGASINGA.* TO 'administrador_del_sistema' WITH GRANT OPTION;

-- Privilegios: Personal de Salud Animal
GRANT SELECT ON ASOGASINGA.ganado TO 'personal_de_salud_animal';
GRANT SELECT ON ASOGASINGA.fincas TO 'personal_de_salud_animal';
GRANT INSERT ON ASOGASINGA.vacunacion TO 'personal_de_salud_animal';
GRANT INSERT ON ASOGASINGA.vacunas TO 'personal_de_salud_animal';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarVacunacion TO 'personal_de_salud_animal';

-- Privilegios: Encargado de Finca
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.ganado TO 'encargado_de_Finca';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.produccion_leche TO 'encargado_de_Finca';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.alimentacion TO 'encargado_de_Finca';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarProduccionLeche TO 'encargado_de_Finca';
GRANT EXECUTE ON FUNCTION ASOGASINGA.fn_CalcularEdadMeses TO 'encargado_de_Finca';

-- Privilegios: Recursos Humanos
GRANT SELECT, INSERT, UPDATE, DELETE ON ASOGASINGA.empleados TO 'recurso_humanos';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_ActualizarSalarioEmpleado TO 'recurso_humanos';

-- Privilegios: Auditor Externo
GRANT SELECT ON ASOGASINGA.* TO 'auditor_externo';


-- 3. CREACIÓN DE USUARIOS 
CREATE USER IF NOT EXISTS 'usuario_admin'@'%' IDENTIFIED BY 'AdminSeguro2026*';
CREATE USER IF NOT EXISTS 'usuario_veterinario'@'%' IDENTIFIED BY 'Veterinario2026*';
CREATE USER IF NOT EXISTS 'usuario_operador'@'%' IDENTIFIED BY 'Operador2026*';
CREATE USER IF NOT EXISTS 'usuario_rrhh'@'%' IDENTIFIED BY 'RecursosHumanos2026*';
CREATE USER IF NOT EXISTS 'usuario_auditor'@'%' IDENTIFIED BY 'Auditor2026*';


-- 4. ASIGNACIÓN DE ROLES A LOS USUARIOS
GRANT 'administrador_del_sistema' TO 'usuario_admin'@'%';
GRANT 'personal_de_salud_animal' TO 'usuario_veterinario'@'%';
GRANT 'encargado_de_Finca' TO 'usuario_operador'@'%';
GRANT 'recurso_humanos' TO 'usuario_rrhh'@'%';
GRANT 'auditor_externo' TO 'usuario_auditor'@'%';


-- 5. ACTIVACIÓN DE ROLES POR DEFECTO
SET DEFAULT ROLE ALL TO 
    'usuario_admin'@'%', 
    'usuario_veterinario'@'%', 
    'usuario_operador'@'%', 
    'usuario_rrhh'@'%', 
    'usuario_auditor'@'%';

FLUSH PRIVILEGES;
