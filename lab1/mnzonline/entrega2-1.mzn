% Use this editor as a MiniZinc scratch book
include "globals.mzn";

int: CAPACITY = (12 * 60) div 15; % capacidad diaria de cada LINAC (en intervalos de 15 minutos)=48
set of int: DAY = 1..7 * 3; % días en tres semanas

int: m; % número de LINACs
set of int: LINAC = 1..m;
array[LINAC, DAY] of 0..CAPACITY: disponible; % Tiempo disponible cada día en cada LINAC descontando el tiempo ya comprometido por tandas anteriores

int: paciente; % número de nuevos pacientes cuyas tandas hay que incorporar
set of int: PACIENTE = 1..paciente;

int: sesion; % sesiones por tanda
array[PACIENTE] of 1..5: solicitud; % Día (laborable) de la semana en que se hizo la solicitud
set of int: SESION = 1..sesion;
array[PACIENTE, SESION] of int: duracion; % Duración de las sesiones (en multiples de 15 minutos)
array[PACIENTE, 2..sesion] of int: separacion; % Número de días que idealmente tienen que pasar entre la sesión anterior y la actual.

%variable de decision
array[PACIENTE, SESION] of var LINAC: linac;  % LINAC asignado a cada sesion
array[PACIENTE, SESION] of var DAY: diaAsignado;  % dia asignado para cada sesion
array[LINAC,DAY] of var 0..CAPACITY: tiempoOcupada; %tiempo ocupada a un dia y linac determinado
array[PACIENTE, SESION] of var int: desvioPaciente; %desvio de cada sesion del paciente
array[PACIENTE] of var int: desvioPacienteMax; %desvio maximo de cada tanda del paciente

% Add constraints and optimization goals below as needed.
%restricciones para los parametros de entrada
constraint forall(i in PACIENTE, j in SESION)(duracion[i,j]>0); %el valor debe ser mayor que 0
constraint forall(i in PACIENTE, j in 2..sesion)(separacion[i,j]>0); %el valor debe ser mayor que 0
constraint forall(d in DAY, l in LINAC where d>=15)(disponible[d,l]=48); %3r semana debe estar totalmente libre para cualquier LINAC
% la primera sesion debe estar planificada antes de 8 dias despues de la solicitud
constraint forall(p in PACIENTE)(diaAsignado[p,1] <= solicitud[p]+8); 

% orden entre sesiones de una misma tanda a nivel de dias
constraint forall(p in PACIENTE, s in 1..sesion-1)(diaAsignado[p,s]<diaAsignado[p,s+1]);

%Asignacion para la variable tiempoOcupada
constraint forall(d in DAY, l in LINAC)
(tiempoOcupada[l,d]=sum(p in PACIENTE, s in SESION where diaAsignado[p,s]=d /\ linac[p,s]=l)(duracion[p,s]));

% el tiempo ocupado por un dia y linac determinado es menor que la disponibilidad correspondiente
constraint forall(d in DAY, l in LINAC)(tiempoOcupada[l,d] <= disponible[l,d]);

%Asignacion del desvioPaciente
constraint forall(p in PACIENTE, s in 2..sesion)
(desvioPaciente[p,s]=abs(diaAsignado[p,s] - diaAsignado[p,s-1] - separacion[p,s]) /\ desvioPaciente[p,1]=0);
%Asignacion del desvioPacienteMax
constraint forall(p in PACIENTE)(desvioPacienteMax[p]=max(s in SESION)(desvioPaciente[p,s]));

%Solve
solve minimize max(p in PACIENTE)(desvioPacienteMax[p]);