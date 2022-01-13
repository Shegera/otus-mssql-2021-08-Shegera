

-- Наполнение таблиц базовыми значениями
USE MyCompany


-- Сотрудники
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Сотрудники')

INSERT INTO States (StateName) VALUES 
('Работает'),
('Уволен')

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(1, 'Удалить черновик', 1, 2),
(1, 'Отменить Удаление', 2, 1),
(1, 'Принять на работу', 1, 3),
(1, 'Уволить', 3, 4),
(1, 'Восстановить', 4, 3)



-- Организации
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Организации')

INSERT INTO States (StateName, Inactive) VALUES 
('Действует',0),
('Прекратила существование',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(2, 'Удалить черновик', 1, 2),
(2, 'Отменить Удаление', 2, 1),
(2, 'Организация действует', 1, 5),
(2, 'Организация прекратила существование', 5, 6),
(2, 'Восстановить организацию', 6, 5)



-- Контрагенты
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Контрагенты')

INSERT INTO States (StateName, Inactive) VALUES 
('Прекратил существование',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(3, 'Удалить черновик', 1, 2),
(3, 'Отменить Удаление', 2, 1),
(3, 'Контрагент действует', 1, 5),
(3, 'Контрагент прекратил существование', 5, 7),
(3, 'Восстановить контрагента', 7, 5)



-- Договоры
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Договоры')

INSERT INTO States (StateName, Inactive) VALUES 
('Согласование',0),
('Архив',1)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(4, 'Удалить черновик', 1, 2),
(4, 'Отменить Удаление', 2, 1),
(4, 'Отправить на согласование', 1, 8),
(4, 'Вернуть на доработку', 8, 1),
(4, 'Ввести в действие', 8, 5),
(4, 'В архив', 5, 9)



-- Номенклатуры
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Номенклатуры')

INSERT INTO States (StateName, Inactive) VALUES 
('Активна',0)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(5, 'Удалить черновик', 1, 2),
(5, 'Отменить Удаление', 2, 1),
(5, 'Ввести в действие', 1, 10),
(5, 'В архив', 10, 9),
(5, 'Восстановить', 9, 10)



-- Заказы
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Заказы')

INSERT INTO States (StateName, Inactive) VALUES 
('Выполняется',0),
('Оплачен',0),
('Выполнен',0)

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(6, 'Удалить черновик', 1, 2),
(6, 'Отменить Удаление', 2, 1),
(6, 'В работу', 1, 11),
(6, 'Оплачен', 11, 12),
(6, 'Заказы выполнен', 12, 13)



-- Позиции заказов
INSERT INTO ObjectRoutes (RouteName) VALUES 
('Позиции заказов')

INSERT INTO Steps (RouteID, StepName, FromStateID, ToStateID) VALUES 
(7, 'Удалить черновик', 1, 2),
(7, 'Отменить Удаление', 2, 1),
(7, 'Активна', 1, 10),
(7, 'В архив', 10, 9),
(7, 'Восстановить', 9, 10)

SELECT * FROM States
SELECT * FROM Steps JOIN ObjectRoutes ON Steps.RouteID = ObjectRoutes.RouteID

USE master

