CREATE DATABASE `steam` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

CREATE TABLE `Friends` (
  `user_id` int NOT NULL,
  `friend_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`friend_id`),
  KEY `friend_id` (`friend_id`),
  CONSTRAINT `Friends_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `Friends_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Game_Progress` (
  `progress_id` int NOT NULL,
  `user_id` int NOT NULL,
  `game_id` int NOT NULL,
  `achievements` int NOT NULL,
  `time_played` int NOT NULL,
  `last_played` date NOT NULL,
  PRIMARY KEY (`progress_id`),
  KEY `user_id` (`user_id`),
  KEY `game_id` (`game_id`),
  CONSTRAINT `Game_Progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `Game_Progress_ibfk_2` FOREIGN KEY (`game_id`) REFERENCES `Games` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Games` (
  `game_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `developer` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `genre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `release_date` date NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Payment_Methods` (
  `payment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `card_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration_date` date NOT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Payment_Methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Purchases` (
  `purchase_id` int NOT NULL,
  `game_id` int NOT NULL,
  `user_id` int NOT NULL,
  `purchase_date` date NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`purchase_id`),
  KEY `game_id` (`game_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Purchases_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `Games` (`game_id`),
  CONSTRAINT `Purchases_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Ratings` (
  `rating_id` int NOT NULL,
  `game_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` int NOT NULL,
  PRIMARY KEY (`rating_id`),
  KEY `game_id` (`game_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Ratings_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `Games` (`game_id`),
  CONSTRAINT `Ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Users` (
  `user_id` int NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `birthdate` date NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Virtual_Currency` (
  `currency_id` int NOT NULL,
  `user_id` int NOT NULL,
  `balance` decimal(10,2) NOT NULL,
  PRIMARY KEY (`currency_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Virtual_Currency_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `Virtual_Currency_Transaction` (
  `transaction_id` int NOT NULL,
  `user_id` int NOT NULL,
  `game_id` int NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'purchase',
  `amount` decimal(10,2) NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `user_id` (`user_id`),
  KEY `game_id` (`game_id`),
  CONSTRAINT `Virtual_Currency_Transaction_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `Virtual_Currency_Transaction_ibfk_2` FOREIGN KEY (`game_id`) REFERENCES `Games` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

