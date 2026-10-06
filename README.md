# 🐄 Sistema ASOGASINGA – Base de Datos Relacional en MySQL

Implementación de una base de datos relacional para la **Asociación de Ganaderos Sin Ganado (ASOGASINGA)**, que centraliza y automatiza la gestión de socios, fincas, inventario de ganado, producción de leche, vacunación, personal y alimentación. Incluye lógica de negocio en el servidor (procedimientos almacenados, funciones, triggers y eventos) y un esquema de seguridad basado en roles con el principio de **menor privilegio**.

---

## 📑 Tabla de contenido

1. [Contexto del negocio](#-contexto-del-negocio)
2. [Estructura del repositorio](#-estructura-del-repositorio)
3. [Modelo de datos](#-modelo-de-datos)
4. [Procedimientos almacenados](#-procedimientos-almacenados)
5. [Funciones (UDF)](#-funciones-udf)
6. [Triggers](#-triggers)
7. [Eventos programados](#-eventos-programados)
8. [Seguridad: usuarios, roles y permisos](#-seguridad-usuarios-roles-y-permisos)
9. [Instalación y ejecución](#-instalación-y-ejecución)
10. [Tecnologías](#-tecnologías)

---

## 🌾 Contexto del negocio

ASOGASINGA necesita optimizar la lógica del negocio dentro del servidor de base de datos y garantizar la seguridad de la información. Las operaciones que cubre el sistema son:

- Gestión de **socios** y **fincas**
- Inventario de **ganado**
- Control de **producción de leche**
- Esquemas de **vacunación**
- Gestión de **personal**
- Control de **alimentación**

---

## 📂 Estructura del repositorio

| Archivo | Descripción |
|---|---|
| `estructura_base.sql` | Creación de las 12 tablas, llaves primarias/foráneas e inserts base |
| `Funciones.sql` | Las 5 funciones definidas por el usuario (UDF) |
| `Procedimientos_almacenados.sql` | Los 5 procedimientos almacenados |
| `Triggers_eventos.sql` | Los 3 triggers y los 2 eventos programados |
| `creacion_gestion_usuarios.sql` | Creación de usuarios, contraseñas y asignación de privilegios (`GRANT`) |

---

## 🗄️ Modelo de datos

El esquema está compuesto por **12 tablas** con integridad referencial mediante llaves primarias y foráneas:

`socios` · `municipios` · `fincas` · `tipos_ganado` · `ganado` · `veterinarios` · `vacunas` · `vacunacion` · `produccion_leche` · `empleados` · `alimentos` · `alimentacion`

Además, la automatización requiere tablas de apoyo: `auditoria_salarios` y `resumen_semanal_fincas` (más una bitácora para el registro de depuraciones).

---

## ⚙️ Procedimientos almacenados

| Procedimiento | Descripción |
|---|---|
| `sp_RegistrarProduccionLeche` | Recibe el código de arete, la fecha y los litros. Busca el `ganado_id` y registra la producción, validando que el animal sea de tipo **"Lechero"** y sexo **"Hembra"**. |
| `sp_ActualizarSalarioEmpleado` | Recibe el `empleado_id` y un porcentaje de aumento (ej. `10.00` = 10%) y actualiza el salario en `empleados`. |
| `sp_TrasladarGanadoFinca` | Recibe el `ganado_id` y la `finca_id` de destino, y modifica la ubicación actual del animal. |
| `sp_RegistrarVacunacion` | Recibe el código de arete, el nombre de la vacuna, el id del veterinario y las observaciones; inserta el registro con la fecha actual del sistema. |
| `sp_ReporteGastoAlimento` | Recibe el `ganado_id` y un rango de fechas; devuelve el total gastado en alimentación (`cantidad_kg` × costo del alimento). |

---

## 🧮 Funciones (UDF)

| Función | Descripción |
|---|---|
| `fn_CalcularEdadMeses` | Recibe el `ganado_id` y devuelve la edad actual del animal en meses (entero) a partir de `fecha_nacimiento`. |
| `fn_TotalLitrosFinca` | Recibe el `finca_id` y un rango de fechas; devuelve el total de litros producidos por todos los animales de la finca. |
| `fn_PromedioPesoPorRaza` | Recibe el nombre de una raza (ej. `'Holstein'`) y devuelve el peso promedio de sus animales. |
| `fn_ContarGanadoPorSocio` | Recibe el `socio_id` y devuelve la cantidad total de cabezas de ganado que posee a través de todas sus fincas. |
| `fn_CostoTotalAlimentacion` | Recibe un `ganado_id` y devuelve la sumatoria histórica del costo de los alimentos consumidos por el animal. |

---

## 🛡️ Triggers

| Trigger | Tabla | Momento | Regla de negocio |
|---|---|---|---|
| `trg_ValidarPesoGanado` | `ganado` | BEFORE INSERT / BEFORE UPDATE | Si `peso_kg` ≤ 0 o > 1500.00 kg, aborta con `SIGNAL SQLSTATE '45000'`: *"Error: El peso ingresado está fuera de los rangos biológicos válidos (1 - 1500 kg)"*. |
| `trg_AuditarAumentoSalario` | `empleados` | AFTER UPDATE | Solo cuando `NEW.salario <> OLD.salario`; inserta en `auditoria_salarios` (`empleado_id`, `salario_anterior`, `salario_nuevo`, `diferencia`, `fecha_modificacion`). |
| `trg_ValidarIntervaloVacunacion` | `vacunacion` | BEFORE INSERT | Si el animal ya recibió la misma vacuna en los últimos 30 días, cancela con `SIGNAL SQLSTATE '45000'`: *"Error: El animal ya recibió esta vacuna en un periodo menor a 30 días"*. |

---

## ⏰ Eventos programados

| Evento | Frecuencia | Acción |
|---|---|---|
| `evt_DepuracionAuditoriaMensual` | `EVERY 1 MONTH` | Elimina los registros de `auditoria_salarios` con más de 6 meses de antigüedad (`fecha_modificacion < NOW() - INTERVAL 6 MONTH`) y registra en una bitácora la cantidad de filas purgadas. |
| `evt_CierreSemanalProduccionLeche` | `EVERY 1 WEEK` (domingos 23:59:00) | Agrupa la producción total de leche de la semana por finca e inserta el consolidado en `resumen_semanal_fincas` (`finca_id`, `litros_totales`, `semana_anio`, `fecha_cierre`). |

> Para que los eventos se ejecuten, el programador de eventos de MySQL debe estar activo:
> ```sql
> SET GLOBAL event_scheduler = ON;
> ```

---

## 🔐 Seguridad: usuarios, roles y permisos

Se crean **5 usuarios** aplicando el principio de menor privilegio:

| Usuario | Rol | Permisos |
|---|---|---|
| `usuario_admin` | Administrador del sistema | `ALL PRIVILEGES` sobre la base de datos; puede crear, modificar y eliminar tablas y ejecutar cualquier procedimiento o función. |
| `usuario_veterinario` | Personal de salud animal | `SELECT` en `ganado` y `fincas`; `INSERT` en `vacunacion` y `vacunas`; `EXECUTE` en `sp_RegistrarVacunacion`. |
| `usuario_operador` | Encargado de finca / producción | `SELECT`, `INSERT`, `UPDATE` en `produccion_leche`, `alimentacion` y `ganado`; `EXECUTE` en `sp_RegistrarProduccionLeche` y `fn_CalcularEdadMeses`. **No** puede ver `empleados`. |
| `usuario_rrhh` | Recursos humanos | `SELECT`, `INSERT`, `UPDATE`, `DELETE` exclusivamente sobre `empleados`; `EXECUTE` en `sp_ActualizarSalarioEmpleado`. |
| `usuario_auditor` | Auditor externo / consulta | Únicamente `SELECT` en todas las tablas. Sin DML (`INSERT`, `UPDATE`, `DELETE`) ni alteraciones estructurales. |

---

## 🚀 Instalación y ejecución

**Requisitos:** MySQL 8.x (o compatible) y un cliente como MySQL Workbench o la línea de comandos.

1. Clona el repositorio:
   ```bash
   git clone <URL-DEL-REPOSITORIO>
   cd <NOMBRE-DEL-REPOSITORIO>
   ```
2. Ejecuta los scripts en este orden:
   ```bash
   mysql -u root -p < estructura_base.sql
   mysql -u root -p < Funciones.sql
   mysql -u root -p < Procedimientos_almacenados.sql
   mysql -u root -p < Triggers_eventos.sql
   mysql -u root -p < creacion_gestion_usuarios.sql
   ```
3. Activa el programador de eventos (si no lo está):
   ```sql
   SET GLOBAL event_scheduler = ON;
   ```
4. Prueba los componentes, por ejemplo:
   ```sql
   SELECT fn_CalcularEdadMeses(1);
   ```

---

## 🧰 Tecnologías

- **MySQL** (DDL, DML, Stored Procedures, Functions, Triggers, Events)
- **SQL** para gestión de usuarios, roles y privilegios
- **Git / GitHub** para el control de versiones

---

## 👩‍💻 Autora

**Adriana Reatigui** – Proyecto académico de Base de Datos (Campuslands)
