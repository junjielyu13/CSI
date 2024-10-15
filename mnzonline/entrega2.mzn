include "globals.mzn";
int: CAPACITY = (12 * 60) div 15; % capacidad diaria de cada LINAC (en intervalos de 15 minutos)=48
set of int: DAY = 1..7 * 3; % días en tres semanas
int: m; % número de LINACs
set of int: LINAC = 1..m;
% Tiempo disponible cada día en cada LINAC descontando el tiempo ya comprometido por tandas anteriores
array[LINAC, DAY] of 0..CAPACITY: disponible;
int: pac; % número de nuevos pacientes cuyas tandas hay que incorporar
set of int: PACIENTE = 1..pac;
int: sesion; % sesiones por tanda
% Día (laborable) de la semana en que se hizo la solicitud
array[PACIENTE] of 1..5: solicitud;
set of int: SESION = 1..sesion;
% Duración de las sesiones (en multiples de 15 minutos)
array[PACIENTE, SESION] of int: duracion;
% Número de días que idealmente tienen que pasar entre la sesión anterior y la actual.
array[PACIENTE, SESION] of int: separacion;
%variable de decision
array[PACIENTE, SESION] of var 0..CAPACITY: start;%tiempo cuando empieza una sesion en ese dia
array[PACIENTE, SESION] of var LINAC: linac;  % LINAC asignado a cada sesion
array[PACIENTE, SESION] of var DAY: diaAsignado;  % dia asignado para cada sesion

% Add constraints and optimization goals below as needed.
constraint forall(p in PACIENTE)(diaAsignado[p,1] <= solicitud[p]+8); %1r sesion menor que 8 dias
constraint forall(i in PACIENTE, j in SESION)(duracion[i,j]>=0);%el valor debe ser mayor que 0
constraint forall(i in PACIENTE, j in SESION)(separacion[i,j]>=0);%el valor debe ser mayor que 0
%nooverlap de las sesiones a nivel temporal en un dia
constraint forall(p1,p2 in PACIENTE, s1,s2 in SESION where p1<p2 /\ diaAsignado[p1,s1]!=diaAsignado[p2,s2])
(start[p1,s1]+duracion[p1,s1] div 15+1 <= start[p2,s2] \/ start[p2,s2]+duracion[p2,s2] div 15+1 <= start[p2,s2]);
%sesiones del mismo paciente no pueden ser asignadas en el mismo dia
constraint forall(p in PACIENTE, s1,s2 in SESION where s1<s2)(diaAsignado[p,s1]!=diaAsignado[p,s2]);
%ultima hora en el que se puede planificar una sesion
constraint forall(p in PACIENTE, s in SESION)(start[p,s]+duracion[p,s] div 15 <= CAPACITY);
% la suma de la duracion de las sesiones de un mismo dia y linac debe ser menor que la disponibilidad determinada
constraint forall(d in DAY, l in LINAC)
(sum(p in PACIENTE, s in SESION where diaAsignado[p,s]=d /\ linac[p,s]=l)(duracion[p,s] div 15) <= disponible[l,d]);

solve minimize sum(p in PACIENTE, s in 1..sesion-1)(abs(diaAsignado[p,s+1]-diaAsignado[p,s]));
