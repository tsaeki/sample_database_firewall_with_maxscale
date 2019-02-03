CREATE DATABASE IF NOT EXISTS sampledb DEFAULT CHARACTER SET utf8;
CREATE TABLE IF NOT EXISTS sampledb.users (
    id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    zip VARCHAR(50),
    tel VARCHAR(50),
    credit_card_number VARCHAR(50)
);

CREATE USER `sample`@`%` IDENTIFIED BY 'sample_password';
GRANT ALL ON sampledb.* TO `sample`@`%`;

CREATE USER `maxscale`@`%` IDENTIFIED BY 'maxscale_password';
GRANT SELECT ON mysql.user TO `maxscale`@`%`;
GRANT SELECT ON mysql.db TO `maxscale`@`%`;
GRANT SELECT ON mysql.tables_priv TO `maxscale`@`%`;
GRANT SHOW DATABASES ON *.* TO `maxscale`@`%`;