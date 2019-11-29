CREATE SCHEMA `olympics_schema` ;

CREATE TABLE `olympics_schema`.`country_codes` (
  `NOC` CHAR(3) NOT NULL,
  `Country` VARCHAR(45) NULL,
  PRIMARY KEY (`NOC`),
  UNIQUE INDEX `NOC_UNIQUE` (`NOC` ASC));
  
  CREATE TABLE `olympics_schema`.`athletes_events` (
  `idathletes_events` INT NOT NULL,
  `Athelete Name` VARCHAR(200) NULL,
  `Sex` CHAR(1) NULL,
  `Age` INT NULL,
  `Height` INT NULL,
  `Weight` INT NULL,
  `NOC` CHAR(3) NULL,
  `Year` INT NULL,
  `Season` VARCHAR(12) NULL,
  `City` VARCHAR(45) NULL,
  `Sport` VARCHAR(45) NULL,
  PRIMARY KEY (`idathletes_events`),
  UNIQUE INDEX `idathletes_events_UNIQUE` (`idathletes_events` ASC),
  INDEX `NOC_idx` (`NOC` ASC),
  CONSTRAINT `NOC`
    FOREIGN KEY (`NOC`)
    REFERENCES `olympics_schema`.`country_codes` (`NOC`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    LOAD DATA INFILE 'departments.csv' INTO TABLE departments FIELDS TERMINATED BY ',' ENCLOSED BY '"'  LINES TERMINATED BY '\n' IGNORE 1 LINES;