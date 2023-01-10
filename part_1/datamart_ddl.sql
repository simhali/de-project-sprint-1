CREATE TABLE analysis.dm_rfm_segments (
    user_id         integer  not null PRIMARY KEY,
    recency         smallint not null CHECK (recency >= 1 and recency <=5),           
    frequency       smallint not null CHECK (recency >= 1 and recency <=5),           
    monetary_valye  smallint not null CHECK (recency >= 1 and recency <=5)
);