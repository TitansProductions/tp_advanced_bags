
CREATE TABLE IF NOT EXISTS `bag_inventories` (
  `id` varchar(255) NOT NULL DEFAULT '0',
  `identifier` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `x` varchar(255) NOT NULL DEFAULT '0',
  `y` varchar(255) NOT NULL DEFAULT '0',
  `z` varchar(255) NOT NULL DEFAULT '0',
  `inventory` longtext DEFAULT '{}',
  `weapons` longtext DEFAULT '{}',
  `money` int(50) DEFAULT 0,
  `black_money` int(50) DEFAULT 0,
  `locked` int(2) DEFAULT 0,
  `lock_password` int(10) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `items` (`name`, `label`, `limit`) VALUES 
  ('bag', 'Bag', 1),
  ('luggage_lock', 'Luggage Lock', -1)
;