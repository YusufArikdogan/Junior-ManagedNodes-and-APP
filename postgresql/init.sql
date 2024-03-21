CREATE DATABASE juniortodo;

\c juniortodo;

CREATE TABLE todo(
    todo_id SERIAL PRIMARY KEY,
    description VARCHAR(255)
);