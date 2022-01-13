

-- ���������� ������ �������� ����������
USE MyCompany


-- ����������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('����������')

INSERT INTO States (StateName) VALUES 
('��������'),
('������')

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(1, '������� ��������', 1, 2),
(1, '�������� ��������', 2, 1),
(1, '������� �� ������', 1, 3),
(1, '�������', 3, 4),
(1, '������������', 4, 3)



-- �����������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('�����������')

INSERT INTO States (StateName, Inactive) VALUES 
('���������',0),
('���������� �������������',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(2, '������� ��������', 1, 2),
(2, '�������� ��������', 2, 1),
(2, '����������� ���������', 1, 5),
(2, '����������� ���������� �������������', 5, 6),
(2, '������������ �����������', 6, 5)



-- �����������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('�����������')

INSERT INTO States (StateName, Inactive) VALUES 
('��������� �������������',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(3, '������� ��������', 1, 2),
(3, '�������� ��������', 2, 1),
(3, '���������� ���������', 1, 5),
(3, '���������� ��������� �������������', 5, 7),
(3, '������������ �����������', 7, 5)



-- ��������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('��������')

INSERT INTO States (StateName, Inactive) VALUES 
('������������',0),
('�����',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(4, '������� ��������', 1, 2),
(4, '�������� ��������', 2, 1),
(4, '��������� �� ������������', 1, 8),
(4, '������� �� ���������', 8, 1),
(4, '������ � ��������', 8, 5),
(4, '� �����', 5, 9)



-- ������������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('������������')

INSERT INTO States (StateName, Inactive) VALUES 
('�������',0)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(5, '������� ��������', 1, 2),
(5, '�������� ��������', 2, 1),
(5, '������ � ��������', 1, 10),
(5, '� �����', 10, 9),
(5, '������������', 9, 10)



-- ������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('������')

INSERT INTO States (StateName, Inactive) VALUES 
('�����������',0),
('�������',0),
('��������',0)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(6, '������� ��������', 1, 2),
(6, '�������� ��������', 2, 1),
(6, '� ������', 1, 11),
(6, '�������', 11, 12),
(6, '������ ��������', 12, 13)



-- ������� �������
INSERT INTO ObjectRoutes (RouteName) VALUES 
('������� �������')

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(7, '������� ��������', 1, 2),
(7, '�������� ��������', 2, 1),
(7, '�������', 1, 10),
(7, '� �����', 10, 9),
(7, '������������', 9, 10)

SELECT * FROM States
SELECT * FROM Steps JOIN ObjectRoutes ON Steps.RouteID = ObjectRoutes.RouteID

USE master

