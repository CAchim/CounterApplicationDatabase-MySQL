DROP TABLE IF EXISTS email_logs;

CREATE TABLE email_logs (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    email_to      VARCHAR(255) NOT NULL,
    subject       VARCHAR(255) NOT NULL,
    email_type    ENUM('OTP', 'ALERT', 'OWNER_CHANGE', 'RESET_WARNING') NOT NULL,
    status        ENUM('SENT', 'FAILED') NOT NULL DEFAULT 'SENT',
    error_message TEXT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
