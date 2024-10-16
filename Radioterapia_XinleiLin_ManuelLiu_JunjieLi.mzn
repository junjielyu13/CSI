
int: ndisp; %numero de dispositivos medicos totales
set of int: DISP = 1..ndisp; %dispositivos medicos disponibles
int: ntandas; %numero de tandas solicitadas en un viernes determinado
set of int: TANDA = 1..ntandas; %Conjuntos de sesiones

int: nsesion; %numero de sesiones
set of int: SESION = 1..nsesion; %conjunto de sesiones
array[TANDA,SESION] of int: duracion; %duracion de la sesion en minutos
array[TANDA,SESION] of int: separacionIdeal; %separacion ideal respecto la sesion anterior en dias

%objetivo:
%para cada una de las sesiones a planificar asignar el dia y un dispositivo
%de manera que minimiza la sesion que se aleje mas de la separacion ideal

array[TANDA,SESION] of var int: diaSesion;  %dia asignado a la sesion
array[TANDA,SESION] of var DISP: disp;  %asignacion de dispositivos a cada sesion
array[TANDA,SESION] of int: diaSesionPlanificadas; %sesiones ya planificadas anteriormente
%var int: diferenciaIdeal=forall(i in SESION, j in TANDA, abs(fechaSolicitud[j]-disSesion[TANDA,SESION]));
%minimizar sesiones que se aleje mucho de la separacion ideal
%solve minimize diferenciaIdeal;


%restricciones:
% dia de la sesion+ su duracion <= sesion2 -separacioideal de sesion2
%no misma sesion en el mismo dia
%no puede usar los dispositivos ocupados
%la 1r sesion de una tanda tiene que empezar 8 dias o menos desde la solicitud de la tanda.
%tener en cuenta que las sesiones ya planificadas
%duracion ultima session no superar de las 8pm
%sesiones de una tanda no pase más de 3 semanas, teniendo en cuenta la separacion ideal.
