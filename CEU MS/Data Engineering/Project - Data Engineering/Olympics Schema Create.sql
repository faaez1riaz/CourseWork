Create schema `olympics`;

CREATE TABLE `olympcs`.`olympics_events` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `athletes_id` int(11) DEFAULT NULL,
  `Athelete Name` varchar(200) DEFAULT NULL,
  `Sex` char(1) DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  `Height` int(11) DEFAULT NULL,
  `Weight` int(11) DEFAULT NULL,
  `Team` varchar(45) DEFAULT NULL,
  `NOC` char(3) DEFAULT NULL,
  `GAMES` varchar(45) DEFAULT NULL,
  `Year` int(11) DEFAULT NULL,
  `Season` varchar(12) DEFAULT NULL,
  `City` varchar(45) DEFAULT NULL,
  `Sport` varchar(45) DEFAULT NULL,
  `Event` varchar(200) DEFAULT NULL,
  `Medals` varchar(45) DEFAULT NULL,
  `GDP_PPP` bigint(29) DEFAULT NULL,
  `GDP_per_cap` int(11) DEFAULT NULL,
  `Population` bigint(29) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `idathletes_events_UNIQUE` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=983026 DEFAULT CHARSET=latin1;
SELECT * FROM olympics.olympics_events;