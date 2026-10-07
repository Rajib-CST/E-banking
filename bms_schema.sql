-- Banking Management System - standalone MySQL / MariaDB script
-- Optional: the app creates all of this automatically on first start.
-- Run it manually with:  mysql -u root -p < bms_schema.sql

CREATE DATABASE IF NOT EXISTS bms_db CHARACTER SET utf8mb4;
USE bms_db;


CREATE TABLE IF NOT EXISTS branches (
  branch_id     INT AUTO_INCREMENT PRIMARY KEY,
  branch_name   VARCHAR(120) NOT NULL,
  ifsc_code     VARCHAR(20)  NOT NULL UNIQUE,
  manager_name  VARCHAR(100),
  email         VARCHAR(120),
  phone         VARCHAR(20),
  address       VARCHAR(255),
  city          VARCHAR(80),
  state         VARCHAR(80),
  status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
  customer_id   INT AUTO_INCREMENT PRIMARY KEY,
  first_name    VARCHAR(80)  NOT NULL,
  last_name     VARCHAR(80)  NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  mobile        VARCHAR(20),
  address       VARCHAR(255),
  aadhaar       VARCHAR(20),
  pan           VARCHAR(20),
  kyc_status    VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(80)  NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password      VARCHAR(255) NOT NULL,
  role          VARCHAR(20)  NOT NULL,
  customer_id   INT NULL,
  active        TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login    DATETIME NULL,
  CONSTRAINT fk_users_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS accounts (
  account_id     INT AUTO_INCREMENT PRIMARY KEY,
  account_number VARCHAR(20)   NOT NULL UNIQUE,
  account_type   VARCHAR(30)   NOT NULL,
  balance        DECIMAL(15,2) NOT NULL DEFAULT 0,
  status         VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
  customer_id    INT NOT NULL,
  branch_id      INT NULL,
  opened_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_acc_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
  CONSTRAINT fk_acc_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)   ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transactions (
  transaction_id   INT AUTO_INCREMENT PRIMARY KEY,
  account_id       INT NOT NULL,
  transaction_type VARCHAR(30)   NOT NULL,
  amount           DECIMAL(15,2) NOT NULL,
  balance_after    DECIMAL(15,2) NOT NULL,
  description      VARCHAR(255),
  transaction_date DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_txn_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
  INDEX idx_txn_account_date (account_id, transaction_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS loans (
  loan_id         INT AUTO_INCREMENT PRIMARY KEY,
  customer_id     INT NOT NULL,
  loan_type       VARCHAR(40)   NOT NULL,
  amount          DECIMAL(15,2) NOT NULL,
  interest_rate   DOUBLE        NOT NULL,
  duration_months INT           NOT NULL,
  emi             DECIMAL(15,2) NOT NULL,
  status          VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
  applied_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_loan_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS credit_cards (
  card_id            INT AUTO_INCREMENT PRIMARY KEY,
  customer_id        INT NOT NULL,
  card_number        VARCHAR(20) NULL UNIQUE,
  card_type          VARCHAR(30) NOT NULL,
  credit_limit       DECIMAL(15,2) NOT NULL,
  available_limit    DECIMAL(15,2) NOT NULL,
  outstanding_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  status             VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  expiry_date        DATE NULL,
  created_date       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_card_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS beneficiaries (
  beneficiary_id   INT AUTO_INCREMENT PRIMARY KEY,
  customer_id      INT NOT NULL,
  beneficiary_name VARCHAR(120) NOT NULL,
  account_number   VARCHAR(30)  NOT NULL,
  ifsc_code        VARCHAR(20),
  bank_name        VARCHAR(100),
  mobile_number    VARCHAR(20),
  status           VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  created_date     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ben_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nominees (
  nominee_id       INT AUTO_INCREMENT PRIMARY KEY,
  customer_id      INT NOT NULL,
  nominee_name     VARCHAR(120) NOT NULL,
  relationship     VARCHAR(50),
  mobile_number    VARCHAR(20),
  email            VARCHAR(120),
  address          VARCHAR(255),
  share_percentage DOUBLE NOT NULL DEFAULT 100,
  status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_nom_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employees (
  employee_id   INT AUTO_INCREMENT PRIMARY KEY,
  employee_code VARCHAR(30) NOT NULL UNIQUE,
  first_name    VARCHAR(80) NOT NULL,
  last_name     VARCHAR(80) NOT NULL,
  email         VARCHAR(120),
  mobile        VARCHAR(20),
  gender        VARCHAR(15),
  designation   VARCHAR(80),
  department    VARCHAR(80),
  salary        DECIMAL(12,2) NOT NULL DEFAULT 0,
  username      VARCHAR(80),
  role          VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE',
  status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  joining_date  DATE NULL,
  branch_id     INT NULL,
  CONSTRAINT fk_emp_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS support_tickets (
  ticket_id            INT AUTO_INCREMENT PRIMARY KEY,
  customer_id          INT NOT NULL,
  subject              VARCHAR(200) NOT NULL,
  description          VARCHAR(2000),
  category             VARCHAR(50),
  priority             VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
  status               VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  resolution_notes     VARCHAR(2000),
  created_date         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_date          DATETIME NULL,
  assigned_employee_id INT NULL,
  CONSTRAINT fk_tkt_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
  CONSTRAINT fk_tkt_employee FOREIGN KEY (assigned_employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT NOT NULL,
  title           VARCHAR(200) NOT NULL,
  message         VARCHAR(1000),
  type            VARCHAR(30) NOT NULL DEFAULT 'INFO',
  is_read         TINYINT(1)  NOT NULL DEFAULT 0,
  created_date    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  audit_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NULL,
  username      VARCHAR(80),
  role          VARCHAR(20),
  activity      VARCHAR(255),
  module_name   VARCHAR(120),
  ip_address    VARCHAR(60),
  status        VARCHAR(20),
  activity_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_time (activity_time)
) ENGINE=InnoDB;

-- First administrator (sign in with admin@bank.com / Admin@123, then add staff from the Employees page).
INSERT IGNORE INTO users (username, email, password, role, active) VALUES ('Admin', 'admin@bank.com', 'pbkdf2$120000$IMno4yVH7qhRtVlQV5rKHw==$fektJiCuMcYLsVMymbhq54c0AdVzOGLvbm9dwqmBs3Y=', 'ADMIN', 1);
