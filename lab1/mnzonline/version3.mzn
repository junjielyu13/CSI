include "globals.mzn";

int: CAPACITY = (12 * 60) div 15; % 每个LINAC每天的容量（按15分钟为单位）
set of int: DAY = 1..7 * 3; % 三周中的天数（从1到21）

int: m; % LINAC的数量
set of int: LINAC = 1..m;
array[LINAC, DAY] of 0..CAPACITY: disponible; % 每天每个LINAC的可用时间，已经扣除了之前承诺的时间

int: paciente; % 新增患者的数量
set of int: PACIENTE = 1..paciente;

int: sesion; % 每个患者的会话数量
array[PACIENTE] of 1..5: solicitud; % 每个患者申请的天（工作日）
set of int: SESION = 1..sesion;
array[PACIENTE, SESION] of int: duracion; % 每次会话的持续时间（以15分钟为单位）
array[PACIENTE, 2..sesion] of int: separacion; % 理想情况下，每次会话之间的天数间隔

% 决策变量
array[PACIENTE, SESION] of var LINAC: linac;  % 每次会话分配的LINAC
array[PACIENTE, SESION] of var DAY: diaAsignado;  % 每次会话分配的天数
array[LINAC, DAY] of var 0..CAPACITY: tiempoOcupada; % 每天和每个LINAC被占用的时间
array[PACIENTE, SESION] of var int: desvioPaciente; % 每个患者会话的偏差
array[PACIENTE] of var int: desvioPacienteMax; % 每个患者的最大偏差

% 约束条件

% 第一次会话必须在申请后的8天内进行
constraint forall(p in PACIENTE)(diaAsignado[p,1] <= solicitud[p] + 8);

% 每个患者的会话时间必须大于0天
constraint forall(i in PACIENTE, j in SESION)(duracion[i,j] >= 0);

% 只从第二次会话开始计算偏差，因为第1次会话没有前置会话
constraint forall(p in PACIENTE, s in 2..sesion)(
  desvioPaciente[p,s] = abs(diaAsignado[p,s] - diaAsignado[p,s-1] - separacion[p,s])
);

% 确保第1次会话的偏差为0
constraint forall(p in PACIENTE)(
  desvioPaciente[p,1] = 0
);

% 确保同一患者的会话按时间顺序安排
constraint forall(p in PACIENTE, s in 1..sesion-1)(
  diaAsignado[p,s] < diaAsignado[p,s+1]
);

% 确保每天每个LINAC的被占用时间正确分配
constraint forall(d in DAY, l in LINAC)(
  tiempoOcupada[l,d] = sum(p in PACIENTE, s in SESION where diaAsignado[p,s] = d /\ linac[p,s] = l)(duracion[p,s])
);

% 每天每个LINAC的占用时间不得超过其可用时间
constraint forall(d in DAY, l in LINAC)(
  tiempoOcupada[l,d] <= disponible[l,d]
);

% 定义每个患者的最大偏差
constraint forall(p in PACIENTE)(
  desvioPacienteMax[p] = max([desvioPaciente[p,s] | s in SESION])
);

% 每个患者每天最多只能有一次会话
constraint forall(p in PACIENTE, d in DAY)(
  count([diaAsignado[p, s] | s in SESION], d) <= 1
);

% 求解目标：最小化所有患者中最大偏差的最大值
solve minimize max([desvioPacienteMax[p] | p in PACIENTE]);
