CREATE SCHEMA `CEU_database` ;

CREATE TABLE IF NOT EXISTS `ceu_database`.`departments` (
  `department_id` INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  `department_name` VARCHAR(250) NOT NULL,
  `department_phone` VARCHAR(45) NULL,
  `department_email` VARCHAR(45) NULL,
  `department_website` VARCHAR(45) NULL);
  
  CREATE TABLE `ceu_database`.`programs` (
  `program_id` INT NOT NULL AUTO_INCREMENT UNIQUE primary KEY,
  `program_name` VARCHAR(250) NOT NULL,
  `home_department` INT NOT NULL,
  INDEX `home_department_idx` (`home_department` ASC),
  CONSTRAINT `home_department`
    FOREIGN KEY (`home_department`)
    REFERENCES `ceu_database`.`departments` (`department_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT);
    
    CREATE TABLE `ceu_database`.`courses` (
  `course_id` INT NOT NULL AUTO_INCREMENT,
  `course_name` VARCHAR(250) NOT NULL,
  `home_program` INT NULL,
  `course_level` INT NULL,
  `course_instructor` INT NOT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE INDEX `course_id_UNIQUE` (`course_id` ASC),
  INDEX `course_program_mapping_idx` (`home_program` ASC),
  CONSTRAINT `course_program_mapping`
    FOREIGN KEY (`home_program`)
    REFERENCES `ceu_database`.`programs` (`program_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT);
    
    CREATE TABLE `ceu_database`.`instructors` (
  `instructor_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(200) NULL,
  `last_name` VARCHAR(200) NULL,
  `status` INT NULL,
  `instructor_email` VARCHAR(100) NULL,
  `home_department` INT NULL,
  PRIMARY KEY (`instructor_id`),
  UNIQUE INDEX `instructor_id_UNIQUE` (`instructor_id` ASC),
  INDEX `instructor_department_mapping_idx` (`home_department` ASC),
  CONSTRAINT `instructor_department_mapping`
    FOREIGN KEY (`home_department`)
    REFERENCES `ceu_database`.`departments` (`department_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    CREATE TABLE `ceu_database`.`students` (
  `student_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(250) NULL,
  `last_name` VARCHAR(250) NULL,
  `student_program` INT NULL,
  `student_email` VARCHAR(250) NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE INDEX `student_id_UNIQUE` (`student_id` ASC),
  INDEX `student_program_mapping_idx` (`student_program` ASC),
  CONSTRAINT `student_program_mapping`
    FOREIGN KEY (`student_program`)
    REFERENCES `ceu_database`.`programs` (`program_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    CREATE TABLE `ceu_database`.`exams` (
  `exam_id` INT NOT NULL AUTO_INCREMENT,
  `exam_name` VARCHAR(45) NOT NULL,
  `course_id` INT NULL,
  `max_score` INT NULL,
  PRIMARY KEY (`exam_id`),
  UNIQUE INDEX `exam_id_UNIQUE` (`exam_id` ASC),
  INDEX `course_exam_idx` (`course_id` ASC),
  CONSTRAINT `course_exam`
    FOREIGN KEY (`course_id`)
    REFERENCES `ceu_database`.`courses` (`course_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
    
    
CREATE TABLE `ceu_database`.`students_exams` (
  `exam_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `marks_obtained` INT NOT NULL,
  `date_exam` DATETIME,
  PRIMARY KEY (`exam_id`, `student_id`),
  INDEX `student_id_idx` (`student_id` ASC),
  CONSTRAINT `exams_id`
    FOREIGN KEY (`exam_id`)
    REFERENCES `ceu_database`.`exams` (`exam_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `student_id`
    FOREIGN KEY (`student_id`)
    REFERENCES `ceu_database`.`students` (`student_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
