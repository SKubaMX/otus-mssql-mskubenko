CREATE DATABASE CarRental;
GO

USE CarRental;
GO

-- 2. Создание основных таблиц с ограничениями и ключами
CREATE TABLE Brands (
    brand_id INT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    rental_cost_per_day INT CHECK (rental_cost_per_day > 0)
);
GO

CREATE TABLE Cars (
    car_id INT PRIMARY KEY,
    vin VARCHAR(50) UNIQUE NOT NULL,
    brand_id INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT CHECK (year > 1900),
    FOREIGN KEY (brand_id) REFERENCES Brands(brand_id)
);
GO

CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(50) CHECK (phone LIKE '+%'),
    email VARCHAR(50) CHECK (email LIKE '%@%'),
    driver_license VARCHAR(50) UNIQUE NOT NULL
);
GO

CREATE TABLE Contracts (
    contract_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    car_id INT NOT NULL,
    employee_id INT NOT NULL,
    start_date DATE DEFAULT GETDATE(),
    rental_days INT CHECK (rental_days > 0),
    daily_rate INT CHECK (daily_rate > 0),
    total_cost AS (daily_rate * rental_days),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);
GO

-- 3. Создание индексов
-- Для поиска автомобилей по марке
CREATE INDEX idx_cars_brand ON Cars(brand_id);
GO

-- Для быстрого поиска клиентов по правам
CREATE UNIQUE INDEX idx_clients_license ON Clients(driver_license);
GO