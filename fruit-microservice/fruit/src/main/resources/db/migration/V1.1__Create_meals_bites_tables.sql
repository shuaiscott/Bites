CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create table MEALS (
    ID uuid DEFAULT uuid_generate_v4() primary key,
    CREATED_DATE timestamp not null,
    FRUIT_ID bigint references fruits(id) not null,
    BITES_LEFT int not null
);

create table BITES (
    ID bigserial not null primary key,
    CREATED_DATE timestamp not null,
    IP_ADDRESS varchar(15),
    MEAL_ID uuid references meals(id) not null
);
