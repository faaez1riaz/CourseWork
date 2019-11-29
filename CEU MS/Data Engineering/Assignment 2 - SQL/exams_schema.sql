CREATE SCHEMA `exams_schema` ;

CREATE TABLE IF NOT EXISTS `exams_schema`.`courses_dimension` (
  `course_id` INT NOT NULL AUTO_INCREMENT,
  `course_name` VARCHAR(250) NOT NULL,
  `course_level` INT NULL,
  `course_instructor` INT NOT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE INDEX `course_id_UNIQUE` (`course_id` ASC));
    
CREATE TABLE IF NOT EXISTS `exams_schema`.`instructors_dimension` (
  `instructor_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(200) NULL,
  `last_name` VARCHAR(200) NULL,
  `status` INT NULL,
  `instructor_email` VARCHAR(100) NULL,
  PRIMARY KEY (`instructor_id`),
  UNIQUE INDEX `instructor_id_UNIQUE` (`instructor_id` ASC));
    
CREATE TABLE IF NOT EXISTS `exams_schema`.`students_dimension` (
  `student_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(250) NULL,
  `last_name` VARCHAR(250) NULL,
  `student_email` VARCHAR(250) NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE INDEX `student_id_UNIQUE` (`student_id` ASC));
  
  CREATE TABLE IF NOT EXISTS `exams_schema`.`departments_dimension` (
  `department_id` INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  `department_name` VARCHAR(250) NOT NULL,
  `department_phone` VARCHAR(45) NULL,
  `department_email` VARCHAR(45) NULL,
  `department_website` VARCHAR(45) NULL);
  
CREATE TABLE IF NOT EXISTS `exams_schema`.`programs_dimension` (
  `program_id` INT NOT NULL AUTO_INCREMENT UNIQUE primary KEY,
  `program_name` VARCHAR(250) NOT NULL,
  `home_department` INT NOT NULL,
  INDEX `home_department_idx` (`home_department` ASC));
  
  CREATE TABLE IF NOT EXISTS `exams_schema`.`exam_fact` (
  `exam_fact_id` INT NOT NULL AUTO_INCREMENT,
  `exam_id` INT NOT NULL,
  `exam_name` VARCHAR(250) NOT NULL,
  `max_score` INT NULL,
  `marks_obtained` INT NULL,
  `exam_date` DATETIME NULL,
  `student_id` INT NULL,
  `course_id` INT NOT NULL,
  `instructor_id` INT NULL,
  `program_id` INT NULL,
  `department_id` INT NULL,
  PRIMARY KEY (`exam_fact_id`),
  INDEX `exam_fact_id` (`exam_fact_id` ASC),
  INDEX `student_dim_idx` (`student_id` ASC),
  INDEX `instructor_dim_idx` (`instructor_id` ASC),
  INDEX `course_dim_idx` (`course_id` ASC),
  INDEX `program_dim_idx` (`program_id` ASC),
  INDEX `department_dim_idx` (`department_id` ASC),
  CONSTRAINT `student_dim`
    FOREIGN KEY (`student_id`)
    REFERENCES `exams_schema`.`students_dimension` (`student_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `instructor_dim`
    FOREIGN KEY (`instructor_id`)
    REFERENCES `exams_schema`.`instructors_dimension` (`instructor_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `course_dim`
    FOREIGN KEY (`course_id`)
    REFERENCES `exams_schema`.`courses_dimension` (`course_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `program_dim`
    FOREIGN KEY (`program_id`)
    REFERENCES `exams_schema`.`programs_dimension` (`program_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `department_dim`
	FOREIGN KEY (`department_id`)
	REFERENCES `exams_schema`.`departments_dimension` (`department_id`)
	ON DELETE RESTRICT
	ON UPDATE CASCADE);



    USE `exams_schema`;
DROP procedure IF EXISTS `edw_load_sp`;

DELIMITER $$
USE `exams_schema`$$
CREATE PROCEDURE `edw_load_sp` ()
BEGIN

INSERT INTO `exams_schema`.`instructors_dimension` (instructor_id,first_name, last_name,status,instructor_email) 
(select instructor_id,first_name, last_name,status,instructor_email 
from `ceu_database`.`instructors`);

INSERT INTO `exams_schema`.`courses_dimension` (course_id, course_name, course_level) 
(select course_id, course_name, course_level
from `ceu_database`.`courses`);

INSERT INTO `exams_schema`.`students_dimension` (student_id,first_name, last_name, student_email) 
(select student_id,first_name, last_name, student_email
from `ceu_database`.`students`);

INSERT INTO `exams_schema`.`programs_dimension` (program_id,program_name) 
(select program_id,program_name 
from `ceu_database`.`programs`);

INSERT INTO `exams_schema`.`departments_dimension` (department_id,department_name,department_phone,department_email, department_website) 
(select department_id,department_name,department_phone,department_email, department_website 
from `ceu_database`.`departments`);

Insert into `exams_schema`.`exam_fact` 
(exam_id, exam_name, max_score, marks_obtained, exam_date, student_id, course_id, instructor_id, program_id, department_id)
(select e.exam_id, e.exam_name, e.max_score, se.marks_obtained, se.date_exam, s.student_id, c.course_id, 
i.instructor_id, p.program_id, d.department_id
from `ceu_database`.`exams` e inner join `ceu_database`.`students_exams` se on e.exam_id = se.exam_id
inner join `ceu_database`.`students` s on se.student_id = s.student_id
inner join `ceu_database`.`courses` c on e.course_id = c.course_id
inner join `ceu_database`.`programs` p on  c.home_program = p.program_id
inner join `ceu_database`.`departments` d on p.home_department = d.department_id
inner join `ceu_database`.`instructors` i on  i.home_department = d.department_id);


END$$
DELIMITER ;

USE `exams_schema`;
CALL edw_load_sp();

CREATE VIEW prog_exam_summary AS
select d.department_name, count(e.exam_id) as total_exams_attempted, (sum(case when (e.marks_obtained/e.max_score)*100 > 50 then 1 else 0 end)/count(e.exam_id))*100
as passed_percentage, avg(e.marks_obtained) as average_obtained_marks, count(distinct instructor_id) as no_of_instructors, 
count(distinct e.course_id) as no_of_courses, count(distinct e.program_id) as no_of_programs
from `exams_schema`.`exam_fact` e inner join `exams_schema`.`departments_dimension` d  on e.department_id = d.department_id
inner join `exams_schema`.`courses_dimension` c on c.course_id = e.course_id
group by d.department_id;


















    
