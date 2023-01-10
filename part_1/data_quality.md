# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
Данные были проверены на дубли по id и парам тех значений, которые должны быть уникальны (например номер заказа и номер товара в таблице orderitems). Так же была проведена проверка на пропущенные значения в тех полях, которые нам понадобяться при расчете витрины.

## Укажите, какие инструменты обеспечивают качество данных в источнике.
Ответ запишите в формате таблицы со следующими столбцами:
- `Наименование таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Здесь укажите название объекта в таблице, на который применён инструмент. Например, здесь стоит перечислить поля таблицы, индексы и т.д.
- `Инструмент` - тип инструмента: первичный ключ, ограничение или что-то ещё.
- `Для чего используется` - здесь в свободной форме опишите, что инструмент делает.


| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.products | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о товарах |
| production.products | name varchar(2048) NOT NULL | Ограничение на NULL  | Обеспечивает отсутствие пустых значений|
| production.products | price numeric(19, 5) NOT NULL DEFAULT 0 | Проверка CHECK ((price >= (0)::numeric)) | Обеспечивает положительное значение поля |
| production.orderitems | id int4 NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY | Генератор последовательности, первичный ключ | Автоматически создает значение поля и не предоставляет возможности указать его вручную  и обеспечивает уникальность записей|
| production.orderitems | orderitems_check CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Ограничение | Ограничение на то, чтобы значеине в поле discount было положительным или равнялось нулю, и было меньше либо равно значению в поле price|
| production.orderitems | CONSTRAINT orderitems_order_id_product_id_key UNIQUE (order_id, product_id) | Ограничение | Обеспечивает уникальность пары значений в полях order_id и  product_id|
| production.orderitems | СONSTRAINT orderitems_price_check CHECK ((price >= (0)::numeric)), | Проверка| Обеспечивает, что значение поля  price больше либо равно нулю|
| production.orderitems | CONSTRAINT orderitems_quantity_check CHECK ((quantity > 0))| Проверка |  Обеспечивает, что значение поля  quantity больше нуля|
| production.orders | CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment))), | Проверка | Обеспечивает, что сумма полей payment и  bonus_payment равна значению поля cost|
| production.orders | orders_pkey PRIMARY KEY (order_id) | Первичный ключ | Обеспечивает уникальность записей о заказах |
|  production.orderstatuses| CONSTRAINT orderstatuses_pkey PRIMARY KEY (id) | Первичный ключ|  Обеспечивает уникальность записей о статусах заказов|
| production.orderstatuslog | CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id), | Ограничение | Обеспечивает уникальность пары значений в полях order_id и  status_id| |
| production.orderstatuslog | CONSTRAINT orderstatuslog_pkey PRIMARY KEY (id) | Первичный ключ | Обеспечивает уникальность записей об изменениях статусов заказов |
| production.users | CONSTRAINT users_pkey PRIMARY KEY (id) | Первичный ключ | Обеспечивает уникальность записей о пользователях  |
