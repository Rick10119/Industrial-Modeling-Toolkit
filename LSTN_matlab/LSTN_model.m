%% ��Lu-2021���������飬LSTN

% ���룺24h��ۣ�����������NOFPOINTS, NOFMACHINES, NOFINTERVALS
%% ��ȡ����

% ��������
parameter_Lu_milp;
NOFMACHINES = 10;
NOFPOINTS = 3;


E_intervals = [];
Cost_intervals = [];

delta_t = 1;
% ʱ����������
NOFINTERVALS = 24;

idx_day = 1;
Price = Price_days(:, idx_day);
%% ��������

% �����ڸ�����״̬������ʱ��
T_hnp = sdpvar(NOFPOINTS, NOFMACHINES, NOFINTERVALS, 'full');

% �����ĺ���
E_hn = sdpvar(NOFMACHINES, NOFINTERVALS, 'full');

% ���ϵ�����0ʱ��Ϊ��ʼֵ����Ϊ0�����Ϊ1-24ʱ��ĩ��ֵ��
S_hn = sdpvar(NOFMACHINES, NOFINTERVALS + 1, 'full');

%% Լ��
Constraints_primal = [];

% ���ֽܷ�Լ��(2)
temp = reshape(sum(T_hnp .* repmat(e_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, E_hn == temp];

% ʱ��Ǹ�Լ��(3)
Constraints_primal = [Constraints_primal, - T_hnp <= 0];
% ʱ�������Լ��(4)
temp = reshape(sum(T_hnp),  NOFMACHINES, NOFINTERVALS);
Constraints_primal = [Constraints_primal, temp == ones(NOFMACHINES, NOFINTERVALS)];

% ���ϱ仯Լ��(5, 6, 7)
% ��һ��ʱ�Σ�������ֵ
Constraints_primal = [Constraints_primal, S_hn(:, 1) == S_0];
% ����ʱ��
temp = reshape(sum(T_hnp .* repmat(g_np', 1, 1, NOFINTERVALS)), NOFMACHINES, NOFINTERVALS);
% ��ĩ����
Constraints_primal = [Constraints_primal, S_hn(1 : end-1, 2 : end) - S_hn(1 : end-1, 1 : end - 1) - ...
    temp(1 : end-1, 1 : end) + temp(2 : end, 1 : end) == 0];
% ĩ����(ע��P��S��ά�Ȳ�1)
Constraints_primal = [Constraints_primal, S_hn(end, 2 : end) - S_hn(end, 1 : end-1) - ...
    temp(end, 1 : end) == 0];

% ���ϴ洢Լ��(��β���Բ���)
Constraints_primal = [Constraints_primal, - S_hn <= 0];

Constraints_primal = [Constraints_primal, S_hn <= repmat(S_max, 1, NOFINTERVALS + 1)];

% ����Ŀ�꣨ĩʱ�Σ�
Constraints_primal = [Constraints_primal, S_0 + S_tar - S_hn(:, end) <= 0];


%% Ŀ�꺯��
Z_primal = sum(E_hn) * Price;

%% solve
ops = sdpsettings('debug',1,'solver','CPLEX');

sol = optimize(Constraints_primal, Z_primal, ops)


%% ͳ��ÿ��Сʱ������
E_val = ones(1, NOFMACHINES) * value(E_hn);
E_val = ones(1, 1/delta_t) * reshape(E_val', 1/delta_t, 24);
% plot(E_val);
