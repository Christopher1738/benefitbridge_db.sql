-- BENEFITBRIDGE HR DATABASE SYSTEM
-- MySQL Assignment Solution
-- Developer: Christopher Simango (@Christopher1738)

-- Database Creation
DROP DATABASE IF EXISTS benefitbridge_hr;
CREATE DATABASE benefitbridge_hr;
USE benefitbridge_hr;

-- 1. CORE TABLES WITH CONSTRAINTS
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2) NOT NULL CHECK (budget > 0)
);

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    hire_date DATE NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    department_id INT NOT NULL,
    manager_id INT NULL,
    CONSTRAINT fk_department 
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_manager 
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE benefits (
    benefit_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
    category ENUM('Health', 'Retirement', 'Wellness', 'Other') NOT NULL
);

-- 2. RELATIONSHIP TABLES
CREATE TABLE employee_benefits (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    benefit_id INT NOT NULL,
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE NULL,
    CONSTRAINT fk_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_benefit
        FOREIGN KEY (benefit_id) REFERENCES benefits(benefit_id),
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date > start_date)
);

CREATE TABLE payroll (
    payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    pay_date DATE NOT NULL,
    gross_pay DECIMAL(10,2) NOT NULL,
    deductions DECIMAL(10,2) NOT NULL,
    net_pay DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_payroll_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_pay_values CHECK (gross_pay > 0 AND net_pay > 0)
);

-- 3. SAMPLE DATA INSERTION
INSERT INTO departments (name, location, budget) VALUES
('Human Resources', 'Floor 5', 500000.00),
('Engineering', 'Floor 3', 1200000.00),
('Finance', 'Floor 2', 750000.00);

INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, salary, department_id) VALUES
('John', 'Smith', 'john.smith@company.com', '+1234567890', '2020-01-15', 'HR Manager', 85000.00, 1),
('Sarah', 'Johnson', 'sarah.j@company.com', '+1234567891', '2021-03-22', 'Software Engineer', 95000.00, 2),
('Michael', 'Brown', 'michael.b@company.com', '+1234567892', '2022-06-10', 'Financial Analyst', 78000.00, 3);

INSERT INTO benefits (name, description, cost, category) VALUES
('Health Insurance', 'Comprehensive medical coverage', 200.00, 'Health'),
('401(k) Plan', 'Retirement savings plan with matching', 150.00, 'Retirement'),
('Gym Membership', 'Corporate gym discount program', 30.00, 'Wellness');

-- 4. INDEXES FOR PERFORMANCE
CREATE INDEX idx_employee_name ON employees(last_name, first_name);
CREATE INDEX idx_employee_department ON employees(department_id);
CREATE INDEX idx_benefit_category ON benefits(category);

-- 5. STORED PROCEDURE EXAMPLE
DELIMITER //
CREATE PROCEDURE CalculateEmployeeBenefitsCost(IN emp_id INT)
BEGIN
    SELECT e.first_name, e.last_name, SUM(b.cost) AS total_benefits_cost
    FROM employees e
    JOIN employee_benefits eb ON e.employee_id = eb.employee_id
    JOIN benefits b ON eb.benefit_id = b.benefit_id
    WHERE e.employee_id = emp_id
    GROUP BY e.employee_id;
END //
DELIMITER ;

-- 6. TRIGGER EXAMPLE
DELIMITER //
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be decreased';
    END IF;
END //
DELIMITER ;
