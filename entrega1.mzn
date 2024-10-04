
int: ndisp; %numero de dispositivos medicos totales
set of int: DISP = 1..ndisp; %dispositivos medicos disponibles
int: ntandas; %numero de tandas solicitadas en un viernes determinado
set of int: TANDA = 1..ntandas; %Conjuntos de sesiones

%array[TANDA] of int : nsesion;
int: nsesion=19; %maximo de dias posibles de sesiones en 3 semanas:7+7+5
set of int: SESION = 1..nsesion;
array[TANDA,SESION] of int: duracion; %duracion de la sesion en dias
array[TANDA,SESION] of int: separacionIdeal; %separacion ideal respecto la sesion anterior en dias
%fecha de la solicitud de la tanda(dia del año por ejemplo)
array[TANDA] of int: fechaSolicitud;

%objetivo:
%para cada una de las sesiones a planificar asignar el dia y un dispositivo
%de manera que minimiza la sesion que se aleje mas de la separacion ideal

array[TANDA,SESION] of var int: diaSesion;%dia asignado a la sesion
array[TANDA,SESION] of var DISP: disp;
% var int: diferenciaIdeal=forall(i in SESION, j in TANDA, abs(fechaSolicitud[j]-disSesion[TANDA,SESION])); 
%minimizar sesiones que se aleje mucho de la separacion ideal
%solve minimize diferenciaIdeal;

%restricciones:
%dia sesion+ su duracion <= sesion2 -separacioideal de sesion2
%mismo sesion en el mismo dia
%no puede usar los dispositivos ocupados
%la 1r sesion de una tanda tiene que empezar 8 dias o menos desde la solicitud de la tanda.
%tener en cuenta las sesiones ya reservadas anteriormente

