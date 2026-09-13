-- CREACION Y GESTIÓN DE USUARIOS

-- nota: se que ponerlo % asi no es lo mas acertado en cuestión de seguridad pero por temas de practicidad del taller, lo pondre de esta manera

 -- 1. Rol: Administrador del Sistema

CREATE USER 'usuario_admin'@'%' IDENTIFIED BY 'AdminSeguro2026*';

GRANT ALL PRIVILEGES ON ASOGASINGA.* TO 'usuario_admin'@'%' WITH GRANT OPTION;


-- 2. Rol: Personal de Salud Animal

CREATE USER 'usuario_veterinario'@'%' IDENTIFIED BY 'Veterinario2026*';


GRANT SELECT ON ASOGASINGA.ganado TO 'usuario_veterinario'@'%';
GRANT SELECT ON ASOGASINGA.fincas TO 'usuario_veterinario'@'%';


GRANT INSERT ON ASOGASINGA.vacunacion TO 'usuario_veterinario'@'%';
GRANT INSERT ON ASOGASINGA.vacunas TO 'usuario_veterinario'@'%';


GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarVacunacion TO 'usuario_veterinario'@'%';

-- 3. Rol: Encargado de Finca / Producción

CREATE USER 'usuario_operador'@'%' IDENTIFIED BY 'Operador2026*';

GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.ganado TO 'usuario_operador'@'%';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.produccion_leche TO 'usuario_operador'@'%';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.alimentacion  TO 'usuario_operador'@'%';

GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarProduccionLeche TO 'usuario_operador'@'%';

GRANT EXECUTE ON FUNCTION ASOGASINGA.fn_CalcularEdadMeses TO 'usuario_operador'@'%';


-- 4. Rol: Recursos Humanos

CREATE USER 'usuario_rrhh'@'%' IDENTIFIED BY 'RecursosHumanos2026*';

GRANT SELECT, INSERT, UPDATE, DELETE ON ASOGASINGA.empleados TO 'usuario_rrhh'@'%';


GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_ActualizarSalarioEmpleado TO 'usuario_rrhh'@'%';


-- 5.Rol: Auditor Externo / Consulta

CREATE USER 'usuario_auditor'@'%' IDENTIFIED BY 'Auditor2026*';


GRANT SELECT ON ASOGASINGA.* TO 'usuario_auditor'@'%';