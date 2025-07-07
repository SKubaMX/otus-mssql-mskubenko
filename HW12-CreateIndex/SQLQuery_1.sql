-- Индекс на Brands.name (для быстрого поиска по названию марки)
CREATE INDEX idx_brands_name ON Brands(name);

-- Для запроса "Страховки с истекающим сроком"
CREATE INDEX idx_insurance_end_date ON InsurancePolicies(end_date);

-- Для запроса "Авто марки со страховкой дешевле заданной" 
CREATE INDEX idx_policies_car_cost ON InsurancePolicies(car_id, cost);