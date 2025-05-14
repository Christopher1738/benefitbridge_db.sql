-- Database: benefitbridge_hr
CREATE DATABASE IF NOT EXISTS benefitbridge_hr;
USE benefitbridge_hr;

-- 1. TABLES WITH CONSTRAINTS
-- Employees Table (1-M with Departments, 1-M with Benefits)
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    department_id INT NOT NULL
);

-- Departments Table (1-M with Employees)
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    manager_id INT NULL
);

-- Benefits Table (M-M with Employees via enrollment)
CREATE TABLE benefits (
    benefit_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    cost DECIMAL(10,2) NOT NULL
);

-- Enrollment Junction Table (M-M relationship)
CREATE TABLE employee_benefits (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    benefit_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(benefit_id),
    CONSTRAINT unique_enrollment UNIQUE (employee_id, benefit_id)
);

-- 2. ADDITIONAL TABLES FOR REAL-WORLD COMPLEXITY
-- Salaries (1-1 with Employees)
CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 3. ADD CONSTRAINTS & RELATIONSHIPS
ALTER TABLE employees
ADD CONSTRAINT fk_department
FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE departments
ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- 4. SAMPLE DATA INSERTION
INSERT INTO departments (name) VALUES 
('Human Resources'),
('Engineering'),
('Finance');

INSERT INTO benefits (name, cost) VALUES
('Health Insurance', 200.00),
('Retirement Plan', 150.00),
('Gym Membership', 30.00);

-- 5. INDEXES FOR PERFORMANCE
CREATE INDEX idx_employee_email ON employees(email);
CREATE INDEX idx_department_name ON departments(name);
