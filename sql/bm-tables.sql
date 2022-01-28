-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server versie:                10.4.21-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Versie:              11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Structuur van  tabel 5px-2.clients wordt geschreven
CREATE TABLE IF NOT EXISTS `clients` (
  `client_id` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `info` longtext NOT NULL,
  `perms` longtext NOT NULL,
  `queue` longtext NOT NULL,
  `identifiers` longtext NOT NULL,
  `first_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumpen data van tabel 5px-2.clients: ~0 rows (ongeveer)
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;

-- Structuur van  tabel 5px-2.client_bans wordt geschreven
CREATE TABLE IF NOT EXISTS `client_bans` (
  `client_id` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `expire` int(11) NOT NULL,
  `banned_by` varchar(255) DEFAULT NULL,
  `banned_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `edited_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `FK_client_bans_clients` (`client_id`),
  KEY `FK_client_bans_clients_2` (`banned_by`),
  CONSTRAINT `FK_client_bans_clients` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_client_bans_clients_2` FOREIGN KEY (`banned_by`) REFERENCES `clients` (`client_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumpen data van tabel 5px-2.client_bans: ~0 rows (ongeveer)
/*!40000 ALTER TABLE `client_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_bans` ENABLE KEYS */;

-- Structuur van  tabel 5px-2.client_warns wordt geschreven
CREATE TABLE IF NOT EXISTS `client_warns` (
  `client_id` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `warned_by` varchar(50) DEFAULT NULL,
  `warned_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `edited_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `FK_client_warns_clients` (`client_id`),
  KEY `FK_client_warns_clients_2` (`warned_by`),
  CONSTRAINT `FK_client_warns_clients` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_client_warns_clients_2` FOREIGN KEY (`warned_by`) REFERENCES `clients` (`client_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumpen data van tabel 5px-2.client_warns: ~0 rows (ongeveer)
/*!40000 ALTER TABLE `client_warns` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_warns` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
