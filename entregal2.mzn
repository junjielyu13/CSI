include "globals.mzn";

int: CAPACITY = (12 * 60) / 15; % capacidad diaria de cada LINAC (en intervalos de 15 minutos)
set of int: DAY = 1..7 * 3; % días en tres semanas

int: m; % número de LINACs
set of int: LINAC = 1..m;

% Tiempo disponible cada día en cada LINAC descontando el tiempo ya comprometido por tandas anteriores
array[LINAC, DAY] of 0..CAPACITY: disponible;

int: p; % número de nuevos pacientes cuyas tandas hay que incorporar
set of int: PACIENTE = 1..p;
int: s; % sesiones por tanda

% Día (laborable) de la semana en que se hizo la solicitud
array[PACIENTE] of 1..5: solicitud;

set of int: SESION = 1..s;

% Duración de las sesiones (en múltiplos de 15 minutos)
array[PACIENTE, SESION] of int: duracion;

% Número de días que idealmente tienen que pasar entre la sesión anterior y la actual.
% La primera columna se refiere al día de la solicitud.
array[PACIENTE, SESION] of int: separacion;

% Add constraints and optimization goals below as needed.
