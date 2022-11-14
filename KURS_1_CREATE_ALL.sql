/* Создааем базу для компьетерного магазина, в которую можно занести пользователей, товары,
количество товара на складе, а также в ней отражены заказы пользователей. Кроме того, компьютерная база
позволяет пользователям ставить оценку товарам и вести переписку с администрацией магазина. */

DROP DATABASE IF EXISTS computer_shop_1; 
CREATE DATABASE computer_shop_1;
USE computer_shop_1;

-- Создаем таблицу пользователей
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(40),
	lastname VARCHAR(40),
	login VARCHAR(40),
	password_hash VARCHAR(100), 
	email VARCHAR(100) UNIQUE,
	phone BIGINT UNIQUE NOT NULL,
	birthday DATE,
	hometown VARCHAR(40),
	INDEX users_firstname_lastname_idx(firstname, lastname)
);


-- Создаем таблицу сообщений
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Срздаем таблицу каталога
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
  	name VARCHAR(255)
);

-- Создаем таблицу товаров
DROP TABLE IF EXISTS products;
CREATE TABLE products (
	id SERIAL PRIMARY KEY,
  	name VARCHAR(255),
  	description TEXT,
  	price DECIMAL (11,2),
  	catalog_id BIGINT UNSIGNED,
  	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 	INDEX index_of_catalog_id (catalog_id),
 	FOREIGN KEY (catalog_id) REFERENCES catalogs(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создаем таблицу заказов
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED,
 	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 	INDEX index_of_user_id(user_id),
 	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создаем таблицу товаров в заказе
DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
	id SERIAL,
  	order_id BIGINT UNSIGNED,
  	product_id BIGINT UNSIGNED,
  	total BIGINT UNSIGNED DEFAULT 1,
  	PRIMARY KEY (id, order_id, product_id),
  	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  	FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
  	FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создаем таблицу складов
DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  	id SERIAL PRIMARY KEY,
  	name VARCHAR(100),
  	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Создаем таблицу с товарами на складах
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
	id SERIAL PRIMARY KEY,
  	storehouse_id BIGINT UNSIGNED,
  	product_id BIGINT UNSIGNED,
  	value BIGINT,
  	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  	FOREIGN KEY (storehouse_id) REFERENCES storehouses(id) ON UPDATE CASCADE ON DELETE CASCADE,
  	FOREIGN KEY (product_id) REFERENCES products (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создаем таблицу отзывов
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	product_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	grade DECIMAL(1,0),
	INDEX reviews_product_id_idx(product_id),
	FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создаем таблицу вида архив с изменениями количества товаров на складах
DROP TABLE IF EXISTS products_change_logs;
CREATE TABLE logs_products_change (
	id SERIAL,	
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	from_storehouses_id VARCHAR (40),
	from_product_id BIGINT,
	value_change BIGINT
) ENGINE=ARCHIVE;

INSERT INTO users (firstname, lastname, login, password_hash, email, phone, birthday, hometown) VALUES
('Александр', 'Овечкин', 'user01', 'abcde01234567000', 'user01@gmail.com', '89160000001', '1985-05-12', 'Москва'),
('Кирилл', 'Козлов', 'user02', 'abcde01234567002', 'user02@gmail.com', '89160000002', '1976-05-01', 'Москва'),
('Сергей', 'Кирьяков', 'user03', 'abcde01234567003', 'user03@gmail.com', '89160000003', '1993-12-17', 'Москва'),
('Вадим', 'Иванов', 'user04', 'abcde01234567004', 'user04@gmail.com', '89160000004', '1998-03-20', 'Санкт-Петербург'),
('Екатерина', 'Иванова', 'user05', 'abcde01234567005', 'user05@gmail.com', '89160000005', '2000-01-08', 'Москва'),
('Ольга', 'Седова', 'user06', 'abcde01234567006', 'user06@gmail.com', '89160000006', '1997-06-27', 'Ижевск'),
('Денис', 'Клюев', 'user07', 'abcde01234567007', 'user07@gmail.com', '89160000007', '1998-02-20', 'Москва'),
('Игорь', 'Колыванов', 'user08', 'abcde01234567008', 'user08@gmail.com', '89160000008', '2001-07-21', 'Тула'),
('Александр', 'Уваров', 'user09', 'abcde01234567009', 'user09@gmail.com', '89160000009', '1985-05-20', 'Москва'),
('Светлана', 'Некрасова', 'user10', 'abcde01234567010', 'user10@gmail.com', '89160000010', '1985-09-27', 'Москва'),
('Валерий', 'Маслов', 'user11', 'abcde01234567011', 'user11@gmail.com', '89160000011', '1986-10-08', 'Санкт-Петербург'),
('Ирина', 'Гусева', 'user12', 'abcde01234567012', 'user12@gmail.com', '89160000012', '1969-11-18', 'Москва'),
('Алексей', 'Козлов', 'user13', 'abcde01234567013', 'user13@gmail.com', '89160000013', '1979-05-16', 'Москва'),
('Ирина', 'Авербах', 'user14', 'abcde01234567014', 'user14@gmail.com', '89160000014', '1968-07-30', 'Москва'),
('Александр', 'Алехин', 'user15', 'abcde01234567015', 'user15@gmail.com', '89160000015', '1998-03-02', 'Москва'),
('Михаил', 'Таль', 'user16', 'abcde01234567016', 'user16@gmail.com', '89160000016', '1993-01-06', 'Москва'),
('Анатолий', 'Карпов', 'user17', 'abcde01234567017', 'user17@gmail.com', '89160000017', '1995-08-08', 'Москва'),
('Дарья', 'Сидорова', 'user18', 'abcde01234567018', 'user18@gmail.com', '89160000018', '1987-09-17', 'Москва'),
('Андрей', 'Кобелев', 'user19', 'abcde01234567019', 'user19@gmail.com', '89160000019', '1986-12-16', 'Москва'),
('Михаил', 'Ботвинник', 'user20', 'abcde01234567020', 'user20@gmail.com', '89160000020', '1982-11-24', 'Москва');


INSERT INTO messages (from_user_id, to_user_id, body) VALUES
('1', '4', 'Добро пожаловать в наш магазин!'),
('1', '5', 'Добро пожаловать в наш магазин!'),
('1', '6', 'Добро пожаловать в наш магазин!'),
('1', '7', 'Добро пожаловать в наш магазин!'),
('1', '8', 'Добро пожаловать в наш магазин!'),
('1', '9', 'Добро пожаловать в наш магазин!'),
('1', '10', 'Добро пожаловать в наш магазин!'),
('1', '11', 'Добро пожаловать в наш магазин!'),
('4', '1', 'Ваш магазин работает в выходные?'),
('1', '12', 'Добро пожаловать в наш магазин!'),
('1', '13', 'Добро пожаловать в наш магазин!'),
('10', '1', 'У вас есть скидки?'),
('1', '14', 'Добро пожаловать в наш магазин!'),
('1', '15', 'Добро пожаловать в наш магазин!'),
('1', '16', 'Добро пожаловать в наш магазин!'),
('1', '17', 'Добро пожаловать в наш магазин!'),
('1', '18', 'Добро пожаловать в наш магазин!'),
('1', '19', 'Добро пожаловать в наш магазин!'),
('1', '20', 'Добро пожаловать в наш магазин!'),
('1', '4', 'Мы работаем без выходных.');

INSERT INTO catalogs (id, name) VALUES
('1', 'Процессоры'),
('2', 'Видеокарты'),
('3', 'Материнские платы'),
('4', 'Память'),
('5', 'Корпуса'),
('6', 'Блоки питания'),
('7', 'Накопители'),
('8', 'Звуковые карты'),
('9', 'Сетевое оборудование'),
('10', 'Прочее');

INSERT INTO products (name, description, price, catalog_id) VALUES
('Intel Celeron G6900 3.4ГГц', '2-ядерный, 4МБ, LGA1700, OEM', 5950, 1),
('Intel Core i3-10105F 3.7ГГц', '(Turbo 4.4ГГц), 4-ядерный, L3 6МБ, LGA1200, OEM', 9950, 1),
('Intel Core i3-10105F 3.7ГГц', '(Turbo 4.4ГГц), 4-ядерный, L3 6МБ, LGA1200, BOX', 10350, 1),
('Intel Core i5-10400F, 2.9ГГц', '(Turbo 4.3ГГц), 6-ядерный, L3 12МБ, LGA1200, OEM', 15250, 1),
('AMD Ryzen 5 3600, 3.6ГГц', '(Turbo 4.2ГГц), 6-ядерный, L3 32МБ, Сокет AM4, OEM', 17350, 1),
('AMD Ryzen 9 5900X, 3.7ГГц', '(Turbo 4.8ГГц), 12-ядерный, L3 64МБ, Сокет AM4, BOX', 45750, 1),
('ASUS GeForce GTX 1660 Super 6144Mb', 'PH-GTX1660S-O6G DVI-D, HDMI, DP Ret', 51450, 2),
('ASUS GeForce RTX 3060 12288Mb', 'Phoenix 12G V2 LHR (PH-RTX3060-12G-V2) 1xHDMI, 3xDP, Ret', 65950, 2),
('ASUS 12888Mb RX 6700 XT', 'Dual-RX6700XT-O12G 3xDP, HDMI, Ret', 89950, 2),
('Palit GeForce RTX 3060 Ti 8192Mb', 'ColorPOP (NE6306T019P2-1041R) 1xHDMI, 3xDP, Ret', 93990, 2),
('ASUS GeForce RTX 3080 10240Mb', 'Strix White V2 O10G (ROG-Strix-RTX3080-O10G-White-V2) 2xHDMI, 3xDP, Ret', 155550, 2),
('Gigabyte B660M DS3H DDR4', 'B660 Socket-1700 4xDDR4, 4xSATA3, RAID, 2xM.2, 1xPCI-E16x', 12450, 3),
('MSI MAG B550M Mortar Socket-AM4 AMD', 'B550 4xDDR4, 6xSATA3, RAID, 2xM.2, 2xPCI-E16x, 3xUSB3.2', 13350, 3),
('ASUS TUF Gaming B660M-Plus', 'WiFi B660 Socket-1700 4xDDR5, 4xSATA3, RAID, 2xM.2, 2xPCI-E16x', 16980, 3),
('DIMM 16Gb 2х8Gb DDR4 PC21300', '2666MHz Gigabyte', 8390, 4),
('DIMM 16Gb DDR4 PC25600', '3200MHz Crucial Ballistix White', 12950, 4),
('ATX Miditower Zalman', 'N5 MF Black, N5 MF', 5710, 5),
('Внутренний жесткий диск 3,5" 1Tb Western Digital', '(WD10EZEX) 64Mb 7200rpm SATA3 Caviar Blue', 5150, 7),
('SSD-накопитель 480Gb Western Digital', 'Green WDS480G2G0A SATA3 2.5"', 6950, 7),
('SSD-накопитель 1000Gb Western Digital Blue', 'WDS100T2B0A SATA3 2.5"', 13640, 7);

INSERT INTO orders (user_id) VALUES
(4),
(4),
(4),
(4),
(5),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(14),
(17),
(20);

INSERT INTO orders_products (order_id, product_id, total) VALUES
(1, 1, 1),
(1, 7, 1),
(1, 14, 1),
(1, 20, 2),
(2, 2, 1),
(2, 19, 1),
(3, 16, 4),
(4, 10, 1),
(5, 10, 1),
(6, 18, 1),
(6, 2, 1),
(7, 18, 5),
(8, 15, 4),
(9, 3, 1),
(10, 4, 1),
(11, 9, 1),
(12, 12, 1),
(13, 3, 1),
(14, 19, 2),
(15, 17, 1),
(15, 16, 1),
(5, 3, 1),
(14, 1, 1),
(12, 7, 1),
(11, 2, 1),
(11, 20, 1);

INSERT INTO storehouses (id, name) VALUES
(1, 'Москва-север'),
(2, 'Москва-юг'),
(3, 'Санкт-Петербург');

INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES
(1, 1, 15),
(2, 1, 5),
(1, 2, 7),
(1, 3, 8),
(3, 1, 2),
(1, 4, 5),
(2, 4, 3),
(3, 4, 7),
(1, 5, 3),
(1, 6, 25),
(2, 6, 15),
(3, 6, 11),
(1, 7, 10),
(2, 7, 9),
(3, 7, 2),
(1, 8, 7),
(2, 8, 2),
(1, 9, 3),
(1, 10, 8),
(2, 10, 3),
(1, 11, 2),
(1, 12, 14),
(2, 12, 10),
(3, 12, 5),
(1, 13, 8),
(2, 13, 5),
(1, 14, 3),
(1, 15, 26),
(2, 15, 18),
(3, 15, 10),
(1, 16, 18),
(1, 17, 8),
(2, 17, 5),
(1, 18, 8),
(2, 18, 6),
(3, 18, 3),
(1, 19, 8),
(1, 20, 3);

INSERT INTO reviews (from_user_id, product_id, body, grade) VALUES
(4, 1, 'Отличный процесоор. Хорошо разгоняется', 5),
(4, 7, 'Хорошая недорогая видеокарта', 5),
(4, 14, 'Надежная материнская плата', 5),
(4, 16, 'На штатной частоте работает нормально, но больше не гонится', 4),
(4, 10, 'За эти деньги хорошая видеокарта', 5),
(5, 10, 'Могла бы быть и побыстрее', 4),
(5, 18, 'Бюджетный жесткий диск', 5),
(6, 18, 'Нормальный диск для не игрового компьютера', 5),
(7, 15, 'Работает, не глючит', 5),
(8, 3, 'Мой экземпляр процессора разогнался на 200 МГц!', 5),
(9, 4, 'Хороший процессор', 5),
(10, 9, '', 5),
(11, 12, 'Материнская плата сренего уроня. Но все необходимое есть', 5),
(14, 3, '', 4),
(20, 17, '', 5);