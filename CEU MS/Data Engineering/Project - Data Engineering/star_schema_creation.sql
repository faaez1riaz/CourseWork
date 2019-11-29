-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `star_schema` DEFAULT CHARACTER SET utf8 ;
USE `star_schema` ;

-- -----------------------------------------------------
-- Table `star_schema`.`Country`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `star_schema`.`Country` (
  `Country_key` INT NOT NULL,
  `Team` VARCHAR(45) NULL,
  `NOC` VARCHAR(45) NULL,
  PRIMARY KEY (`Country_key`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `star_schema`.`Athlete information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `star_schema`.`Athlete information` (
  `Athlete_key` INT NOT NULL,
  `Name` VARCHAR(45) NULL,
  `Sex` VARCHAR(45) NULL,
  `Height` INT NULL,
  `Weight` INT NULL,
  PRIMARY KEY (`Athlete_key`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `star_schema`.`Games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `star_schema`.`Games` (
  `Games_key` INT NOT NULL,
  `Year` INT NULL,
  `Season` VARCHAR(45) NULL,
  `City` VARCHAR(45) NULL,
  PRIMARY KEY (`Games_key`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `star_schema`.`Event`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `star_schema`.`Event` (
  `Event ID` INT NOT NULL,
  `Event` VARCHAR(45) NULL,
  `Sports` VARCHAR(45) NULL,
  `Medal` VARCHAR(45) NULL,
  `Country_key` INT NULL,
  `Athlete_key` INT NULL,
  `Country_Country_key` INT NOT NULL,
  `Athlete information_Athlete_key` INT NOT NULL,
  `Games_key` INT NOT NULL,
  `gapminder_id` INT NULL,
  PRIMARY KEY (`Event ID`),
  INDEX `fk_Event_Country_idx` (`Country_Country_key` ASC),
  INDEX `fk_Event_Athlete information1_idx` (`Athlete information_Athlete_key` ASC),
  INDEX `fk_Event_Games1_idx` (`Games_key` ASC),
  CONSTRAINT `fk_Event_Country`
    FOREIGN KEY (`Country_Country_key`)
    REFERENCES `star_schema`.`Country` (`Country_key`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Event_Athlete information1`
    FOREIGN KEY (`Athlete information_Athlete_key`)
    REFERENCES `star_schema`.`Athlete information` (`Athlete_key`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Event_Games1`
    FOREIGN KEY (`Games_key`)
    REFERENCES `star_schema`.`Games` (`Games_key`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
CONSTRAINT `fk_gapminder`
    FOREIGN KEY (`gapminder_id`)
    REFERENCES `star_schema`.`gapminder` (`gapminder_id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE TABLE `gapminder` (
  `gapminder_id` int(11) NOT NULL AUTO_INCREMENT,
  `Country` varchar(200) DEFAULT NULL,
  `Year` int(11) DEFAULT NULL,
  `Population` int(11) DEFAULT NULL,
  `Continent` varchar(45) DEFAULT NULL,
  `lifExp` double DEFAULT NULL,
  `GDP_per_Capita` int(11) DEFAULT NULL,
  PRIMARY KEY (`gapminder_id`),
  UNIQUE KEY `gapminder_id_UNIQUE` (`gapminder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2048 DEFAULT CHARSET=latin1;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
