# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

> Расположение
  - БД:de
  - Схема:analysis
> Структура
- user_id-число (integer)
- recency-число (smallint)
- frequency-число (smallint)
- monetary_value-число (smallint)
> Период
- 2022 год
> Название витрины
- dm_rfm_segments
> Частота обновлений
- Без обновлений
> Успешный заказ — статус «Closed»


## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

Для расчета витрины понадобятся следующие поля:
> orders
- order_id
- order_ts
- user_id
- payment
- status

> users
- user_id

## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

Данные были проверены на дубли по id и парам тех значений, которые должны быть уникальны (например номер заказа и номер товара в таблице orderitems). Так же была проведена проверка на пропущенные значения в тех полях, которые нам понадобяться при расчете витрины.

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



## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
create view analysis.orders as
	select *
	from production.orders;

create view analysis.orderitems as
	select *
	from production.orderitems;

create view analysis.orderstatuses as
	select *
	from production.orderstatuses;

create view analysis.products as
	select *
	from production.products;

create view analysis.users as
	select *
	from production.users;


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE analysis.dm_rfm_segments (
    user_id         integer  not null PRIMARY KEY,
    recency         smallint not null CHECK (recency >= 1 and recency <=5),           
    frequency       smallint not null CHECK (recency >= 1 and recency <=5),           
    monetary_valye  smallint not null CHECK (recency >= 1 and recency <=5)
);


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
insert into dm_rfm_segments 
select u.id as user_id,
	trr.recency, 
	trf.frequency,
	trmv.monetary_value
from users u
join tmp_rfm_frequency trf on u.id = trf.user_id 
join tmp_rfm_monetary_value trmv on u.id = trmv.user_id 
join tmp_rfm_recency trr on u.id = trr.user_id ;


```



