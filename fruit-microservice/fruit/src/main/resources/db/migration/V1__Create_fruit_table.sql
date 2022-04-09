create table FRUITS (
    ID serial not null primary key,
    NAME varchar(100) not null,
    TOTALBITES int not null
);

INSERT INTO FRUITS
(name, totalbites)
VALUES('Apple', 5);
