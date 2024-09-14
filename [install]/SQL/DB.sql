CREATE TABLE IF NOT EXISTS `active_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicle_net_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `officer_name` varchar(255) NOT NULL,
  `license_plate` varchar(20) NOT NULL,
  `is_paid` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_ticket_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `parking_meters` (
  `meter_id` int(11) NOT NULL AUTO_INCREMENT,
  `remaining_time` int(11) DEFAULT NULL,
  `paid_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`meter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
