create table FRUITS (
    ID serial not null primary key,
    CREATED_DATE timestamp not null,
    NAME varchar(100) not null,
    TOTAL_BITES int not null
);

INSERT INTO FRUITS
(name, created_date, total_bites)
VALUES('Apple', '2022-04-09', 5);
