-- bail_bonds.sql
CREATE TABLE IF NOT EXISTS `bail_bonds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizen_id` varchar(50) NOT NULL,
  `amount` int(11) NOT NULL,
  `expiry` int(11) NOT NULL,
  `paid` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_id` (`citizen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;