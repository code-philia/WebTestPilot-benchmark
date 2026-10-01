-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: ninja
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `plan` enum('pro','enterprise','white_label') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_term` enum('month','year') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_started` date DEFAULT NULL,
  `plan_paid` date DEFAULT NULL,
  `plan_expires` date DEFAULT NULL,
  `user_agent` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_id` int unsigned DEFAULT NULL,
  `default_company_id` int unsigned NOT NULL,
  `trial_started` date DEFAULT NULL,
  `trial_plan` enum('pro','enterprise') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_price` decimal(7,2) DEFAULT NULL,
  `num_users` smallint NOT NULL DEFAULT '1',
  `utm_source` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_medium` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_campaign` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_term` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_content` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latest_version` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0.0.0',
  `report_errors` tinyint(1) NOT NULL DEFAULT '0',
  `referral_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `is_scheduler_running` tinyint(1) NOT NULL DEFAULT '0',
  `trial_duration` int unsigned DEFAULT NULL,
  `is_onboarding` tinyint(1) NOT NULL DEFAULT '0',
  `onboarding` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_migrated` tinyint(1) NOT NULL DEFAULT '0',
  `platform` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hosted_client_count` int unsigned DEFAULT NULL,
  `hosted_company_count` int unsigned DEFAULT NULL,
  `inapp_transaction_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `set_react_as_default_ap` tinyint(1) NOT NULL DEFAULT '1',
  `is_flagged` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified_account` tinyint(1) NOT NULL DEFAULT '0',
  `account_sms_verification_code` text COLLATE utf8mb4_unicode_ci,
  `account_sms_verification_number` text COLLATE utf8mb4_unicode_ci,
  `account_sms_verified` tinyint(1) NOT NULL DEFAULT '0',
  `bank_integration_account_id` text COLLATE utf8mb4_unicode_ci,
  `is_trial` tinyint(1) NOT NULL DEFAULT '0',
  `email_quota` int DEFAULT NULL,
  `e_invoice_quota` int unsigned NOT NULL DEFAULT '0',
  `e_invoicing_token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_payment_id_index` (`payment_id`),
  KEY `accounts_key_index` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,NULL,NULL,NULL,NULL,NULL,NULL,'F7v5gzr0itc8Yx8xPFjsjAq6YfBE3VTz',NULL,1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'0.0.0',1,'qdkyxptgdntnpp40kajoo0q3bvorghya','2026-09-16 07:56:53.947351','2026-09-16 07:56:53.980884',0,NULL,0,NULL,0,NULL,NULL,NULL,NULL,1,0,0,NULL,NULL,0,NULL,0,NULL,0,NULL);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `client_contact_id` int unsigned DEFAULT NULL,
  `account_id` int unsigned DEFAULT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `payment_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `credit_id` int unsigned DEFAULT NULL,
  `invitation_id` int unsigned DEFAULT NULL,
  `task_id` int unsigned DEFAULT NULL,
  `expense_id` int unsigned DEFAULT NULL,
  `activity_type_id` int unsigned DEFAULT NULL,
  `ip` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `token_id` int unsigned DEFAULT NULL,
  `quote_id` int unsigned DEFAULT NULL,
  `subscription_id` int unsigned DEFAULT NULL,
  `recurring_invoice_id` int unsigned DEFAULT NULL,
  `recurring_expense_id` int unsigned DEFAULT NULL,
  `recurring_quote_id` int unsigned DEFAULT NULL,
  `purchase_order_id` int unsigned DEFAULT NULL,
  `vendor_contact_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activities_vendor_id_company_id_index` (`vendor_id`,`company_id`),
  KEY `activities_project_id_company_id_index` (`project_id`,`company_id`),
  KEY `activities_user_id_company_id_index` (`user_id`,`company_id`),
  KEY `activities_client_id_company_id_index` (`client_id`,`company_id`),
  KEY `activities_payment_id_company_id_index` (`payment_id`,`company_id`),
  KEY `activities_invoice_id_company_id_index` (`invoice_id`,`company_id`),
  KEY `activities_credit_id_company_id_index` (`credit_id`,`company_id`),
  KEY `activities_invitation_id_company_id_index` (`invitation_id`,`company_id`),
  KEY `activities_task_id_company_id_index` (`task_id`,`company_id`),
  KEY `activities_expense_id_company_id_index` (`expense_id`,`company_id`),
  KEY `activities_client_contact_id_company_id_index` (`client_contact_id`,`company_id`),
  KEY `activities_company_id_foreign` (`company_id`),
  KEY `activities_quote_id_company_id_index` (`quote_id`,`company_id`),
  KEY `activities_recurring_invoice_id_company_id_index` (`recurring_invoice_id`,`company_id`),
  KEY `activities_purchase_order_id_company_id_index` (`purchase_order_id`,`company_id`),
  KEY `activities_vendor_contact_id_company_id_index` (`vendor_contact_id`,`company_id`),
  CONSTRAINT `activities_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backups`
--

DROP TABLE IF EXISTS `backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `activity_id` int unsigned NOT NULL,
  `json_backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `amount` decimal(16,4) NOT NULL,
  `filename` text COLLATE utf8mb4_unicode_ci,
  `disk` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `backups_activity_id_foreign` (`activity_id`),
  CONSTRAINT `backups_activity_id_foreign` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups`
--

LOCK TABLES `backups` WRITE;
/*!40000 ALTER TABLE `backups` DISABLE KEYS */;
/*!40000 ALTER TABLE `backups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_companies`
--

DROP TABLE IF EXISTS `bank_companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `bank_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `username` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bank_companies_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `bank_companies_user_id_foreign` (`user_id`),
  KEY `bank_companies_bank_id_foreign` (`bank_id`),
  CONSTRAINT `bank_companies_bank_id_foreign` FOREIGN KEY (`bank_id`) REFERENCES `banks` (`id`),
  CONSTRAINT `bank_companies_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_companies_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_companies`
--

LOCK TABLES `bank_companies` WRITE;
/*!40000 ALTER TABLE `bank_companies` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank_companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_integrations`
--

DROP TABLE IF EXISTS `bank_integrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_integrations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int unsigned NOT NULL,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `provider_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_id` bigint NOT NULL,
  `bank_account_id` bigint NOT NULL,
  `bank_account_name` text COLLATE utf8mb4_unicode_ci,
  `bank_account_number` text COLLATE utf8mb4_unicode_ci,
  `bank_account_status` text COLLATE utf8mb4_unicode_ci,
  `bank_account_type` text COLLATE utf8mb4_unicode_ci,
  `balance` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `currency` text COLLATE utf8mb4_unicode_ci,
  `nickname` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_date` date DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `disabled_upstream` tinyint(1) NOT NULL DEFAULT '0',
  `auto_sync` tinyint(1) NOT NULL DEFAULT '0',
  `integration_type` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nordigen_account_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nordigen_institution_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bank_integrations_user_id_foreign` (`user_id`),
  KEY `bank_integrations_account_id_foreign` (`account_id`),
  KEY `bank_integrations_company_id_foreign` (`company_id`),
  CONSTRAINT `bank_integrations_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_integrations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_integrations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_integrations`
--

LOCK TABLES `bank_integrations` WRITE;
/*!40000 ALTER TABLE `bank_integrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank_integrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_subcompanies`
--

DROP TABLE IF EXISTS `bank_subcompanies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_subcompanies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `bank_company_id` int unsigned NOT NULL,
  `account_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bank_subcompanies_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `bank_subcompanies_user_id_foreign` (`user_id`),
  KEY `bank_subcompanies_bank_company_id_foreign` (`bank_company_id`),
  CONSTRAINT `bank_subcompanies_bank_company_id_foreign` FOREIGN KEY (`bank_company_id`) REFERENCES `bank_companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_subcompanies_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_subcompanies_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_subcompanies`
--

LOCK TABLES `bank_subcompanies` WRITE;
/*!40000 ALTER TABLE `bank_subcompanies` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank_subcompanies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_transaction_rules`
--

DROP TABLE IF EXISTS `bank_transaction_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_transaction_rules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rules` mediumtext COLLATE utf8mb4_unicode_ci,
  `auto_convert` tinyint(1) NOT NULL DEFAULT '0',
  `matches_on_all` tinyint(1) NOT NULL DEFAULT '0',
  `applies_to` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CREDIT',
  `client_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `on_credit_match` enum('create_payment','link_payment') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'create_payment',
  PRIMARY KEY (`id`),
  KEY `bank_transaction_rules_user_id_foreign` (`user_id`),
  KEY `bank_transaction_rules_company_id_foreign` (`company_id`),
  CONSTRAINT `bank_transaction_rules_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_transaction_rules_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_transaction_rules`
--

LOCK TABLES `bank_transaction_rules` WRITE;
/*!40000 ALTER TABLE `bank_transaction_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank_transaction_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bank_transactions`
--

DROP TABLE IF EXISTS `bank_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `bank_integration_id` bigint unsigned NOT NULL,
  `transaction_id` bigint unsigned NOT NULL,
  `amount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `currency_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `account_type` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `ninja_category_id` int unsigned DEFAULT NULL,
  `category_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date DEFAULT NULL,
  `bank_account_id` bigint unsigned NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `invoice_ids` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `expense_id` text COLLATE utf8mb4_unicode_ci,
  `vendor_id` int unsigned DEFAULT NULL,
  `status_id` int unsigned NOT NULL DEFAULT '1',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `bank_transaction_rule_id` bigint DEFAULT NULL,
  `payment_id` int unsigned DEFAULT NULL,
  `participant` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `participant_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nordigen_transaction_id` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `bank_transactions_bank_integration_id_foreign` (`bank_integration_id`),
  KEY `bank_transactions_user_id_foreign` (`user_id`),
  KEY `bank_transactions_company_id_foreign` (`company_id`),
  KEY `bank_transactions_transaction_id_index` (`transaction_id`),
  KEY `bank_transactions_category_type_index` (`category_type`),
  KEY `bank_transactions_base_type_index` (`base_type`),
  CONSTRAINT `bank_transactions_bank_integration_id_foreign` FOREIGN KEY (`bank_integration_id`) REFERENCES `bank_integrations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_transactions_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bank_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bank_transactions`
--

LOCK TABLES `bank_transactions` WRITE;
/*!40000 ALTER TABLE `bank_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `banks`
--

DROP TABLE IF EXISTS `banks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `banks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remote_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_library_id` int NOT NULL DEFAULT '1',
  `config` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=387 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banks`
--

LOCK TABLES `banks` WRITE;
/*!40000 ALTER TABLE `banks` DISABLE KEYS */;
INSERT INTO `banks` VALUES (1,'ING DIRECT (Canada)','421',1,'{\"fid\":\"061400152\",\"org\":\"INGDirectCanada\",\"url\":\"https:\\/\\/ofx.ingdirect.ca\"}'),(2,'Safe Credit Union - OFX Beta','422',1,'{\"fid\":\"321173742\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxcert.diginsite.com\\/cmr\\/cmr.ofx\"}'),(3,'Ascentra Credit Union','423',1,'{\"fid\":\"273973456\",\"org\":\"Alcoa Employees&Community CU\",\"url\":\"https:\\/\\/alc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(4,'American Express Card','424',1,'{\"fid\":\"3101\",\"org\":\"AMEX\",\"url\":\"https:\\/\\/online.americanexpress.com\\/myca\\/ofxdl\\/desktop\\/desktopDownload.do?request_type=nl_ofxdownload\"}'),(5,'TD Ameritrade','425',1,'{\"fid\":\"5024\",\"org\":\"ameritrade.com\",\"url\":\"https:\\/\\/ofxs.ameritrade.com\\/cgi-bin\\/apps\\/OFX\"}'),(6,'Truliant FCU','426',1,'{\"fid\":\"253177832\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(7,'AT&T Universal Card','427',1,'{\"fid\":\"24909\",\"org\":\"Citigroup\",\"url\":\"https:\\/\\/secureofx2.bankhost.com\\/citi\\/cgi-forte\\/ofx_rt?servicename=ofx_rt&pagename=ofx\"}'),(8,'Bank One','428',1,'{\"fid\":\"5811\",\"org\":\"B1\",\"url\":\"https:\\/\\/onlineofx.chase.com\\/chase.ofx\"}'),(9,'Bank of Stockton','429',1,'{\"fid\":\"3901\",\"org\":\"BOS\",\"url\":\"https:\\/\\/internetbanking.bankofstockton.com\\/scripts\\/serverext.dll\"}'),(10,'Bank of the Cascades','430',1,'{\"fid\":\"4751\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(11,'Centra Credit Union','431',1,'{\"fid\":\"274972883\",\"org\":\"Centra CU\",\"url\":\"https:\\/\\/centralink.org\\/scripts\\/isaofx.dll\"}'),(12,'Centura Bank','432',1,'{\"fid\":\"1901\",\"org\":\"Centura Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1901.ofxgp\"}'),(13,'Charles Schwab&Co., INC','433',1,'{\"fid\":\"5104\",\"org\":\"ISC\",\"url\":\"https:\\/\\/ofx.schwab.com\\/cgi_dev\\/ofx_server\"}'),(14,'JPMorgan Chase Bank (Texas)','434',1,'{\"fid\":\"5301\",\"org\":\"Chase Bank of Texas\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/5301.ofxgp\"}'),(15,'JPMorgan Chase Bank','435',1,'{\"fid\":\"1601\",\"org\":\"Chase Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1601.ofxgp\"}'),(16,'Colonial Bank','436',1,'{\"fid\":\"1046\",\"org\":\"Colonial Banc Group\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1046.ofxgp\"}'),(17,'Comerica Bank','437',1,'{\"fid\":\"5601\",\"org\":\"Comerica\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/5601.ofxgp\"}'),(18,'Commerce Bank NJ, PA, NY&DE','438',1,'{\"fid\":\"1001\",\"org\":\"CommerceBank\",\"url\":\"https:\\/\\/www.commerceonlinebanking.com\\/scripts\\/serverext.dll\"}'),(19,'Commerce Bank, NA','439',1,'{\"fid\":\"4001\",\"org\":\"Commerce Bank NA\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/4001.ofxgp\"}'),(20,'Commercial Federal Bank','440',1,'{\"fid\":\"4801\",\"org\":\"CommercialFederalBank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/4801.ofxgp\"}'),(21,'COMSTAR FCU','441',1,'{\"fid\":\"255074988\",\"org\":\"Comstar Federal Credit Union\",\"url\":\"https:\\/\\/pcu.comstarfcu.org\\/scripts\\/isaofx.dll\"}'),(22,'SunTrust','442',1,'{\"fid\":\"2801\",\"org\":\"SunTrust PC Banking\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/2801.ofxgp\"}'),(23,'Denali Alaskan FCU','443',1,'{\"fid\":\"1\",\"org\":\"Denali Alaskan FCU\",\"url\":\"https:\\/\\/remotebanking.denalifcu.com\\/ofx\\/ofx.dll\"}'),(24,'Discover Card','444',1,'{\"fid\":\"7101\",\"org\":\"Discover Financial Services\",\"url\":\"https:\\/\\/ofx.discovercard.com\"}'),(25,'E*TRADE','446',1,'{\"fid\":\"fldProv_mProvBankId\",\"org\":\"fldProv_mId\",\"url\":\"https:\\/\\/ofx.etrade.com\\/cgi-ofx\\/etradeofx\"}'),(26,'Eastern Bank','447',1,'{\"fid\":\"6201\",\"org\":\"Eastern Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/6201.ofxgp\"}'),(27,'EDS Credit Union','448',1,'{\"fid\":\"311079474\",\"org\":\"EDS CU\",\"url\":\"https:\\/\\/eds.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(28,'Fidelity Investments','449',1,'{\"fid\":\"7776\",\"org\":\"fidelity.com\",\"url\":\"https:\\/\\/ofx.fidelity.com\\/ftgw\\/OFX\\/clients\\/download\"}'),(29,'Fifth Third Bancorp','450',1,'{\"fid\":\"5829\",\"org\":\"Fifth Third Bank\",\"url\":\"https:\\/\\/banking.53.com\\/ofx\\/OFXServlet\"}'),(30,'First Tech Credit Union','451',1,'{\"fid\":\"2243\",\"org\":\"First Tech Credit Union\",\"url\":\"https:\\/\\/ofx.firsttechcu.com\"}'),(31,'zWachovia','452',1,'{\"fid\":\"4301\",\"org\":\"Wachovia\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/4301.ofxgp\"}'),(32,'KeyBank','453',1,'{\"fid\":\"5901\",\"org\":\"KeyBank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/05901.ofx\"}'),(33,'Mellon Bank','454',1,'{\"fid\":\"1226\",\"org\":\"Mellon Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1226.ofxgp\"}'),(34,'LaSalle Bank Midwest','455',1,'{\"fid\":\"1101\",\"org\":\"LaSalleBankMidwest\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1101.ofxgp\"}'),(35,'Nantucket Bank','456',1,'{\"fid\":\"466\",\"org\":\"Nantucket\",\"url\":\"https:\\/\\/ofx.onlinencr.com\\/scripts\\/serverext.dll\"}'),(36,'National Penn Bank','457',1,'{\"fid\":\"6301\",\"org\":\"National Penn Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/6301.ofxgp\"}'),(37,'Nevada State Bank - New','458',1,'{\"fid\":\"1121\",\"org\":\"295-3\",\"url\":\"https:\\/\\/quicken.metavante.com\\/ofx\\/OFXServlet\"}'),(38,'UBS Financial Services Inc.','459',1,'{\"fid\":\"7772\",\"org\":\"Intuit\",\"url\":\"https:\\/\\/ofx1.ubs.com\\/eftxweb\\/access.ofx\"}'),(39,'Patelco CU','460',1,'{\"fid\":\"2000\",\"org\":\"Patelco Credit Union\",\"url\":\"https:\\/\\/ofx.patelco.org\"}'),(40,'Mercantile Brokerage Services','461',1,'{\"fid\":\"011\",\"org\":\"Mercantile Brokerage\",\"url\":\"https:\\/\\/ofx.netxclient.com\\/cgi\\/OFXNetx\"}'),(41,'Regions Bank','462',1,'{\"fid\":\"243\",\"org\":\"regions.com\",\"url\":\"https:\\/\\/ofx.morgankeegan.com\\/begasp\\/directtocore.asp\"}'),(42,'Spectrum Connect/Reich&Tang','463',1,'{\"fid\":\"6510\",\"org\":\"SpectrumConnect\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/6510.ofxgp\"}'),(43,'Smith Barney - Transactions','464',1,'{\"fid\":\"3201\",\"org\":\"SmithBarney\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/3201.ofxgp\"}'),(44,'Southwest Airlines FCU','465',1,'{\"fid\":\"311090673\",\"org\":\"Southwest Airlines EFCU\",\"url\":\"https:\\/\\/www.swacuflashbp.org\\/scripts\\/isaofx.dll\"}'),(45,'Technology Credit Union - CA','467',1,'{\"fid\":\"11257\",\"org\":\"Tech CU\",\"url\":\"https:\\/\\/webbranchofx.techcu.com\\/TekPortalOFX\\/servlet\\/TP_OFX_Controller\"}'),(46,'UMB Bank','468',1,'{\"fid\":\"0\",\"org\":\"UMB\",\"url\":\"https:\\/\\/pcbanking.umb.com\\/hs_ofx\\/hsofx.dll\"}'),(47,'Union Bank of California','469',1,'{\"fid\":\"2901\",\"org\":\"Union Bank of California\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/2901.ofxgp\"}'),(48,'United Teletech Financial','470',1,'{\"fid\":\"221276011\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxcore.digitalinsight.com:443\\/servlet\\/OFXCoreServlet\"}'),(49,'US Bank','471',1,'{\"fid\":\"1401\",\"org\":\"US Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1401.ofxgp\"}'),(50,'Bank of America (All except CA, WA,&ID)','472',1,'{\"fid\":\"6812\",\"org\":\"HAN\",\"url\":\"https:\\/\\/ofx.bankofamerica.com\\/cgi-forte\\/fortecgi?servicename=ofx_2-3&pagename=ofx\"}'),(51,'Wells Fargo','473',1,'{\"fid\":\"3000\",\"org\":\"WF\",\"url\":\"https:\\/\\/ofxdc.wellsfargo.com\\/ofx\\/process.ofx\"}'),(52,'LaSalle Bank NA','474',1,'{\"fid\":\"6501\",\"org\":\"LaSalle Bank NA\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/6501.ofxgp\"}'),(53,'BB&T','475',1,'{\"fid\":\"BB&T\",\"org\":\"BB&T\",\"url\":\"https:\\/\\/eftx.bbt.com\\/eftxweb\\/access.ofx\"}'),(54,'Los Alamos National Bank','476',1,'{\"fid\":\"107001012\",\"org\":\"LANB\",\"url\":\"https:\\/\\/ofx.lanb.com\\/ofx\\/ofxrelay.dll\"}'),(55,'Citadel FCU','477',1,'{\"fid\":\"citadel\",\"org\":\"CitadelFCU\",\"url\":\"https:\\/\\/pcu.citadelfcu.org\\/scripts\\/isaofx.dll\"}'),(56,'Clearview Federal Credit Union','478',1,'{\"fid\":\"243083237\",\"org\":\"Clearview Federal Credit Union\",\"url\":\"https:\\/\\/www.pcu.clearviewfcu.org\\/scripts\\/isaofx.dll\"}'),(57,'Vanguard Group, The','479',1,'{\"fid\":\"1358\",\"org\":\"The Vanguard Group\",\"url\":\"https:\\/\\/vesnc.vanguard.com\\/us\\/OfxDirectConnectServlet\"}'),(58,'First Citizens Bank - NC, VA, WV','480',1,'{\"fid\":\"5013\",\"org\":\"First Citizens Bank NC, VA, WV\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/5013.ofxgp\"}'),(59,'Northern Trust - Banking','481',1,'{\"fid\":\"5804\",\"org\":\"ORG\",\"url\":\"https:\\/\\/www3883.ntrs.com\\/nta\\/ofxservlet\"}'),(60,'The Mechanics Bank','482',1,'{\"fid\":\"121102036\",\"org\":\"TMB\",\"url\":\"https:\\/\\/ofx.mechbank.com\\/OFXServer\\/ofxsrvr.dll\"}'),(61,'USAA Federal Savings Bank','483',1,'{\"fid\":\"24591\",\"org\":\"USAA\",\"url\":\"https:\\/\\/service2.usaa.com\\/ofx\\/OFXServlet\"}'),(62,'Florida Telco CU','484',1,'{\"fid\":\"FTCU\",\"org\":\"FloridaTelcoCU\",\"url\":\"https:\\/\\/ppc.floridatelco.org\\/scripts\\/isaofx.dll\"}'),(63,'DuPont Community Credit Union','485',1,'{\"fid\":\"251483311\",\"org\":\"DuPont Community Credit Union\",\"url\":\"https:\\/\\/pcu.mydccu.com\\/scripts\\/isaofx.dll\"}'),(64,'Central Florida Educators FCU','486',1,'{\"fid\":\"590678236\",\"org\":\"CentralFloridaEduc\",\"url\":\"https:\\/\\/www.mattweb.cfefcu.com\\/scripts\\/isaofx.dll\"}'),(65,'California Bank&Trust','487',1,'{\"fid\":\"5006\",\"org\":\"401\",\"url\":\"https:\\/\\/pfm.metavante.com\\/ofx\\/OFXServlet\"}'),(66,'First Commonwealth FCU','488',1,'{\"fid\":\"231379199\",\"org\":\"FirstCommonwealthFCU\",\"url\":\"https:\\/\\/pcu.firstcomcu.org\\/scripts\\/isaofx.dll\"}'),(67,'Ameriprise Financial Services, Inc.','489',1,'{\"fid\":\"3102\",\"org\":\"AMPF\",\"url\":\"https:\\/\\/www25.ameriprise.com\\/AMPFWeb\\/ofxdl\\/us\\/download?request_type=nl_desktopdownload\"}'),(68,'AltaOne Federal Credit Union','490',1,'{\"fid\":\"322274462\",\"org\":\"AltaOneFCU\",\"url\":\"https:\\/\\/pcu.altaone.org\\/scripts\\/isaofx.dll\"}'),(69,'A. G. Edwards and Sons, Inc.','491',1,'{\"fid\":\"43-0895447\",\"org\":\"A.G. Edwards\",\"url\":\"https:\\/\\/ofx.agedwards.com\"}'),(70,'Educational Employees CU Fresno','492',1,'{\"fid\":\"321172594\",\"org\":\"Educational Employees C U\",\"url\":\"https:\\/\\/www.eecuonline.org\\/scripts\\/isaofx.dll\"}'),(71,'Hawthorne Credit Union','493',1,'{\"fid\":\"271979193\",\"org\":\"Hawthorne Credit Union\",\"url\":\"https:\\/\\/hwt.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(72,'Firstar','494',1,'{\"fid\":\"1255\",\"org\":\"Firstar\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/1255.ofxgp\"}'),(73,'myStreetscape','495',1,'{\"fid\":\"7784\",\"org\":\"Fidelity\",\"url\":\"https:\\/\\/ofx.ibgstreetscape.com:443\"}'),(74,'Collegedale Credit Union','496',1,'{\"fid\":\"35GFA\",\"org\":\"CollegedaleCU\",\"url\":\"https:\\/\\/www.netit.financial-net.com\\/ofx\"}'),(75,'GCS Federal Credit Union','498',1,'{\"fid\":\"281076853\",\"org\":\"Granite City Steel cu\",\"url\":\"https:\\/\\/pcu.mygcscu.com\\/scripts\\/isaofx.dll\"}'),(76,'Vantage Credit Union','499',1,'{\"fid\":\"281081479\",\"org\":\"EECU-St. Louis\",\"url\":\"https:\\/\\/secure2.eecu.com\\/scripts\\/isaofx.dll\"}'),(77,'Morgan Stanley ClientServ','500',1,'{\"fid\":\"1235\",\"org\":\"msdw.com\",\"url\":\"https:\\/\\/ofx.morganstanleyclientserv.com\\/ofx\\/ProfileMSMoney.ofx\"}'),(78,'Kennedy Space Center FCU','501',1,'{\"fid\":\"263179532\",\"org\":\"Kennedy Space Center FCU\",\"url\":\"https:\\/\\/www.pcu.kscfcu.org\\/scripts\\/isaofx.dll\"}'),(79,'Sierra Central Credit Union','502',1,'{\"fid\":\"321174770\",\"org\":\"Sierra Central Credit Union\",\"url\":\"https:\\/\\/www.sierracpu.com\\/scripts\\/isaofx.dll\"}'),(80,'Virginia Educators Credit Union','503',1,'{\"fid\":\"251481355\",\"org\":\"Virginia Educators CU\",\"url\":\"https:\\/\\/www.vecumoneylink.org\\/scripts\\/isaofx.dll\"}'),(81,'Red Crown Federal Credit Union','504',1,'{\"fid\":\"303986148\",\"org\":\"Red Crown FCU\",\"url\":\"https:\\/\\/cre.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(82,'B-M S Federal Credit Union','505',1,'{\"fid\":\"221277007\",\"org\":\"B-M S Federal Credit Union\",\"url\":\"https:\\/\\/bms.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(83,'Fort Stewart GeorgiaFCU','506',1,'{\"fid\":\"261271364\",\"org\":\"Fort Stewart FCU\",\"url\":\"https:\\/\\/fsg.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(84,'Northern Trust - Investments','507',1,'{\"fid\":\"6028\",\"org\":\"Northern Trust Investments\",\"url\":\"https:\\/\\/www3883.ntrs.com\\/nta\\/ofxservlet?accounttypegroup=INV\"}'),(85,'Picatinny Federal Credit Union','508',1,'{\"fid\":\"221275216\",\"org\":\"Picatinny Federal Credit Union\",\"url\":\"https:\\/\\/banking.picacreditunion.com\\/scripts\\/isaofx.dll\"}'),(86,'SAC FEDERAL CREDIT UNION','509',1,'{\"fid\":\"091901480\",\"org\":\"SAC Federal CU\",\"url\":\"https:\\/\\/pcu.sacfcu.com\\/scripts\\/isaofx.dll\"}'),(87,'Merrill Lynch&Co., Inc.','510',1,'{\"fid\":\"5550\",\"org\":\"Merrill Lynch & Co., Inc.\",\"url\":\"https:\\/\\/taxcert.mlol.ml.com\\/eftxweb\\/access.ofx\"}'),(88,'Southeastern CU','511',1,'{\"fid\":\"261271500\",\"org\":\"Southeastern FCU\",\"url\":\"https:\\/\\/moo.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(89,'Texas Dow Employees Credit Union','512',1,'{\"fid\":\"313185515\",\"org\":\"TexasDow\",\"url\":\"https:\\/\\/allthetime.tdecu.org\\/scripts\\/isaofx.dll\"}'),(90,'University Federal Credit Union','513',1,'{\"fid\":\"314977405\",\"org\":\"Univerisity FCU\",\"url\":\"https:\\/\\/OnDemand.ufcu.org\\/scripts\\/isaofx.dll\"}'),(91,'Yakima Valley Credit Union','514',1,'{\"fid\":\"325183796\",\"org\":\"Yakima Valley Credit Union\",\"url\":\"https:\\/\\/secure1.yvcu.org\\/scripts\\/isaofx.dll\"}'),(92,'First Community FCU','515',1,'{\"fid\":\"272483633\",\"org\":\"FirstCommunityFCU\",\"url\":\"https:\\/\\/pcu.1stcomm.org\\/scripts\\/isaofx.dll\"}'),(93,'Wells Fargo Advisor','516',1,'{\"fid\":\"1030\",\"org\":\"strong.com\",\"url\":\"https:\\/\\/ofx.wellsfargoadvantagefunds.com\\/eftxWeb\\/Access.ofx\"}'),(94,'Chicago Patrolmens FCU','517',1,'{\"fid\":\"271078146\",\"org\":\"Chicago Patrolmens CU\",\"url\":\"https:\\/\\/chp.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(95,'Signal Financial Federal Credit Union','518',1,'{\"fid\":\"255075495\",\"org\":\"Washington Telephone FCU\",\"url\":\"https:\\/\\/webpb.sfonline.org\\/scripts\\/isaofx.dll\"}'),(96,'Bank-Fund Staff FCU','520',1,'{\"fid\":\"2\",\"org\":\"Bank Fund Staff FCU\",\"url\":\"https:\\/\\/secure.bfsfcu.org\\/ofx\\/ofx.dll\"}'),(97,'APCO EMPLOYEES CREDIT UNION','521',1,'{\"fid\":\"262087609\",\"org\":\"APCO Employees Credit Union\",\"url\":\"https:\\/\\/apc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(98,'Bank of Tampa, The','522',1,'{\"fid\":\"063108680\",\"org\":\"BOT\",\"url\":\"https:\\/\\/OFX.Bankoftampa.com\\/OFXServer\\/ofxsrvr.dll\"}'),(99,'Cedar Point Federal Credit Union','523',1,'{\"fid\":\"255077736\",\"org\":\"Cedar Point Federal Credit Union\",\"url\":\"https:\\/\\/pcu.cpfcu.com\\/scripts\\/isaofx.dll\"}'),(100,'Las Colinas FCU','524',1,'{\"fid\":\"311080573\",\"org\":\"Las Colinas Federal CU\",\"url\":\"https:\\/\\/las.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(101,'McCoy Federal Credit Union','525',1,'{\"fid\":\"263179956\",\"org\":\"McCoy Federal Credit Union\",\"url\":\"https:\\/\\/www.mccoydirect.org\\/scripts\\/isaofx.dll\"}'),(102,'Old National Bank','526',1,'{\"fid\":\"11638\",\"org\":\"ONB\",\"url\":\"https:\\/\\/www.ofx.oldnational.com\\/ofxpreprocess.asp\"}'),(103,'Citizens Bank - Consumer','527',1,'{\"fid\":\"CTZBK\",\"org\":\"CheckFree OFX\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/0CTZBK.ofxgp\"}'),(104,'Citizens Bank - Business','528',1,'{\"fid\":\"4639\",\"org\":\"CheckFree OFX\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/04639.ofxgp\"}'),(105,'Century Federal Credit Union','529',1,'{\"fid\":\"241075056\",\"org\":\"CenturyFederalCU\",\"url\":\"https:\\/\\/pcu.cenfedcu.org\\/scripts\\/isaofx.dll\"}'),(106,'ABNB Federal Credit Union','530',1,'{\"fid\":\"251481627\",\"org\":\"ABNB Federal Credit Union\",\"url\":\"https:\\/\\/cuathome.abnbfcu.org\\/scripts\\/isaofx.dll\"}'),(107,'Allegiance Credit Union','531',1,'{\"fid\":\"303085230\",\"org\":\"Federal Employees CU\",\"url\":\"https:\\/\\/fed.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(108,'Wright Patman Congressional FCU','532',1,'{\"fid\":\"254074345\",\"org\":\"Wright Patman Congressional FCU\",\"url\":\"https:\\/\\/www.congressionalonline.org\\/scripts\\/isaofx.dll\"}'),(109,'America First Credit Union','533',1,'{\"fid\":\"54324\",\"org\":\"America First Credit Union\",\"url\":\"https:\\/\\/ofx.americafirst.com\"}'),(110,'Motorola Employees Credit Union','534',1,'{\"fid\":\"271984311\",\"org\":\"Motorola Employees CU\",\"url\":\"https:\\/\\/mecuofx.mecunet.org\\/scripts\\/isaofx.dll\"}'),(111,'Finance Center FCU (IN)','535',1,'{\"fid\":\"274073876\",\"org\":\"Finance Center FCU\",\"url\":\"https:\\/\\/sec.fcfcu.com\\/scripts\\/isaofx.dll\"}'),(112,'Fort Knox Federal Credit Union','536',1,'{\"fid\":\"283978425\",\"org\":\"Fort Knox Federal Credit Union\",\"url\":\"https:\\/\\/fcs1.fkfcu.org\\/scripts\\/isaofx.dll\"}'),(113,'Wachovia Bank','537',1,'{\"fid\":\"4309\",\"org\":\"Wachovia\",\"url\":\"https:\\/\\/pfmpw.wachovia.com\\/cgi-forte\\/fortecgi?servicename=ofx&pagename=PFM\"}'),(114,'Think Federal Credit Union','538',1,'{\"fid\":\"291975465\",\"org\":\"IBMCU\",\"url\":\"https:\\/\\/ofx.ibmcu.com\"}'),(115,'PSECU','539',1,'{\"fid\":\"54354\",\"org\":\"Teknowledge\",\"url\":\"https:\\/\\/ofx.psecu.com\\/servlet\\/OFXServlet\"}'),(116,'Envision Credit Union','540',1,'{\"fid\":\"263182558\",\"org\":\"Envision Credit Union\",\"url\":\"https:\\/\\/pcu.envisioncu.com\\/scripts\\/isaofx.dll\"}'),(117,'Columbia Credit Union','541',1,'{\"fid\":\"323383349\",\"org\":\"Columbia Credit Union\",\"url\":\"https:\\/\\/ofx.columbiacu.org\\/scripts\\/isaofx.dll\"}'),(118,'1st Advantage FCU','542',1,'{\"fid\":\"251480563\",\"org\":\"1st Advantage FCU\",\"url\":\"https:\\/\\/members.1stadvantage.org\\/scripts\\/isaofx.dll\"}'),(119,'Central Maine FCU','543',1,'{\"fid\":\"211287926\",\"org\":\"Central Maine FCU\",\"url\":\"https:\\/\\/cro.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(120,'Kirtland Federal Credit Union','544',1,'{\"fid\":\"307070050\",\"org\":\"Kirtland Federal Credit Union\",\"url\":\"https:\\/\\/pcu.kirtlandfcu.org\\/scripts\\/isaofx.dll\"}'),(121,'Chesterfield Federal Credit Union','545',1,'{\"fid\":\"251480327\",\"org\":\"Chesterfield Employees FCU\",\"url\":\"https:\\/\\/chf.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(122,'Campus USA Credit Union','546',1,'{\"fid\":\"263178478\",\"org\":\"Campus USA Credit Union\",\"url\":\"https:\\/\\/que.campuscu.com\\/scripts\\/isaofx.dll\"}'),(123,'Summit Credit Union (WI)','547',1,'{\"fid\":\"275979034\",\"org\":\"Summit Credit Union\",\"url\":\"https:\\/\\/branch.summitcreditunion.com\\/scripts\\/isaofx.dll\"}'),(124,'Financial Center CU','548',1,'{\"fid\":\"321177803\",\"org\":\"Fincancial Center Credit Union\",\"url\":\"https:\\/\\/fin.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(125,'Hawaiian Tel Federal Credit Union','549',1,'{\"fid\":\"321379070\",\"org\":\"Hawaiian Tel FCU\",\"url\":\"https:\\/\\/htl.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(126,'Addison Avenue Federal Credit Union','550',1,'{\"fid\":\"11288\",\"org\":\"hpcu\",\"url\":\"https:\\/\\/ofx.addisonavenue.com\"}'),(127,'Navy Army Federal Credit Union','551',1,'{\"fid\":\"111904503\",\"org\":\"Navy Army Federal Credit Union\",\"url\":\"https:\\/\\/mybranch.navyarmyfcu.com\\/scripts\\/isaofx.dll\"}'),(128,'Nevada Federal Credit Union','552',1,'{\"fid\":\"10888\",\"org\":\"PSI\",\"url\":\"https:\\/\\/ssl4.nevadafederal.org\\/ofxdirect\\/ofxrqst.aspx\"}'),(129,'66 Federal Credit Union','553',1,'{\"fid\":\"289\",\"org\":\"SixySix\",\"url\":\"https:\\/\\/ofx.cuonlineaccounts.org\"}'),(130,'FirstBank of Colorado','554',1,'{\"fid\":\"FirstBank\",\"org\":\"FBDC\",\"url\":\"https:\\/\\/www.efirstbankpfm.com\\/ofx\\/OFXServlet\"}'),(131,'Continental Federal Credit Union','555',1,'{\"fid\":\"322077559\",\"org\":\"Continenetal FCU\",\"url\":\"https:\\/\\/cnt.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(132,'Fremont Bank','556',1,'{\"fid\":\"121107882\",\"org\":\"Fremont Bank\",\"url\":\"https:\\/\\/ofx.fremontbank.com\\/OFXServer\\/FBOFXSrvr.dll\"}'),(133,'Peninsula Community Federal Credit Union','557',1,'{\"fid\":\"325182344\",\"org\":\"Peninsula Credit Union\",\"url\":\"https:\\/\\/mas.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(134,'Fidelity NetBenefits','558',1,'{\"fid\":\"8288\",\"org\":\"nbofx.fidelity.com\",\"url\":\"https:\\/\\/nbofx.fidelity.com\\/netbenefits\\/ofx\\/download\"}'),(135,'Fall River Municipal CU','559',1,'{\"fid\":\"211382591\",\"org\":\"Fall River Municipal CU\",\"url\":\"https:\\/\\/fal.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(136,'University Credit Union','560',1,'{\"fid\":\"267077850\",\"org\":\"University Credit Union\",\"url\":\"https:\\/\\/umc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(137,'Dominion Credit Union','561',1,'{\"fid\":\"251082644\",\"org\":\"Dominion Credit Union\",\"url\":\"https:\\/\\/dom.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(138,'HFS Federal Credit Union','562',1,'{\"fid\":\"321378660\",\"org\":\"HFS Federal Credit Union\",\"url\":\"https:\\/\\/hfs.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(139,'IronStone Bank','563',1,'{\"fid\":\"5012\",\"org\":\"Atlantic States Bank\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/5012.ofxgp\"}'),(140,'Utah Community Credit Union','564',1,'{\"fid\":\"324377820\",\"org\":\"Utah Community Credit Union\",\"url\":\"https:\\/\\/ofx.uccu.com\\/scripts\\/isaofx.dll\"}'),(141,'OptionsXpress, Inc','565',1,'{\"fid\":\"10876\",\"org\":\"10876\",\"url\":\"https:\\/\\/ofx.optionsxpress.com\\/cgi-bin\\/ox.exe\"}'),(142,'Prudential Retirement','567',1,'{\"fid\":\"1271\",\"org\":\"Prudential Retirement Services\",\"url\":\"https:\\/\\/ofx.prudential.com\\/eftxweb\\/EFTXWebRedirector\"}'),(143,'Wells Fargo Investments, LLC','568',1,'{\"fid\":\"10762\",\"org\":\"wellsfargo.com\",\"url\":\"https:\\/\\/invmnt.wellsfargo.com\\/inv\\/directConnect\"}'),(144,'Penson Financial Services','570',1,'{\"fid\":\"10780\",\"org\":\"Penson Financial Services Inc\",\"url\":\"https:\\/\\/ofx.penson.com\"}'),(145,'Tri Boro Federal Credit Union','571',1,'{\"fid\":\"243382747\",\"org\":\"Tri Boro Federal Credit Union\",\"url\":\"https:\\/\\/tri.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(146,'Hewitt Associates LLC','572',1,'{\"fid\":\"242\",\"org\":\"hewitt.com\",\"url\":\"https:\\/\\/seven.was.hewitt.com\\/eftxweb\\/access.ofx\"}'),(147,'Delta Community Credit Union','573',1,'{\"fid\":\"3328\",\"org\":\"decu.org\",\"url\":\"https:\\/\\/appweb.deltacommunitycu.com\\/ofxroot\\/directtocore.asp\"}'),(148,'Huntington National Bank','574',1,'{\"fid\":\"3701\",\"org\":\"Huntington\",\"url\":\"https:\\/\\/onlinebanking.huntington.com\\/scripts\\/serverext.dll\"}'),(149,'WSECU','575',1,'{\"fid\":\"325181028\",\"org\":\"WSECU\",\"url\":\"https:\\/\\/ssl3.wsecu.org\\/ofxserver\\/ofxsrvr.dll\"}'),(150,'Baton Rouge City Parish Emp FCU','576',1,'{\"fid\":\"265473333\",\"org\":\"Baton Rouge City Parish EFCU\",\"url\":\"https:\\/\\/bat.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(151,'Schools Financial Credit Union','577',1,'{\"fid\":\"90001\",\"org\":\"Teknowledge\",\"url\":\"https:\\/\\/ofx.schools.org\\/TekPortalOFX\\/servlet\\/TP_OFX_Controller\"}'),(152,'Charles Schwab Bank, N.A.','578',1,'{\"fid\":\"101\",\"org\":\"ISC\",\"url\":\"https:\\/\\/ofx.schwab.com\\/bankcgi_dev\\/ofx_server\"}'),(153,'NW Preferred Federal Credit Union','579',1,'{\"fid\":\"323076575\",\"org\":\"NW Preferred FCU\",\"url\":\"https:\\/\\/nwf.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(154,'Camino FCU','580',1,'{\"fid\":\"322279975\",\"org\":\"Camino FCU\",\"url\":\"https:\\/\\/homebanking.caminofcu.org\\/isaofx\\/isaofx.dll\"}'),(155,'Novartis Federal Credit Union','581',1,'{\"fid\":\"221278556\",\"org\":\"Novartis FCU\",\"url\":\"https:\\/\\/cib.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(156,'U.S. First FCU','582',1,'{\"fid\":\"321076289\",\"org\":\"US First FCU\",\"url\":\"https:\\/\\/uff.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(157,'FAA Technical Center FCU','583',1,'{\"fid\":\"231277440\",\"org\":\"FAA Technical Center FCU\",\"url\":\"https:\\/\\/ftc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(158,'Municipal Employees Credit Union of Baltimore, Inc.','584',1,'{\"fid\":\"252076468\",\"org\":\"Municipal ECU of Baltimore,Inc.\",\"url\":\"https:\\/\\/mec.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(159,'Day Air Credit Union','585',1,'{\"fid\":\"242277808\",\"org\":\"Day Air Credit Union\",\"url\":\"https:\\/\\/pcu.dayair.org\\/scripts\\/isaofx.dll\"}'),(160,'Texas State Bank - McAllen','586',1,'{\"fid\":\"114909013\",\"org\":\"Texas State Bank\",\"url\":\"https:\\/\\/www.tsb-a.com\\/OFXServer\\/ofxsrvr.dll\"}'),(161,'OCTFCU','587',1,'{\"fid\":\"17600\",\"org\":\"OCTFCU\",\"url\":\"https:\\/\\/ofx.octfcu.org\"}'),(162,'Hawaii State FCU','588',1,'{\"fid\":\"321379041\",\"org\":\"Hawaii State FCU\",\"url\":\"https:\\/\\/hse.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(163,'Community First Credit Union','592',1,'{\"fid\":\"275982801\",\"org\":\"Community First Credit Union\",\"url\":\"https:\\/\\/pcu.communityfirstcu.org\\/scripts\\/isaofx.dll\"}'),(164,'MTC Federal Credit Union','593',1,'{\"fid\":\"053285173\",\"org\":\"MTC Federal Credit Union\",\"url\":\"https:\\/\\/mic.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(165,'Home Federal Savings Bank(MN/IA)','594',1,'{\"fid\":\"291270050\",\"org\":\"VOneTwentySevenG\",\"url\":\"https:\\/\\/ofx1.evault.ws\\/ofxserver\\/ofxsrvr.dll\"}'),(166,'Reliant Community Credit Union','595',1,'{\"fid\":\"222382438\",\"org\":\"W.C.T.A Federal Credit Union\",\"url\":\"https:\\/\\/wct.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(167,'Patriots Federal Credit Union','596',1,'{\"fid\":\"322281963\",\"org\":\"PAT FCU\",\"url\":\"https:\\/\\/pat.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(168,'SafeAmerica Credit Union','597',1,'{\"fid\":\"321171757\",\"org\":\"SafeAmerica Credit Union\",\"url\":\"https:\\/\\/saf.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(169,'Mayo Employees Federal Credit Union','598',1,'{\"fid\":\"291975478\",\"org\":\"Mayo Employees FCU\",\"url\":\"https:\\/\\/homebank.mayocreditunion.org\\/ofx\\/ofx.dll\"}'),(170,'FivePoint Credit Union','599',1,'{\"fid\":\"313187571\",\"org\":\"FivePoint Credit Union\",\"url\":\"https:\\/\\/tfcu-nfuse01.texacocommunity.org\\/internetconnector\\/isaofx.dll\"}'),(171,'Community Resource Bank','600',1,'{\"fid\":\"091917160\",\"org\":\"CNB\",\"url\":\"https:\\/\\/www.cnbinternet.com\\/OFXServer\\/ofxsrvr.dll\"}'),(172,'Security 1st FCU','601',1,'{\"fid\":\"314986292\",\"org\":\"Security 1st FCU\",\"url\":\"https:\\/\\/sec.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(173,'First Alliance Credit Union','602',1,'{\"fid\":\"291975481\",\"org\":\"First Alliance Credit Union\",\"url\":\"https:\\/\\/fia.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(174,'Billings Federal Credit Union','603',1,'{\"fid\":\"6217\",\"org\":\"Billings Federal Credit Union\",\"url\":\"https:\\/\\/bfcuonline.billingsfcu.org\\/ofx\\/ofx.dll\"}'),(175,'Windward Community FCU','604',1,'{\"fid\":\"321380315\",\"org\":\"Windward Community FCU\",\"url\":\"https:\\/\\/wwc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(176,'Siouxland Federal Credit Union','606',1,'{\"fid\":\"304982235\",\"org\":\"SIOUXLAND FCU\",\"url\":\"https:\\/\\/sio.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(177,'The Queen\'s Federal Credit Union','607',1,'{\"fid\":\"321379504\",\"org\":\"The Queens Federal Credit Union\",\"url\":\"https:\\/\\/que.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(178,'Edward Jones','608',1,'{\"fid\":\"823\",\"org\":\"Edward Jones\",\"url\":\"https:\\/\\/ofx.edwardjones.com\"}'),(179,'Merck Sharp&Dohme FCU','609',1,'{\"fid\":\"231386645\",\"org\":\"MERCK, SHARPE&DOHME FCU\",\"url\":\"https:\\/\\/msd.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(180,'Credit Union 1 - IL','610',1,'{\"fid\":\"271188081\",\"org\":\"Credit Union 1\",\"url\":\"https:\\/\\/pcu.creditunion1.org\\/scripts\\/isaofx.dll\"}'),(181,'Bossier Federal Credit Union','611',1,'{\"fid\":\"311175129\",\"org\":\"Bossier Federal Credit Union\",\"url\":\"https:\\/\\/bos.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(182,'First Florida Credit Union','612',1,'{\"fid\":\"263079014\",\"org\":\"First Llorida Credit Union\",\"url\":\"https:\\/\\/pcu2.gecuf.org\\/scripts\\/isaofx.dll\"}'),(183,'NorthEast Alliance FCU','613',1,'{\"fid\":\"221982130\",\"org\":\"NorthEast Alliance FCU\",\"url\":\"https:\\/\\/nea.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(184,'ShareBuilder','614',1,'{\"fid\":\"5575\",\"org\":\"ShareBuilder\",\"url\":\"https:\\/\\/ofx.sharebuilder.com\"}'),(185,'Weitz Funds','616',1,'{\"fid\":\"weitz.com\",\"org\":\"weitz.com\",\"url\":\"https:\\/\\/www3.financialtrans.com\\/tf\\/OFXServer?tx=OFXController&cz=702110804131918&cl=52204081925\"}'),(186,'JPMorgan Retirement Plan Services','617',1,'{\"fid\":\"6313\",\"org\":\"JPMORGAN\",\"url\":\"https:\\/\\/ofx.retireonline.com\\/eftxweb\\/access.ofx\"}'),(187,'Credit Union ONE','618',1,'{\"fid\":\"14412\",\"org\":\"Credit Union ONE\",\"url\":\"https:\\/\\/cuhome.cuone.org\\/ofx\\/ofx.dll\"}'),(188,'Salt Lake City Credit Union','619',1,'{\"fid\":\"324079186\",\"org\":\"Salt Lake City Credit Union\",\"url\":\"https:\\/\\/slc.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(189,'First Southwest Company','620',1,'{\"fid\":\"7048\",\"org\":\"AFS\",\"url\":\"https:\\/\\/fswofx.automatedfinancial.com\"}'),(190,'Wells Fargo Trust-Investment Mgt','622',1,'{\"fid\":\"6955\",\"org\":\"Wells Fargo Trust\",\"url\":\"https:\\/\\/trust.wellsfargo.com\\/trust\\/directConnect\"}'),(191,'Scottrade, Inc.','623',1,'{\"fid\":\"777\",\"org\":\"Scottrade\",\"url\":\"https:\\/\\/ofxstl.scottsave.com\"}'),(192,'Silver State Schools CU','624',1,'{\"fid\":\"322484265\",\"org\":\"SSSCU\",\"url\":\"https:\\/\\/www.silverstatecu.com\\/OFXServer\\/ofxsrvr.dll\"}'),(193,'VISA Information Source','626',1,'{\"fid\":\"10942\",\"org\":\"VISA\",\"url\":\"https:\\/\\/vis.informationmanagement.visa.com\\/eftxweb\\/access.ofx\"}'),(194,'National City','627',1,'{\"fid\":\"5860\",\"org\":\"NATIONAL CITY\",\"url\":\"https:\\/\\/ofx.nationalcity.com\\/ofx\\/OFXConsumer.aspx\"}'),(195,'Capital One','628',1,'{\"fid\":\"1001\",\"org\":\"Hibernia\",\"url\":\"https:\\/\\/onlinebanking.capitalone.com\\/scripts\\/serverext.dll\"}'),(196,'Citi Credit Card','629',1,'{\"fid\":\"24909\",\"org\":\"Citigroup\",\"url\":\"https:\\/\\/www.accountonline.com\\/cards\\/svc\\/CitiOfxManager.do\"}'),(197,'Zions Bank','630',1,'{\"fid\":\"1115\",\"org\":\"244-3\",\"url\":\"https:\\/\\/quicken.metavante.com\\/ofx\\/OFXServlet\"}'),(198,'Capital One Bank','631',1,'{\"fid\":\"1001\",\"org\":\"Hibernia\",\"url\":\"https:\\/\\/onlinebanking.capitalone.com\\/scripts\\/serverext.dll\"}'),(199,'Redstone Federal Credit Union','633',1,'{\"fid\":\"2143\",\"org\":\"Harland Financial Solutions\",\"url\":\"https:\\/\\/remotebanking.redfcu.org\\/ofx\\/ofx.dll\"}'),(200,'PNC Bank','634',1,'{\"fid\":\"4501\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/04501.ofx\"}'),(201,'Bank of America (California)','635',1,'{\"fid\":\"6805\",\"org\":\"HAN\",\"url\":\"https:\\/\\/ofx.bankofamerica.com\\/cgi-forte\\/ofx?servicename=ofx_2-3&pagename=bofa\"}'),(202,'Chase (credit card) ','636',1,'{\"fid\":\"10898\",\"org\":\"B1\",\"url\":\"https:\\/\\/ofx.chase.com\"}'),(203,'Arizona Federal Credit Union','637',1,'{\"fid\":\"322172797\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(204,'UW Credit Union','638',1,'{\"fid\":\"1001\",\"org\":\"UWCU\",\"url\":\"https:\\/\\/ofx.uwcu.org\\/serverext.dll\"}'),(205,'Bank of America','639',1,'{\"fid\":\"5959\",\"org\":\"HAN\",\"url\":\"https:\\/\\/eftx.bankofamerica.com\\/eftxweb\\/access.ofx\"}'),(206,'Commerce Bank','640',1,'{\"fid\":\"1001\",\"org\":\"CommerceBank\",\"url\":\"https:\\/\\/ofx.tdbank.com\\/scripts\\/serverext.dll\"}'),(207,'Securities America','641',1,'{\"fid\":\"7784\",\"org\":\"Fidelity\",\"url\":\"https:\\/\\/ofx.ibgstreetscape.com:443\"}'),(208,'First Internet Bank of Indiana','642',1,'{\"fid\":\"074014187\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(209,'Alpine Banks of Colorado','643',1,'{\"fid\":\"1451\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(210,'BancFirst','644',1,'{\"fid\":\"103003632\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(211,'Desert Schools Federal Credit Union','645',1,'{\"fid\":\"1001\",\"org\":\"DSFCU\",\"url\":\"https:\\/\\/epal.desertschools.org\\/scripts\\/serverext.dll\"}'),(212,'Kinecta Federal Credit Union','646',1,'{\"fid\":\"322278073\",\"org\":\"KINECTA\",\"url\":\"https:\\/\\/ofx.kinecta.org\\/OFXServer\\/ofxsrvr.dll\"}'),(213,'Boeing Employees Credit Union','325081403',1,'{\"fid\":\"3670\",\"org\":\"BECU\",\"url\":\"https:\\/\\/onlinebanking.becu.org\\/ofx\\/ofxprocessor.asp\"}'),(214,'Capital One Bank - 2','648',1,'{\"fid\":\"1001\",\"org\":\"Hibernia\",\"url\":\"https:\\/\\/onlinebanking.capitalone.com\\/ofx\\/process.ofx\"}'),(215,'Michigan State University Federal CU','649',1,'{\"fid\":\"272479663\",\"org\":\"MSUFCU\",\"url\":\"https:\\/\\/ofx.msufcu.org\\/ofxserver\\/ofxsrvr.dll\"}'),(216,'The Community Bank','650',1,'{\"fid\":\"211371476\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(217,'Sacramento Credit Union','651',1,'{\"fid\":\"1\",\"org\":\"SACRAMENTO CREDIT UNION\",\"url\":\"https:\\/\\/homebank.sactocu.org\\/ofx\\/ofx.dll\"}'),(218,'TD Bank','652',1,'{\"fid\":\"1001\",\"org\":\"CommerceBank\",\"url\":\"https:\\/\\/onlinebanking.tdbank.com\\/scripts\\/serverext.dll\"}'),(219,'Suncoast Schools FCU','653',1,'{\"fid\":\"1001\",\"org\":\"SunCoast\",\"url\":\"https:\\/\\/ofx.suncoastfcu.org\"}'),(220,'Metro Bank','654',1,'{\"fid\":\"9970\",\"org\":\"MTRO\",\"url\":\"https:\\/\\/ofx.mymetrobank.com\\/ofx\\/ofx.ofx\"}'),(221,'First National Bank (Texas)','655',1,'{\"fid\":\"12840\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(222,'Bank of the West','656',1,'{\"fid\":\"5809\",\"org\":\"BancWest Corp\",\"url\":\"https:\\/\\/olbp.bankofthewest.com\\/ofx0002\\/ofx_isapi.dll\"}'),(223,'Mountain America Credit Union','657',1,'{\"fid\":\"324079555\",\"org\":\"MACU\",\"url\":\"https:\\/\\/ofx.macu.org\\/OFXServer\\/ofxsrvr.dll\"}'),(224,'ING DIRECT','658',1,'{\"fid\":\"031176110\",\"org\":\"ING DIRECT\",\"url\":\"https:\\/\\/ofx.ingdirect.com\\/OFX\\/ofx.html\"}'),(225,'Santa Barbara Bank & Trust','659',1,'{\"fid\":\"5524\",\"org\":\"pfm-l3g\",\"url\":\"https:\\/\\/pfm.metavante.com\\/ofx\\/OFXServlet\"}'),(226,'UMB','660',1,'{\"fid\":\"468\",\"org\":\"UMBOFX\",\"url\":\"https:\\/\\/ofx.umb.com\"}'),(227,'Bank Of America(All except CA,WA,&ID ','661',1,'{\"fid\":\"6812\",\"org\":\"HAN\",\"url\":\"Https:\\/\\/ofx.bankofamerica.com\\/cgi-forte\\/fortecgi?servicename=ofx_2-3&pagename=ofx \"}'),(228,'Centra Credit Union2','662',1,'{\"fid\":\"274972883\",\"org\":\"Centra CU\",\"url\":\"https:\\/\\/www.centralink.org\\/scripts\\/isaofx.dll\"}'),(229,'Mainline National Bank','663',1,'{\"fid\":\"9869\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(230,'Citizens Bank','664',1,'{\"fid\":\"4639\",\"org\":\"CheckFree OFX\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/04639.ofxgp\"}'),(231,'USAA Investment Mgmt Co','665',1,'{\"fid\":\"24592\",\"org\":\"USAA\",\"url\":\"https:\\/\\/service2.usaa.com\\/ofx\\/OFXServlet\"}'),(232,'121 Financial Credit Union','666',1,'{\"fid\":\"000001155\",\"org\":\"121 Financial Credit Union\",\"url\":\"https:\\/\\/ppc.121fcu.org\\/scripts\\/isaofx.dll\"}'),(233,'Abbott Laboratories Employee CU','667',1,'{\"fid\":\"35MXN\",\"org\":\"Abbott Laboratories ECU - ALEC\",\"url\":\"https:\\/\\/www.netit.financial-net.com\\/ofx\\/\"}'),(234,'Achieva Credit Union','668',1,'{\"fid\":\"4491\",\"org\":\"Achieva Credit Union\",\"url\":\"https:\\/\\/rbserver.achievacu.com\\/ofx\\/ofx.dll\"}'),(235,'American National Bank','669',1,'{\"fid\":\"4201\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/04201.ofx\"}'),(236,'Andrews Federal Credit Union','670',1,'{\"fid\":\"AFCUSMD\",\"org\":\"FundsXpress\",\"url\":\"https:\\/\\/ofx.fundsxpress.com\\/piles\\/ofx.pile\\/\"}'),(237,'Citi Personal Wealth Management','671',1,'{\"fid\":\"060\",\"org\":\"Citigroup\",\"url\":\"https:\\/\\/uat-ofx.netxclient.inautix.com\\/cgi\\/OFXNetx\"}'),(238,'Bank One (Chicago)','672',1,'{\"fid\":\"1501\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/01501.ofx\"}'),(239,'Bank One (Michigan and Florida)','673',1,'{\"fid\":\"6001\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/06001.ofx\"}'),(240,'Bank of America (Formerly Fleet)','674',1,'{\"fid\":\"1803\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/01803.ofx\"}'),(241,'BankBoston PC Banking','675',1,'{\"fid\":\"1801\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/01801.ofx\"}'),(242,'Beverly Co-Operative Bank','676',1,'{\"fid\":\"531\",\"org\":\"orcc\",\"url\":\"https:\\/\\/www19.onlinebank.com\\/OROFX16Listener\"}'),(243,'Cambridge Portuguese Credit Union','677',1,'{\"fid\":\"983\",\"org\":\"orcc\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(244,'Citibank','678',1,'{\"fid\":\"2101\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/02101.ofx\"}'),(245,'Community Bank, N.A.','679',1,'{\"fid\":\"11517\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline2.netteller.com\"}'),(246,'Consumers Credit Union','680',1,'{\"fid\":\"12541\",\"org\":\"Consumers Credit Union\",\"url\":\"https:\\/\\/ofx.lanxtra.com\\/ofx\\/servlet\\/Teller\"}'),(247,'CPM Federal Credit Union','681',1,'{\"fid\":\"253279536\",\"org\":\"USERS, Inc.\",\"url\":\"https:\\/\\/cpm.usersonlnet.com\\/scripts\\/isaofx.dll\"}'),(248,'DATCU','682',1,'{\"fid\":\"311980725\",\"org\":\"DATCU\",\"url\":\"https:\\/\\/online.datcu.coop\\/ofxserver\\/ofxsrvr.dll\"}'),(249,'Denver Community Federal Credit Union','683',1,'{\"fid\":\"10524\",\"org\":\"Denver Community FCU\",\"url\":\"https:\\/\\/pccu.dcfcu.coop\\/ofx\\/ofx.dll\"}'),(250,'Discover Platinum','684',1,'{\"fid\":\"7102\",\"org\":\"Discover Financial Services\",\"url\":\"https:\\/\\/ofx.discovercard.com\\/\"}'),(251,'EAB','685',1,'{\"fid\":\"6505\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/06505.ofx\"}'),(252,'FAA Credit Union','686',1,'{\"fid\":\"114\",\"org\":\"FAA Credit Union\",\"url\":\"https:\\/\\/flightline.faaecu.org\\/ofx\\/ofx.dll\"}'),(253,'Fairwinds Credit Union','687',1,'{\"fid\":\"4842\",\"org\":\"OSI 2\",\"url\":\"https:\\/\\/OFX.opensolutionsTOC.com\\/eftxweb\\/access.ofx\"}'),(254,'FedChoice FCU','688',1,'{\"fid\":\"254074785\",\"org\":\"FEDCHOICE\",\"url\":\"https:\\/\\/ofx.fedchoice.org\\/ofxserver\\/ofxsrvr.dll\"}'),(255,'First Clearing, LLC','689',1,'{\"fid\":\"10033\",\"org\":\"First Clearing, LLC\",\"url\":\"https:\\/\\/pfmpw.wachovia.com\\/cgi-forte\\/fortecgi?servicename=ofxbrk&pagename=PFM\"}'),(256,'First Citizens','690',1,'{\"fid\":\"1849\",\"org\":\"First Citizens\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/01849.ofx\"}'),(257,'First Hawaiian Bank','691',1,'{\"fid\":\"3501\",\"org\":\"BancWest Corp\",\"url\":\"https:\\/\\/olbp.fhb.com\\/ofx0001\\/ofx_isapi.dll\"}'),(258,'First National Bank of St. Louis','692',1,'{\"fid\":\"162\",\"org\":\"81004601\",\"url\":\"https:\\/\\/ofx.centralbancompany.com\\/ofxserver\\/ofxsrvr.dll\"}'),(259,'First Interstate Bank','693',1,'{\"fid\":\"092901683\",\"org\":\"FIB\",\"url\":\"https:\\/\\/ofx.firstinterstatebank.com\\/OFXServer\\/ofxsrvr.dll\"}'),(260,'Goldman Sachs','694',1,'{\"fid\":\"1234\",\"org\":\"gs.com\",\"url\":\"https:\\/\\/portfolio-ofx.gs.com:446\\/ofx\\/ofx.eftx\"}'),(261,'Hudson Valley FCU','695',1,'{\"fid\":\"10767\",\"org\":\"Hudson Valley FCU\",\"url\":\"https:\\/\\/internetbanking.hvfcu.org\\/ofx\\/ofx.dll\"}'),(262,'IBM Southeast Employees Federal Credit Union','696',1,'{\"fid\":\"1779\",\"org\":\"IBM Southeast EFCU\",\"url\":\"https:\\/\\/rb.ibmsecu.org\\/ofx\\/ofx.dll\"}'),(263,'Insight CU','697',1,'{\"fid\":\"10764\",\"org\":\"Insight Credit Union\",\"url\":\"https:\\/\\/secure.insightcreditunion.com\\/ofx\\/ofx.dll\"}'),(264,'Janney Montgomery Scott LLC','698',1,'{\"fid\":\"11326\",\"org\":\"AFS\",\"url\":\"https:\\/\\/jmsofx.automatedfinancial.com\"}'),(265,'JSC Federal Credit Union','699',1,'{\"fid\":\"10491\",\"org\":\"JSC Federal Credit Union\",\"url\":\"https:\\/\\/starpclegacy.jscfcu.org\\/ofx\\/ofx.dll\"}'),(266,'J.P. Morgan','700',1,'{\"fid\":\"4701\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/04701.ofx\"}'),(267,'J.P. Morgan Clearing Corp.','701',1,'{\"fid\":\"7315\",\"org\":\"GCS\",\"url\":\"https:\\/\\/ofxgcs.toolkit.clearco.com\"}'),(268,'M & T Bank','702',1,'{\"fid\":\"2601\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/02601.ofx\"}'),(269,'Marquette Banks','703',1,'{\"fid\":\"1301\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/01301.ofx\"}'),(270,'Mercer','704',1,'{\"fid\":\"8007527525\",\"org\":\"PutnamDefinedContributions\",\"url\":\"https:\\/\\/ofx.mercerhrs.com\\/eftxweb\\/access.ofx\"}'),(271,'Merrill Lynch Online Payment','705',1,'{\"fid\":\"7301\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/07301.ofx\"}'),(272,'Missoula Federal Credit Union','706',1,'{\"fid\":\"5097\",\"org\":\"Missoula Federal Credit Union\",\"url\":\"https:\\/\\/secure.missoulafcu.org\\/ofx\\/ofx.dll\"}'),(273,'Morgan Stanley (Smith Barney)','707',1,'{\"fid\":\"5207\",\"org\":\"Smithbarney.com\",\"url\":\"https:\\/\\/ofx.smithbarney.com\\/app-bin\\/ofx\\/servlets\\/access.ofx\"}'),(274,'Nevada State Bank - OLD','708',1,'{\"fid\":\"5401\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/05401.ofx\"}'),(275,'New England Federal Credit Union','709',1,'{\"fid\":\"2104\",\"org\":\"New England Federal Credit Union\",\"url\":\"https:\\/\\/pcaccess.nefcu.com\\/ofx\\/ofx.dll\"}'),(276,'Norwest','710',1,'{\"fid\":\"4601\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/04601.ofx\"}'),(277,'Oppenheimer & Co. Inc.','711',1,'{\"fid\":\"125\",\"org\":\"Oppenheimer\",\"url\":\"https:\\/\\/ofx.opco.com\\/eftxweb\\/access.ofx\"}'),(278,'Oregon College Savings Plan','712',1,'{\"fid\":\"51498\",\"org\":\"tiaaoregon\",\"url\":\"https:\\/\\/ofx3.financialtrans.com\\/tf\\/OFXServer?tx=OFXController&cz=702110804131918&cl=b1908000027141704061413\"}'),(279,'RBC Dain Rauscher','713',1,'{\"fid\":\"8035\",\"org\":\"RBC Dain Rauscher\",\"url\":\"https:\\/\\/ofx.rbcdain.com\\/\"}'),(280,'Robert W. Baird & Co.','714',1,'{\"fid\":\"1109\",\"org\":\"Robert W. Baird & Co.\",\"url\":\"https:\\/\\/ofx.rwbaird.com\"}'),(281,'Sears Card','715',1,'{\"fid\":\"26810\",\"org\":\"CITIGROUP\",\"url\":\"https:\\/\\/secureofx.bankhost.com\\/tuxofx\\/cgi-bin\\/cgi_chip\"}'),(282,'South Trust Bank','716',1,'{\"fid\":\"6101\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/06101.ofx\"}'),(283,'Standard Federal Bank','717',1,'{\"fid\":\"6507\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/06507.ofx\"}'),(284,'United California Bank','718',1,'{\"fid\":\"2701\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/fip\\/genesis\\/prod\\/02701.ofx\"}'),(285,'United Federal CU - PowerLink','719',1,'{\"fid\":\"1908\",\"org\":\"United Federal Credit Union\",\"url\":\"https:\\/\\/remotebanking.unitedfcu.com\\/ofx\\/ofx.dll\"}'),(286,'VALIC','720',1,'{\"fid\":\"77019\",\"org\":\"valic.com\",\"url\":\"https:\\/\\/ofx.valic.com\\/eftxweb\\/access.ofx\"}'),(287,'Van Kampen Funds, Inc.','721',1,'{\"fid\":\"3625\",\"org\":\"Van Kampen Funds, Inc.\",\"url\":\"https:\\/\\/ofx3.financialtrans.com\\/tf\\/OFXServer?tx=OFXController&cz=702110804131918&cl=9210013100012150413\"}'),(288,'Vanguard Group','722',1,'{\"fid\":\"1358\",\"org\":\"The Vanguard Group\",\"url\":\"https:\\/\\/vesnc.vanguard.com\\/us\\/OfxProfileServlet\"}'),(289,'Velocity Credit Union','723',1,'{\"fid\":\"9909\",\"org\":\"Velocity Credit Union\",\"url\":\"https:\\/\\/rbserver.velocitycu.com\\/ofx\\/ofx.dll\"}'),(290,'Waddell & Reed - Ivy Funds','724',1,'{\"fid\":\"49623\",\"org\":\"waddell\",\"url\":\"https:\\/\\/ofx3.financialtrans.com\\/tf\\/OFXServer?tx=OFXController&cz=702110804131918&cl=722000303041111\"}'),(291,'Umpqua Bank','725',1,'{\"fid\":\"1001\",\"org\":\"Umpqua\",\"url\":\"https:\\/\\/ofx.umpquabank.com\\/ofx\\/process.ofx\"}'),(292,'Discover Bank','726',1,'{\"fid\":\"12610\",\"org\":\"Discover Bank\",\"url\":\"https:\\/\\/ofx.discovercard.com\"}'),(293,'Elevations Credit Union','727',1,'{\"fid\":\"1001\",\"org\":\"uocfcu\",\"url\":\"https:\\/\\/ofx.elevationscu.com\\/scripts\\/serverext.dll\"}'),(294,'Kitsap Community Credit Union','728',1,'{\"fid\":\"325180223\",\"org\":\"Kitsap Community Federal Credit\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(295,'Charles Schwab Retirement','729',1,'{\"fid\":\"1234\",\"org\":\"SchwabRPS\",\"url\":\"https:\\/\\/ofx.schwab.com\\/cgi_dev\\/ofx_server\"}'),(296,'Charles Schwab Retirement Plan Services','730',1,'{\"fid\":\"1234\",\"org\":\"SchwabRPS\",\"url\":\"https:\\/\\/ofx.schwab.com\\/cgi_dev\\/ofx_server\"}'),(297,'First Tech Federal Credit Union','731',1,'{\"fid\":\"3169\",\"org\":\"First Tech Federal Credit Union\",\"url\":\"https:\\/\\/ofx.firsttechfed.com\"}'),(298,'Affinity Plus Federal Credit Union','732',1,'{\"fid\":\"75\",\"org\":\"Affinity Plus FCU\",\"url\":\"https:\\/\\/hb.affinityplus.org\\/ofx\\/ofx.dll\"}'),(299,'Bank of George','733',1,'{\"fid\":\"122402366\",\"org\":\"122402366\",\"url\":\"https:\\/\\/ofx.internet-ebanking.com\\/CCOFXServer\\/servlet\\/TP_OFX_Controller\"}'),(300,'Franklin Templeton Investments','734',1,'{\"fid\":\"9444\",\"org\":\"franklintempleton.com\",\"url\":\"https:\\/\\/ofx.franklintempleton.com\\/eftxweb\\/access.ofx\"}'),(301,'ING Institutional Plan Services ','735',1,'{\"fid\":\"1289\",\"org\":\"ing-usa.com\",\"url\":\"https:\\/\\/ofx.ingplans.com\\/ofx\\/Server\"}'),(302,'Sterne Agee','736',1,'{\"fid\":\"2170\",\"org\":\"AFS\",\"url\":\"https:\\/\\/salofx.automatedfinancial.com\"}'),(303,'Wells Fargo Advisors','737',1,'{\"fid\":\"12748\",\"org\":\"WF\",\"url\":\"https:\\/\\/ofxdc.wellsfargo.com\\/ofxbrokerage\\/process.ofx\"}'),(304,'Community 1st Credit Union','738',1,'{\"fid\":\"325082017\",\"org\":\"Community 1st Credit Union\",\"url\":\"https:\\/\\/ib.comm1stcu.org\\/scripts\\/isaofx.dll\"}'),(305,'J.P. Morgan Private Banking','740',1,'{\"fid\":\"0417\",\"org\":\"jpmorgan.com\",\"url\":\"https:\\/\\/ofx.jpmorgan.com\\/jpmredirector\"}'),(306,'Northwest Community CU','741',1,'{\"fid\":\"1948\",\"org\":\"Cavion\",\"url\":\"https:\\/\\/ofx.lanxtra.com\\/ofx\\/servlet\\/Teller\"}'),(307,'North Carolina State Employees Credit Union','742',1,'{\"fid\":\"1001\",\"org\":\"SECU\",\"url\":\"https:\\/\\/onlineaccess.ncsecu.org\\/secuofx\\/secu.ofx \"}'),(308,'International Bank of Commerce','743',1,'{\"fid\":\"1001\",\"org\":\"IBC\",\"url\":\"https:\\/\\/ibcbankonline2.ibc.com\\/scripts\\/serverext.dll\"}'),(309,'RaboBank America','744',1,'{\"fid\":\"11540\",\"org\":\"RBB\",\"url\":\"https:\\/\\/ofx.rabobankamerica.com\\/ofx\\/process.ofx\"}'),(310,'Hughes Federal Credit Union','745',1,'{\"fid\":\"1951\",\"org\":\"Cavion\",\"url\":\"https:\\/\\/ofx.lanxtra.com\\/ofx\\/servlet\\/Teller\"}'),(311,'Apple FCU','746',1,'{\"fid\":\"256078514\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(312,'Chemical Bank','747',1,'{\"fid\":\"072410013\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(313,'Local Government Federal Credit Union','748',1,'{\"fid\":\"1001\",\"org\":\"SECU\",\"url\":\"https:\\/\\/onlineaccess.ncsecu.org\\/lgfcuofx\\/lgfcu.ofx\"}'),(314,'Wells Fargo Bank','749',1,'{\"fid\":\"3000\",\"org\":\"WF\",\"url\":\"https:\\/\\/ofxdc.wellsfargo.com\\/ofx\\/process.ofx\"}'),(315,'Schwab Retirement Plan Services','750',1,'{\"fid\":\"11811\",\"org\":\"The 401k Company\",\"url\":\"https:\\/\\/ofx1.401kaccess.com\"}'),(316,'Southern Community Bank and Trust (SCB&T)','751',1,'{\"fid\":\"053112097\",\"org\":\"MOneFortyEight\",\"url\":\"https:\\/\\/ofx1.evault.ws\\/OFXServer\\/ofxsrvr.dll\"}'),(317,'Elevations Credit Union IB WC-DC','752',1,'{\"fid\":\"307074580\",\"org\":\"uofcfcu\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx \"}'),(318,'Credit Suisse Securities USA LLC','753',1,'{\"fid\":\"001\",\"org\":\"Credit Suisse Securities USA LLC\",\"url\":\"https:\\/\\/ofx.netxclient.com\\/cgi\\/OFXNetx\"}'),(319,'North Country FCU','754',1,'{\"fid\":\"211691004\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(320,'South Carolina Bank and Trust','755',1,'{\"fid\":\"053200983\",\"org\":\"MZeroOneZeroSCBT\",\"url\":\"https:\\/\\/ofx1.evault.ws\\/ofxserver\\/ofxsrvr.dll\"}'),(321,'Wings Financial','756',1,'{\"fid\":\"296076152\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(322,'Haverhill Bank','757',1,'{\"fid\":\"93\",\"org\":\"orcc\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(323,'Mission Federal Credit Union','758',1,'{\"fid\":\"1001\",\"org\":\"mission\",\"url\":\"https:\\/\\/missionlink.missionfcu.org\\/scripts\\/serverext.dll\"}'),(324,'Southwest Missouri Bank','759',1,'{\"fid\":\"101203641\",\"org\":\"Jack Henry\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(325,'Cambridge Savings Bank','760',1,'{\"fid\":\"211371120\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(326,'NetxClient UAT','761',1,'{\"fid\":\"1023\",\"org\":\"NetxClient\",\"url\":\"https:\\/\\/uat-ofx.netxclient.inautix.com\\/cgi\\/OFXNetx\"}'),(327,'bankfinancial','762',1,'{\"fid\":\"271972899\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(328,'AXA Equitable','763',1,'{\"fid\":\"7199\",\"org\":\"AXA\",\"url\":\"https:\\/\\/ofx.netxclient.com\\/cgi\\/OFXNetx\"}'),(329,'Premier America Credit Union','764',1,'{\"fid\":\"322283990\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(330,'Bank of America - 5959','765',1,'{\"fid\":\"5959\",\"org\":\"HAN\",\"url\":\"https:\\/\\/ofx.bankofamerica.com\\/cgi-forte\\/fortecgi?servicename=ofx_2-3&pagename=ofx\"}'),(331,'First Command Bank','766',1,'{\"fid\":\"188\",\"org\":\"First Command Bank\",\"url\":\"https:\\/\\/www19.onlinebank.com\\/OROFX16Listener\"}'),(332,'TIAA-CREF','767',1,'{\"fid\":\"041\",\"org\":\"tiaa-cref.org\",\"url\":\"https:\\/\\/ofx.netxclient.com\\/cgi\\/OFXNetx\"}'),(333,'Citizens National Bank','768',1,'{\"fid\":\"111903151\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(334,'Tower Federal Credit Union','769',1,'{\"fid\":\"255077370\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(335,'First Republic Bank','770',1,'{\"fid\":\"321081669\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(336,'Texans Credit Union','771',1,'{\"fid\":\"-1\",\"org\":\"TexansCU\",\"url\":\"https:\\/\\/www.netit.financial-net.com\\/ofx\"}'),(337,'AltaOne','772',1,'{\"fid\":\"322274462\",\"org\":\"AltaOneFCU\",\"url\":\"https:\\/\\/msconline.altaone.net\\/scripts\\/isaofx.dll\"}'),(338,'CenterState Bank','773',1,'{\"fid\":\"1942\",\"org\":\"ORCC\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(339,'5 Star Bank','774',1,'{\"fid\":\"307087713\",\"org\":\"5 Star Bank\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(340,'Belmont Savings Bank','775',1,'{\"fid\":\"211371764\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(341,'UNIVERSITY & STATE EMPLOYEES CU','776',1,'{\"fid\":\"322281691\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(342,'Wells Fargo Bank 2013','777',1,'{\"fid\":\"3001\",\"org\":\"Wells Fargo\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/3001.ofxgp\"}'),(343,'The Golden1 Credit Union','778',1,'{\"fid\":\"1001\",\"org\":\"Golden1\",\"url\":\"https:\\/\\/homebanking.golden1.com\\/scripts\\/serverext.dll\"}'),(344,'Woodsboro Bank','779',1,'{\"fid\":\"7479\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\\/\"}'),(345,'Sandia Laboratory Federal Credit Union','780',1,'{\"fid\":\"1001\",\"org\":\"SLFCU\",\"url\":\"https:\\/\\/ofx-prod.slfcu.org\\/ofx\\/process.ofx \"}'),(346,'Oregon Community Credit Union','781',1,'{\"fid\":\"2077\",\"org\":\"ORCC\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(347,'Advantis Credit Union','782',1,'{\"fid\":\"323075097\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(348,'Capital One 360','783',1,'{\"fid\":\"031176110\",\"org\":\"ING DIRECT\",\"url\":\"https:\\/\\/ofx.capitalone360.com\\/OFX\\/ofx.html\"}'),(349,'Flagstar Bank','784',1,'{\"fid\":\"272471852\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(350,'Arizona State Credit Union','785',1,'{\"fid\":\"322172496\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(351,'AmegyBank','786',1,'{\"fid\":\"1165\",\"org\":\"292-3\",\"url\":\"https:\\/\\/pfm.metavante.com\\/ofx\\/OFXServlet\"}'),(352,'Bank of Internet, USA','787',1,'{\"fid\":\"122287251\",\"org\":\"Bank of Internet\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(353,'Amplify Federal Credit Union','788',1,'{\"fid\":\"1\",\"org\":\"Harland Financial Solutions\",\"url\":\"https:\\/\\/ezonline.goamplify.com\\/ofx\\/ofx.dll\"}'),(354,'Capitol Federal Savings Bank','789',1,'{\"fid\":\"1001\",\"org\":\"CapFed\",\"url\":\"https:\\/\\/ofx-prod.capfed.com\\/ofx\\/process.ofx\"}'),(355,'Bank of America - access.ofx','790',1,'{\"fid\":\"5959\",\"org\":\"HAN\",\"url\":\"https:\\/\\/eftx.bankofamerica.com\\/eftxweb\\/access.ofx\"}'),(356,'SVB','791',1,'{\"fid\":\"944\",\"org\":\"SVB\",\"url\":\"https:\\/\\/ofx.svbconnect.com\\/eftxweb\\/access.ofx\"}'),(357,'Iinvestor360','792',1,'{\"fid\":\"7784\",\"org\":\"Fidelity\",\"url\":\"https:\\/\\/www.investor360.net\\/OFX\\/FinService.asmx\\/GetData\"}'),(358,'Sound CU','793',1,'{\"fid\":\"325183220\",\"org\":\"SOUNDCUDC\",\"url\":\"https:\\/\\/mb.soundcu.com\\/OFXServer\\/ofxsrvr.dll\"}'),(359,'Tangerine (Canada)','794',1,'{\"fid\":\"10951\",\"org\":\"TangerineBank\",\"url\":\"https:\\/\\/ofx.tangerine.ca\"}'),(360,'First Tennessee','795',1,'{\"fid\":\"2250\",\"org\":\"Online Financial Services \",\"url\":\"https:\\/\\/ofx.firsttennessee.com\\/ofx\\/ofx_isapi.dll \"}'),(361,'Alaska Air Visa (Bank of America)','796',1,'{\"fid\":\"1142\",\"org\":\"BofA\",\"url\":\"https:\\/\\/akairvisa.iglooware.com\\/visa.php\"}'),(362,'TIAA-CREF Retirement Services','797',1,'{\"fid\":\"1304\",\"org\":\"TIAA-CREF\",\"url\":\"https:\\/\\/ofx-service.tiaa-cref.org\\/public\\/ofx\"}'),(363,'Bofi federal bank','798',1,'{\"fid\":\"122287251\",\"org\":\"Bofi Federal Bank - Business\",\"url\":\"https:\\/\\/directline.netteller.com\"}'),(364,'Vanguard','799',1,'{\"fid\":\"15103\",\"org\":\"Vanguard\",\"url\":\"https:\\/\\/vesnc.vanguard.com\\/us\\/OfxDirectConnectServlet\"}'),(365,'Wright Patt CU','800',1,'{\"fid\":\"242279408\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(366,'Technology Credit Union','801',1,'{\"fid\":\"15079\",\"org\":\"TECHCUDC\",\"url\":\"https:\\/\\/m.techcu.com\\/ofxserver\\/ofxsrvr.dll\"}'),(367,'Capital One Bank (after 12-15-13)','802',1,'{\"fid\":\"1001\",\"org\":\"Capital One\",\"url\":\"https:\\/\\/ofx.capitalone.com\\/ofx\\/103\\/process.ofx\"}'),(368,'Bancorpsouth','803',1,'{\"fid\":\"1001\",\"org\":\"BXS\",\"url\":\"https:\\/\\/ofx-prod.bancorpsouthonline.com\\/ofx\\/process.ofx\"}'),(369,'Monterey Credit Union','804',1,'{\"fid\":\"2059\",\"org\":\"orcc\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(370,'D. A. Davidson','805',1,'{\"fid\":\"59401\",\"org\":\"dadco.com\",\"url\":\"https:\\/\\/pfm.davidsoncompanies.com\\/eftxweb\\/access.ofx\"}'),(371,'Morgan Stanley ClientServ - Quicken Win Format','806',1,'{\"fid\":\"1235\",\"org\":\"msdw.com\",\"url\":\"https:\\/\\/ofx.morganstanleyclientserv.com\\/ofx\\/QuickenWinProfile.ofx\"}'),(372,'Star One Credit Union','807',1,'{\"fid\":\"321177968\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(373,'Scottrade Brokerage','808',1,'{\"fid\":\"777\",\"org\":\"Scottrade\",\"url\":\"https:\\/\\/ofx.scottrade.com\"}'),(374,'Mutual Bank','809',1,'{\"fid\":\"88\",\"org\":\"ORCC\",\"url\":\"https:\\/\\/www20.onlinebank.com\\/OROFX16Listener\"}'),(375,'Affinity Plus Federal Credit Union-New','810',1,'{\"fid\":\"15268\",\"org\":\"Affinity Plus Federal Credit Uni\",\"url\":\"https:\\/\\/mobile.affinityplus.org\\/OFX\\/OFXServer.aspx\"}'),(376,'Suncoast Credit Union','811',1,'{\"fid\":\"15469\",\"org\":\"SunCoast\",\"url\":\"https:\\/\\/ofx.suncoastcreditunion.com\"}'),(377,'Think Mutual Bank','812',1,'{\"fid\":\"10139\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline2.netteller.com\"}'),(378,'La Banque Postale','813',1,'{\"fid\":\"0\",\"org\":\"0\",\"url\":\"https:\\/\\/ofx.videoposte.com\\/\"}'),(379,'Pennsylvania State Employees Credit Union','814',1,'{\"fid\":\"231381116\",\"org\":\"PENNSTATEEMPLOYEES\",\"url\":\"https:\\/\\/directconnect.psecu.com\\/ofxserver\\/ofxsrvr.dll\"}'),(380,'St. Mary\'s Credit Union','815',1,'{\"fid\":\"211384214\",\"org\":\"MSevenThirtySeven\",\"url\":\"https:\\/\\/ofx1.evault.ws\\/OFXServer\\/ofxsrvr.dll\"}'),(381,'Institution For Savings','816',1,'{\"fid\":\"59466\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline2.netteller.com\"}'),(382,'PNC Online Banking','817',1,'{\"fid\":\"4501\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/4501.ofxgp\"}'),(383,'PNC Banking Online','818',1,'{\"fid\":\"4501\",\"org\":\"ISC\",\"url\":\"https:\\/\\/www.oasis.cfree.com\\/4501.ofx\"}'),(384,'Central Bank Utah','820',1,'{\"fid\":\"124300327\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(385,'nuVision Financial FCU','821',1,'{\"fid\":\"322282399\",\"org\":\"DI\",\"url\":\"https:\\/\\/ofxdi.diginsite.com\\/cmr\\/cmr.ofx\"}'),(386,'Landings Credit Union','822',1,'{\"fid\":\"02114\",\"org\":\"JackHenry\",\"url\":\"https:\\/\\/directline.netteller.com\"}');
/*!40000 ALTER TABLE `banks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_contacts`
--

DROP TABLE IF EXISTS `client_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `first_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `confirmation_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `last_login` timestamp NULL DEFAULT NULL,
  `failed_logins` smallint DEFAULT NULL,
  `oauth_user_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oauth_provider_id` int unsigned DEFAULT NULL,
  `google_2fa_secret` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `accepted_terms_version` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `send_email` tinyint(1) NOT NULL DEFAULT '1',
  `contact_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_contacts_oauth_user_id_unique` (`oauth_user_id`),
  UNIQUE KEY `client_contacts_oauth_provider_id_unique` (`oauth_provider_id`),
  KEY `client_contacts_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `client_contacts_company_id_email_deleted_at_index` (`company_id`,`email`,`deleted_at`),
  KEY `client_contacts_company_id_index` (`company_id`),
  KEY `client_contacts_client_id_index` (`client_id`),
  KEY `client_contacts_user_id_index` (`user_id`),
  KEY `client_contacts_contact_key(20)_index` (`contact_key`(20)),
  KEY `client_contacts_email_index` (`email`),
  CONSTRAINT `client_contacts_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_contacts`
--

LOCK TABLES `client_contacts` WRITE;
/*!40000 ALTER TABLE `client_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_gateway_tokens`
--

DROP TABLE IF EXISTS `client_gateway_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_gateway_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `token` text COLLATE utf8mb4_unicode_ci,
  `routing_number` text COLLATE utf8mb4_unicode_ci,
  `company_gateway_id` int unsigned NOT NULL,
  `gateway_customer_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gateway_type_id` int unsigned NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `meta` text COLLATE utf8mb4_unicode_ci,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `client_gateway_tokens_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `client_gateway_tokens_client_id_foreign` (`client_id`),
  CONSTRAINT `client_gateway_tokens_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `client_gateway_tokens_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_gateway_tokens`
--

LOCK TABLES `client_gateway_tokens` WRITE;
/*!40000 ALTER TABLE `client_gateway_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_gateway_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_subscriptions`
--

DROP TABLE IF EXISTS `client_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_subscriptions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `subscription_id` int unsigned NOT NULL,
  `recurring_invoice_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned NOT NULL,
  `trial_started` int unsigned DEFAULT NULL,
  `trial_ends` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `client_subscriptions_subscription_id_foreign` (`subscription_id`),
  KEY `client_subscriptions_recurring_invoice_id_foreign` (`recurring_invoice_id`),
  KEY `client_subscriptions_client_id_foreign` (`client_id`),
  KEY `client_subscriptions_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `client_subscriptions_invoice_id_foreign` (`invoice_id`),
  CONSTRAINT `client_subscriptions_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `client_subscriptions_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `client_subscriptions_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `client_subscriptions_recurring_invoice_id_foreign` FOREIGN KEY (`recurring_invoice_id`) REFERENCES `recurring_invoices` (`id`),
  CONSTRAINT `client_subscriptions_subscription_id_foreign` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_subscriptions`
--

LOCK TABLES `client_subscriptions` WRITE;
/*!40000 ALTER TABLE `client_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `client_hash` text COLLATE utf8mb4_unicode_ci,
  `logo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `balance` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `credit_balance` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `last_login` timestamp NULL DEFAULT NULL,
  `industry_id` int unsigned DEFAULT NULL,
  `size_id` int unsigned DEFAULT NULL,
  `address1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` int unsigned DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `shipping_address1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_address2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_city` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_state` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_postal_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_country_id` int unsigned DEFAULT NULL,
  `settings` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `group_settings_id` int unsigned DEFAULT NULL,
  `vat_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `id_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_balance` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `routing_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_tax_exempt` tinyint(1) NOT NULL DEFAULT '0',
  `has_valid_vat_number` tinyint(1) NOT NULL DEFAULT '0',
  `classification` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `sync` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clients_company_id_number_unique` (`company_id`,`number`),
  KEY `clients_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `clients_industry_id_foreign` (`industry_id`),
  KEY `clients_size_id_foreign` (`size_id`),
  KEY `clients_company_id_index` (`company_id`),
  KEY `clients_user_id_index` (`user_id`),
  KEY `clients_client_hash(20)_index` (`client_hash`(20)),
  CONSTRAINT `clients_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clients_industry_id_foreign` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`id`),
  CONSTRAINT `clients_size_id_foreign` FOREIGN KEY (`size_id`) REFERENCES `sizes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int unsigned NOT NULL,
  `industry_id` int unsigned DEFAULT NULL,
  `ip` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `convert_products` tinyint(1) NOT NULL DEFAULT '0',
  `fill_products` tinyint(1) NOT NULL DEFAULT '1',
  `update_products` tinyint(1) NOT NULL DEFAULT '1',
  `show_product_details` tinyint(1) NOT NULL DEFAULT '1',
  `client_can_register` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_taxes1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_taxes2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_taxes3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_taxes4` tinyint(1) NOT NULL DEFAULT '0',
  `show_product_cost` tinyint(1) NOT NULL DEFAULT '0',
  `enabled_tax_rates` int unsigned NOT NULL DEFAULT '0',
  `enabled_modules` int unsigned NOT NULL DEFAULT '0',
  `enable_product_cost` tinyint(1) NOT NULL DEFAULT '0',
  `enable_product_quantity` tinyint(1) NOT NULL DEFAULT '1',
  `default_quantity` tinyint(1) NOT NULL DEFAULT '1',
  `subdomain` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `db` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size_id` int unsigned DEFAULT NULL,
  `first_day_of_week` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_month_of_year` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `portal_mode` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'subdomain',
  `portal_domain` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enable_modules` smallint NOT NULL DEFAULT '0',
  `custom_fields` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `settings` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `slack_webhook_url` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `google_analytics_key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `enabled_item_tax_rates` int NOT NULL DEFAULT '0',
  `is_large` tinyint(1) NOT NULL DEFAULT '0',
  `enable_shop_api` tinyint(1) NOT NULL DEFAULT '0',
  `default_auto_bill` enum('off','always','optin','optout') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'off',
  `mark_expenses_invoiceable` tinyint(1) NOT NULL DEFAULT '0',
  `mark_expenses_paid` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_expense_documents` tinyint(1) NOT NULL DEFAULT '0',
  `auto_start_tasks` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_task_timelog` tinyint(1) NOT NULL DEFAULT '1',
  `invoice_task_documents` tinyint(1) NOT NULL DEFAULT '0',
  `show_tasks_table` tinyint(1) NOT NULL DEFAULT '0',
  `is_disabled` tinyint(1) NOT NULL DEFAULT '0',
  `default_task_is_date_based` tinyint(1) NOT NULL DEFAULT '0',
  `enable_product_discount` tinyint(1) NOT NULL DEFAULT '0',
  `calculate_expense_tax_by_amount` tinyint(1) NOT NULL,
  `expense_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `session_timeout` int NOT NULL DEFAULT '0',
  `oauth_password_required` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_task_datelog` tinyint(1) NOT NULL DEFAULT '1',
  `default_password_timeout` int NOT NULL DEFAULT '30',
  `show_task_end_date` tinyint(1) NOT NULL DEFAULT '0',
  `markdown_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `use_comma_as_decimal_place` tinyint(1) NOT NULL DEFAULT '0',
  `report_include_drafts` tinyint(1) NOT NULL DEFAULT '0',
  `client_registration_fields` mediumtext COLLATE utf8mb4_unicode_ci,
  `convert_rate_to_client` tinyint(1) NOT NULL DEFAULT '1',
  `markdown_email_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `stop_on_unpaid_recurring` tinyint(1) NOT NULL DEFAULT '0',
  `use_quote_terms_on_conversion` tinyint(1) NOT NULL DEFAULT '0',
  `enable_applying_payments` tinyint(1) NOT NULL DEFAULT '0',
  `track_inventory` tinyint(1) NOT NULL DEFAULT '0',
  `inventory_notification_threshold` int NOT NULL DEFAULT '0',
  `stock_notification` tinyint(1) NOT NULL DEFAULT '1',
  `matomo_url` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `matomo_id` bigint DEFAULT NULL,
  `enabled_expense_tax_rates` int unsigned NOT NULL DEFAULT '0',
  `invoice_task_project` tinyint(1) NOT NULL DEFAULT '0',
  `report_include_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_task_lock` tinyint(1) NOT NULL DEFAULT '0',
  `convert_payment_currency` tinyint(1) NOT NULL DEFAULT '0',
  `convert_expense_currency` tinyint(1) NOT NULL DEFAULT '0',
  `notify_vendor_when_paid` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_task_hours` tinyint(1) NOT NULL DEFAULT '0',
  `calculate_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `shopify_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shopify_access_token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `e_invoice_certificate` text COLLATE utf8mb4_unicode_ci,
  `e_invoice_certificate_passphrase` text COLLATE utf8mb4_unicode_ci,
  `origin_tax_data` text COLLATE utf8mb4_unicode_ci,
  `invoice_task_project_header` tinyint(1) NOT NULL DEFAULT '1',
  `invoice_task_item_description` tinyint(1) NOT NULL DEFAULT '1',
  `smtp_host` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `smtp_port` int unsigned DEFAULT NULL,
  `smtp_encryption` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `smtp_username` text COLLATE utf8mb4_unicode_ci,
  `smtp_password` text COLLATE utf8mb4_unicode_ci,
  `smtp_local_domain` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `smtp_verify_peer` tinyint(1) NOT NULL DEFAULT '1',
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `expense_mailbox_active` tinyint(1) NOT NULL DEFAULT '0',
  `expense_mailbox` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inbound_mailbox_allow_company_users` tinyint(1) NOT NULL DEFAULT '0',
  `inbound_mailbox_allow_vendors` tinyint(1) NOT NULL DEFAULT '0',
  `inbound_mailbox_allow_clients` tinyint(1) NOT NULL DEFAULT '0',
  `inbound_mailbox_allow_unknown` tinyint(1) NOT NULL DEFAULT '0',
  `inbound_mailbox_whitelist` text COLLATE utf8mb4_unicode_ci,
  `inbound_mailbox_blacklist` text COLLATE utf8mb4_unicode_ci,
  `quickbooks` text COLLATE utf8mb4_unicode_ci,
  `legal_entity_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `companies_company_key_unique` (`company_key`),
  KEY `companies_industry_id_foreign` (`industry_id`),
  KEY `companies_size_id_foreign` (`size_id`),
  KEY `companies_account_id_index` (`account_id`),
  KEY `companies_subdomain_portal_mode_index` (`subdomain`,`portal_mode`),
  KEY `companies_portal_domain_portal_mode_index` (`portal_domain`,`portal_mode`),
  KEY `companies_company_key_index` (`company_key`),
  KEY `companies_shopify_name_index` (`shopify_name`),
  KEY `companies_shopify_access_token_index` (`shopify_access_token`),
  CONSTRAINT `companies_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `companies_industry_id_foreign` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`id`),
  CONSTRAINT `companies_size_id_foreign` FOREIGN KEY (`size_id`) REFERENCES `sizes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,1,NULL,'246.74.221.167','p8M4qqnNT3RGrJveBtRVBL2yTe6XHqZ4',0,1,1,1,0,0,0,0,0,0,0,65535,0,1,1,NULL,'mysql',NULL,NULL,NULL,'domain','http://localhost:8080',0,'{}','{\"auto_archive_invoice\":false,\"qr_iban\":\"\",\"besr_id\":\"\",\"lock_invoices\":\"off\",\"enable_client_portal_tasks\":false,\"show_all_tasks_client_portal\":\"invoiced\",\"enable_client_portal_password\":false,\"enable_client_portal\":true,\"enable_client_portal_dashboard\":false,\"signature_on_pdf\":false,\"document_email_attachment\":false,\"portal_design_id\":\"1\",\"timezone_id\":\"1\",\"date_format_id\":\"1\",\"military_time\":false,\"language_id\":\"1\",\"show_currency_code\":false,\"company_gateway_ids\":\"\",\"currency_id\":\"1\",\"custom_value1\":\"\",\"custom_value2\":\"\",\"custom_value3\":\"\",\"custom_value4\":\"\",\"default_task_rate\":0,\"payment_terms\":\"\",\"send_reminders\":true,\"custom_message_dashboard\":\"\",\"custom_message_unpaid_invoice\":\"\",\"custom_message_paid_invoice\":\"\",\"custom_message_unapproved_quote\":\"\",\"auto_archive_quote\":false,\"auto_convert_quote\":true,\"auto_email_invoice\":true,\"entity_send_time\":6,\"inclusive_taxes\":false,\"quote_footer\":\"\",\"translations\":{},\"counter_number_applied\":\"when_saved\",\"quote_number_applied\":\"when_saved\",\"invoice_number_pattern\":\"\",\"invoice_number_counter\":1,\"recurring_invoice_number_pattern\":\"\",\"recurring_invoice_number_counter\":1,\"quote_number_pattern\":\"\",\"quote_number_counter\":1,\"client_number_pattern\":\"\",\"client_number_counter\":1,\"credit_number_pattern\":\"\",\"credit_number_counter\":1,\"task_number_pattern\":\"\",\"task_number_counter\":1,\"expense_number_pattern\":\"\",\"expense_number_counter\":1,\"recurring_expense_number_pattern\":\"\",\"recurring_expense_number_counter\":1,\"recurring_quote_number_pattern\":\"\",\"recurring_quote_number_counter\":1,\"vendor_number_pattern\":\"\",\"vendor_number_counter\":1,\"ticket_number_pattern\":\"\",\"ticket_number_counter\":1,\"payment_number_pattern\":\"\",\"payment_number_counter\":1,\"project_number_pattern\":\"\",\"project_number_counter\":1,\"purchase_order_number_pattern\":\"\",\"purchase_order_number_counter\":1,\"shared_invoice_quote_counter\":false,\"shared_invoice_credit_counter\":false,\"recurring_number_prefix\":\"\",\"reset_counter_frequency_id\":\"0\",\"reset_counter_date\":\"\",\"counter_padding\":4,\"auto_bill\":\"off\",\"auto_bill_date\":\"on_due_date\",\"invoice_terms\":\"\",\"quote_terms\":\"\",\"invoice_taxes\":0,\"invoice_design_id\":\"Wpmbk5ezJn\",\"quote_design_id\":\"Wpmbk5ezJn\",\"credit_design_id\":\"Wpmbk5ezJn\",\"purchase_order_design_id\":\"Wpmbk5ezJn\",\"purchase_order_footer\":\"\",\"purchase_order_terms\":\"\",\"purchase_order_public_notes\":\"\",\"require_purchase_order_signature\":false,\"invoice_footer\":\"\",\"credit_footer\":\"\",\"credit_terms\":\"\",\"invoice_labels\":\"\",\"tax_name1\":\"\",\"tax_rate1\":0,\"tax_name2\":\"\",\"tax_rate2\":0,\"tax_name3\":\"\",\"tax_rate3\":0,\"payment_type_id\":\"0\",\"valid_until\":\"\",\"show_accept_invoice_terms\":false,\"show_accept_quote_terms\":false,\"require_invoice_signature\":false,\"require_quote_signature\":false,\"email_sending_method\":\"default\",\"gmail_sending_user_id\":\"0\",\"reply_to_email\":\"\",\"reply_to_name\":\"\",\"bcc_email\":\"\",\"pdf_email_attachment\":false,\"ubl_email_attachment\":false,\"email_style\":\"light\",\"email_style_custom\":\"\",\"email_subject_invoice\":\"\",\"email_subject_quote\":\"\",\"email_subject_credit\":\"\",\"email_subject_payment\":\"\",\"email_subject_payment_partial\":\"\",\"email_subject_statement\":\"\",\"email_subject_purchase_order\":\"\",\"email_template_purchase_order\":\"\",\"email_template_invoice\":\"\",\"email_template_credit\":\"\",\"email_template_quote\":\"\",\"email_template_payment\":\"\",\"email_template_payment_partial\":\"\",\"email_template_statement\":\"\",\"email_subject_reminder1\":\"\",\"email_subject_reminder2\":\"\",\"email_subject_reminder3\":\"\",\"email_subject_reminder_endless\":\"\",\"email_template_reminder1\":\"\",\"email_template_reminder2\":\"\",\"email_template_reminder3\":\"\",\"email_template_reminder_endless\":\"\",\"email_signature\":\"\",\"enable_email_markup\":true,\"email_subject_custom1\":\"\",\"email_subject_custom2\":\"\",\"email_subject_custom3\":\"\",\"email_template_custom1\":\"\",\"email_template_custom2\":\"\",\"email_template_custom3\":\"\",\"enable_reminder1\":false,\"enable_reminder2\":false,\"enable_reminder3\":false,\"enable_reminder_endless\":false,\"num_days_reminder1\":0,\"num_days_reminder2\":0,\"num_days_reminder3\":0,\"schedule_reminder1\":\"\",\"schedule_reminder2\":\"\",\"schedule_reminder3\":\"\",\"reminder_send_time\":0,\"late_fee_amount1\":0,\"late_fee_amount2\":0,\"late_fee_amount3\":0,\"late_fee_percent1\":0,\"late_fee_percent2\":0,\"late_fee_percent3\":0,\"endless_reminder_frequency_id\":\"0\",\"late_fee_endless_amount\":0,\"late_fee_endless_percent\":0,\"client_online_payment_notification\":true,\"client_manual_payment_notification\":true,\"name\":\"Untitled Company\",\"company_logo\":\"\",\"website\":\"\",\"address1\":\"\",\"address2\":\"\",\"city\":\"\",\"state\":\"\",\"postal_code\":\"\",\"phone\":\"\",\"email\":\"\",\"country_id\":\"840\",\"vat_number\":\"\",\"id_number\":\"\",\"page_size\":\"A4\",\"page_layout\":\"portrait\",\"font_size\":16,\"primary_font\":\"Roboto\",\"secondary_font\":\"Roboto\",\"primary_color\":\"#298AAB\",\"secondary_color\":\"#7081e0\",\"page_numbering\":false,\"page_numbering_alignment\":\"C\",\"hide_paid_to_date\":false,\"embed_documents\":false,\"all_pages_header\":false,\"all_pages_footer\":false,\"pdf_variables\":{\"client_details\":[\"$client.name\",\"$client.number\",\"$client.vat_number\",\"$client.address1\",\"$client.address2\",\"$client.city_state_postal\",\"$client.country\",\"$client.phone\",\"$contact.email\"],\"vendor_details\":[\"$vendor.name\",\"$vendor.number\",\"$vendor.vat_number\",\"$vendor.address1\",\"$vendor.address2\",\"$vendor.city_state_postal\",\"$vendor.country\",\"$vendor.phone\",\"$contact.email\"],\"purchase_order_details\":[\"$purchase_order.number\",\"$purchase_order.po_number\",\"$purchase_order.date\",\"$purchase_order.due_date\",\"$purchase_order.total\",\"$purchase_order.balance_due\"],\"company_details\":[\"$company.name\",\"$company.id_number\",\"$company.vat_number\",\"$company.website\",\"$company.email\",\"$company.phone\"],\"company_address\":[\"$company.address1\",\"$company.address2\",\"$company.city_state_postal\",\"$company.country\"],\"invoice_details\":[\"$invoice.number\",\"$invoice.po_number\",\"$invoice.date\",\"$invoice.due_date\",\"$invoice.total\",\"$invoice.balance_due\",\"$invoice.project\"],\"quote_details\":[\"$quote.number\",\"$quote.po_number\",\"$quote.date\",\"$quote.valid_until\",\"$quote.total\",\"$quote.project\"],\"credit_details\":[\"$credit.number\",\"$credit.po_number\",\"$credit.valid_until\",\"$credit.date\",\"$credit.balance\",\"$credit.total\"],\"product_columns\":[\"$product.item\",\"$product.description\",\"$product.unit_cost\",\"$product.quantity\",\"$product.discount\",\"$product.tax\",\"$product.line_total\"],\"product_quote_columns\":[\"$product.item\",\"$product.description\",\"$product.unit_cost\",\"$product.quantity\",\"$product.discount\",\"$product.tax\",\"$product.line_total\"],\"task_columns\":[\"$task.service\",\"$task.description\",\"$task.rate\",\"$task.hours\",\"$task.discount\",\"$task.tax\",\"$task.line_total\"],\"total_columns\":[\"$net_subtotal\",\"$subtotal\",\"$discount\",\"$custom_surcharge1\",\"$custom_surcharge2\",\"$custom_surcharge3\",\"$custom_surcharge4\",\"$total_taxes\",\"$line_taxes\",\"$total\",\"$paid_to_date\",\"$outstanding\"],\"statement_invoice_columns\":[\"$invoice.number\",\"$invoice.date\",\"$due_date\",\"$total\",\"$balance\"],\"statement_payment_columns\":[\"$invoice.number\",\"$payment.date\",\"$method\",\"$statement_amount\"],\"statement_credit_columns\":[\"$credit.number\",\"$credit.date\",\"$total\",\"$credit.balance\"],\"statement_details\":[\"$statement_date\",\"$balance\"],\"delivery_note_columns\":[\"$product.item\",\"$product.description\",\"$product.quantity\"],\"statement_unapplied_columns\":[\"$payment.number\",\"$payment.date\",\"$payment.amount\",\"$payment.payment_balance\"]},\"portal_custom_head\":\"\",\"portal_custom_css\":\"\",\"portal_custom_footer\":\"\",\"portal_custom_js\":\"\",\"client_can_register\":false,\"client_portal_terms\":\"\",\"client_portal_privacy_policy\":\"\",\"client_portal_enable_uploads\":false,\"client_portal_allow_under_payment\":false,\"client_portal_under_payment_minimum\":0,\"client_portal_allow_over_payment\":false,\"use_credits_payment\":\"off\",\"hide_empty_columns_on_pdf\":false,\"email_from_name\":\"\",\"auto_archive_invoice_cancelled\":false,\"vendor_portal_enable_uploads\":false,\"send_email_on_mark_paid\":false,\"postmark_secret\":\"\",\"custom_sending_email\":\"\",\"mailgun_secret\":\"\",\"mailgun_domain\":\"\",\"mailgun_endpoint\":\"api.mailgun.net\",\"brevo_secret\":\"\",\"auto_bill_standard_invoices\":false,\"email_alignment\":\"center\",\"show_email_footer\":true,\"company_logo_size\":\"\",\"show_paid_stamp\":false,\"show_shipping_address\":false,\"accept_client_input_quote_approval\":false,\"allow_billable_task_items\":true,\"show_task_item_description\":false,\"client_initiated_payments\":false,\"client_initiated_payments_minimum\":0,\"sync_invoice_quote_columns\":true,\"e_invoice_type\":\"EN16931\",\"e_quote_type\":\"OrderX_Comfort\",\"default_expense_payment_type_id\":\"0\",\"enable_e_invoice\":false,\"delivery_note_design_id\":\"\",\"statement_design_id\":\"\",\"payment_receipt_design_id\":\"\",\"payment_refund_design_id\":\"\",\"classification\":\"\",\"payment_email_all_contacts\":false,\"show_pdfhtml_on_mobile\":true,\"use_unapplied_payment\":\"off\",\"enable_rappen_rounding\":false,\"task_round_up\":true,\"task_round_to_nearest\":1,\"merge_e_invoice_to_pdf\":false,\"email_quote_template_reminder1\":\"\",\"email_quote_subject_reminder1\":\"\",\"enable_quote_reminder1\":false,\"quote_num_days_reminder1\":0,\"quote_schedule_reminder1\":\"\",\"quote_late_fee_amount1\":0,\"quote_late_fee_percent1\":0,\"payment_flow\":\"smooth\",\"email_subject_payment_failed\":\"\",\"email_template_payment_failed\":\"\",\"enable_client_profile_update\":true,\"preference_product_notes_for_html_view\":true,\"unlock_invoice_documents_after_payment\":false}','','','2026-09-16 07:56:53.954224','2026-09-16 07:56:53.957405',0,0,0,'off',0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1800000,0,1,0,0,'[{\"key\":\"first_name\",\"required\":true,\"visible\":true},{\"key\":\"last_name\",\"required\":true,\"visible\":true},{\"key\":\"email\",\"required\":true,\"visible\":true},{\"key\":\"phone\",\"required\":false,\"visible\":true},{\"key\":\"password\",\"required\":true,\"visible\":true},{\"key\":\"name\",\"required\":false,\"visible\":false},{\"key\":\"website\",\"required\":false,\"visible\":false},{\"key\":\"address1\",\"required\":false,\"visible\":false},{\"key\":\"address2\",\"required\":false,\"visible\":false},{\"key\":\"city\",\"required\":false,\"visible\":false},{\"key\":\"state\",\"required\":false,\"visible\":false},{\"key\":\"postal_code\",\"required\":false,\"visible\":false},{\"key\":\"country_id\",\"required\":false,\"visible\":false},{\"key\":\"custom_value1\",\"required\":false,\"visible\":false},{\"key\":\"custom_value2\",\"required\":false,\"visible\":false},{\"key\":\"custom_value3\",\"required\":false,\"visible\":false},{\"key\":\"custom_value4\",\"required\":false,\"visible\":false},{\"key\":\"public_notes\",\"required\":false,\"visible\":false},{\"key\":\"vat_number\",\"required\":false,\"visible\":false},{\"key\":\"currency_id\",\"required\":false,\"visible\":false}]',1,0,0,0,0,0,0,1,NULL,NULL,0,0,0,0,0,0,0,0,0,'{\"seller_subregion\":\"CA\",\"version\":\"delta\",\"regions\":{\"US\":{\"has_sales_above_threshold\":false,\"tax_all_subregions\":false,\"subregions\":{\"AL\":{\"apply_tax\":false,\"tax_rate\":4,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"AK\":{\"apply_tax\":false,\"tax_rate\":0,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"AZ\":{\"apply_tax\":false,\"tax_rate\":5.6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"AR\":{\"apply_tax\":false,\"tax_rate\":6.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"CA\":{\"apply_tax\":false,\"tax_rate\":7.25,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"CO\":{\"apply_tax\":false,\"tax_rate\":2.9,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"CT\":{\"apply_tax\":false,\"tax_rate\":6.35,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"DE\":{\"apply_tax\":false,\"tax_rate\":0,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"FL\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"GA\":{\"apply_tax\":false,\"tax_rate\":4,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"HI\":{\"apply_tax\":false,\"tax_rate\":4,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"ID\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"IL\":{\"apply_tax\":false,\"tax_rate\":6.25,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"IN\":{\"apply_tax\":false,\"tax_rate\":7,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"IA\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"KS\":{\"apply_tax\":false,\"tax_rate\":6.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"KY\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"LA\":{\"apply_tax\":false,\"tax_rate\":4.45,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"ME\":{\"apply_tax\":false,\"tax_rate\":5.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MD\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MA\":{\"apply_tax\":false,\"tax_rate\":6.25,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MI\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MN\":{\"apply_tax\":false,\"tax_rate\":6.875,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MS\":{\"apply_tax\":false,\"tax_rate\":7,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MO\":{\"apply_tax\":false,\"tax_rate\":4.225,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"MT\":{\"apply_tax\":false,\"tax_rate\":0,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NE\":{\"apply_tax\":false,\"tax_rate\":5.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NV\":{\"apply_tax\":false,\"tax_rate\":6.85,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NH\":{\"apply_tax\":false,\"tax_rate\":0,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NJ\":{\"apply_tax\":false,\"tax_rate\":6.625,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NM\":{\"apply_tax\":false,\"tax_rate\":5.125,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NY\":{\"apply_tax\":false,\"tax_rate\":4,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"NC\":{\"apply_tax\":false,\"tax_rate\":4.75,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"ND\":{\"apply_tax\":false,\"tax_rate\":5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"OH\":{\"apply_tax\":false,\"tax_rate\":5.75,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"OK\":{\"apply_tax\":false,\"tax_rate\":4.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"OR\":{\"apply_tax\":false,\"tax_rate\":0,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"PA\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"RI\":{\"apply_tax\":false,\"tax_rate\":7,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"SC\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"SD\":{\"apply_tax\":false,\"tax_rate\":4.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"TN\":{\"apply_tax\":false,\"tax_rate\":7,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"TX\":{\"apply_tax\":false,\"tax_rate\":6.25,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"UT\":{\"apply_tax\":false,\"tax_rate\":5.95,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"VT\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"VA\":{\"apply_tax\":false,\"tax_rate\":5.3,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"WA\":{\"apply_tax\":false,\"tax_rate\":6.5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"WV\":{\"apply_tax\":false,\"tax_rate\":6,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"WI\":{\"apply_tax\":false,\"tax_rate\":5,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"},\"WY\":{\"apply_tax\":false,\"tax_rate\":4,\"tax_name\":\"Sales Tax\",\"vat_number\":\"\"}}},\"EU\":{\"has_sales_above_threshold\":false,\"tax_all_subregions\":false,\"tax_threshold\":10000,\"subregions\":{\"AT\":{\"tax_rate\":20,\"tax_name\":\"USt\",\"reduced_tax_rate\":10,\"apply_tax\":false,\"vat_number\":\"\"},\"BE\":{\"tax_rate\":21,\"tax_name\":\"BTW\",\"reduced_tax_rate\":6,\"apply_tax\":false,\"vat_number\":\"\"},\"BG\":{\"tax_rate\":20,\"tax_name\":\"\\u041d\\u0414\\u0421\",\"reduced_tax_rate\":9,\"apply_tax\":false,\"vat_number\":\"\"},\"CY\":{\"tax_rate\":19,\"tax_name\":\"\\u03a6\\u03a0\\u0391\",\"reduced_tax_rate\":9,\"apply_tax\":false,\"vat_number\":\"\"},\"CZ\":{\"tax_rate\":21,\"tax_name\":\"DPH\",\"reduced_tax_rate\":15,\"apply_tax\":false,\"vat_number\":\"\"},\"DE\":{\"tax_rate\":19,\"tax_name\":\"MwSt\",\"reduced_tax_rate\":7,\"apply_tax\":false,\"vat_number\":\"\"},\"DK\":{\"tax_rate\":25,\"tax_name\":\"Moms\",\"reduced_tax_rate\":0,\"apply_tax\":false,\"vat_number\":\"\"},\"EE\":{\"tax_rate\":20,\"tax_name\":\"KM\",\"reduced_tax_rate\":9,\"apply_tax\":false,\"vat_number\":\"\"},\"ES\":{\"tax_rate\":21,\"tax_name\":\"IVA\",\"reduced_tax_rate\":10,\"apply_tax\":false,\"vat_number\":\"\"},\"ES-CE\":{\"tax_rate\":4,\"tax_name\":\"IGIC\",\"reduced_tax_rate\":4,\"apply_tax\":false,\"vat_number\":\"\"},\"ES-ML\":{\"tax_rate\":4,\"tax_name\":\"IGIC\",\"reduced_tax_rate\":4,\"apply_tax\":false,\"vat_number\":\"\"},\"ES-CN\":{\"tax_rate\":7,\"tax_name\":\"IGIC\",\"reduced_tax_rate\":3,\"apply_tax\":false,\"vat_number\":\"\"},\"FI\":{\"tax_rate\":24,\"tax_name\":\"ALV\",\"reduced_tax_rate\":14,\"apply_tax\":false,\"vat_number\":\"\"},\"FR\":{\"tax_rate\":20,\"tax_name\":\"TVA\",\"reduced_tax_rate\":5.5,\"apply_tax\":false,\"vat_number\":\"\"},\"GR\":{\"tax_rate\":24,\"tax_name\":\"\\u03a6\\u03a0\\u0391\",\"reduced_tax_rate\":13,\"apply_tax\":false,\"vat_number\":\"\"},\"HR\":{\"tax_rate\":25,\"tax_name\":\"PDV\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"HU\":{\"tax_rate\":27,\"tax_name\":\"\\u00c1FA\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"IE\":{\"tax_rate\":23,\"tax_name\":\"VAT\",\"reduced_tax_rate\":0,\"apply_tax\":false,\"vat_number\":\"\"},\"IS\":{\"tax_rate\":24,\"tax_name\":\"VSK\",\"reduced_tax_rate\":11,\"apply_tax\":false,\"vat_number\":\"\"},\"IT\":{\"tax_rate\":22,\"tax_name\":\"IVA\",\"reduced_tax_rate\":10,\"apply_tax\":false,\"vat_number\":\"\"},\"LI\":{\"tax_rate\":8.1,\"tax_name\":\"MWST\",\"reduced_tax_rate\":2.6,\"apply_tax\":false,\"vat_number\":\"\"},\"LT\":{\"tax_rate\":21,\"tax_name\":\"PVM\",\"reduced_tax_rate\":9,\"apply_tax\":false,\"vat_number\":\"\"},\"LU\":{\"tax_rate\":17,\"tax_name\":\"TVA\",\"reduced_tax_rate\":3,\"apply_tax\":false,\"vat_number\":\"\"},\"LV\":{\"tax_rate\":21,\"tax_name\":\"PVN\",\"reduced_tax_rate\":12,\"apply_tax\":false,\"vat_number\":\"\"},\"MT\":{\"tax_rate\":18,\"tax_name\":\"VAT\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"NO\":{\"tax_rate\":25,\"tax_name\":\"MVA\",\"reduced_tax_rate\":12,\"apply_tax\":false,\"vat_number\":\"\"},\"NL\":{\"tax_rate\":21,\"tax_name\":\"BTW\",\"reduced_tax_rate\":9,\"apply_tax\":false,\"vat_number\":\"\"},\"PL\":{\"tax_rate\":23,\"tax_name\":\"VAT\",\"reduced_tax_rate\":8,\"apply_tax\":false,\"vat_number\":\"\"},\"PT\":{\"tax_rate\":23,\"tax_name\":\"IVA\",\"reduced_tax_rate\":6,\"apply_tax\":false,\"vat_number\":\"\"},\"RO\":{\"tax_rate\":19,\"tax_name\":\"TVA\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"SE\":{\"tax_rate\":25,\"tax_name\":\"Moms\",\"reduced_tax_rate\":12,\"apply_tax\":false,\"vat_number\":\"\"},\"SI\":{\"tax_rate\":22,\"tax_name\":\"DDV\",\"reduced_tax_rate\":9.5,\"apply_tax\":false,\"vat_number\":\"\"},\"SK\":{\"tax_rate\":20,\"tax_name\":\"DPH\",\"reduced_tax_rate\":10,\"apply_tax\":false,\"vat_number\":\"\"}}},\"AU\":{\"has_sales_above_threshold\":false,\"tax_all_subregions\":false,\"tax_threshold\":75000,\"subregions\":{\"AU\":{\"apply_tax\":false,\"tax_rate\":10,\"tax_name\":\"GST\",\"vat_number\":\"\"}}},\"UK\":{\"has_sales_above_threshold\":false,\"tax_threshold\":85000,\"tax_all_subregions\":false,\"subregions\":{\"GB\":{\"tax_rate\":20,\"tax_name\":\"VAT\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"GB-NIR\":{\"tax_rate\":20,\"tax_name\":\"VAT\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"},\"IM\":{\"tax_rate\":20,\"tax_name\":\"VAT\",\"reduced_tax_rate\":5,\"apply_tax\":false,\"vat_number\":\"\"}}}},\"acts_as_sender\":false,\"acts_as_receiver\":false,\"model\":null}',NULL,NULL,NULL,NULL,NULL,1,1,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,0,NULL,0,0,0,0,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_gateways`
--

DROP TABLE IF EXISTS `company_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_gateways` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `gateway_key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `accepted_credit_cards` int unsigned NOT NULL,
  `require_cvv` tinyint(1) NOT NULL DEFAULT '1',
  `require_billing_address` tinyint(1) DEFAULT '1',
  `require_shipping_address` tinyint(1) DEFAULT '1',
  `update_details` tinyint(1) DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `config` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `fees_and_limits` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `custom_value1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value4` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `token_billing` enum('off','always','optin','optout') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'off',
  `label` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `require_client_name` tinyint(1) NOT NULL DEFAULT '0',
  `require_postal_code` tinyint(1) NOT NULL DEFAULT '0',
  `require_client_phone` tinyint(1) NOT NULL DEFAULT '0',
  `require_contact_name` tinyint(1) NOT NULL DEFAULT '0',
  `require_contact_email` tinyint(1) NOT NULL DEFAULT '0',
  `require_custom_value1` tinyint(1) NOT NULL DEFAULT '0',
  `require_custom_value2` tinyint(1) NOT NULL DEFAULT '0',
  `require_custom_value3` tinyint(1) NOT NULL DEFAULT '0',
  `require_custom_value4` tinyint(1) NOT NULL DEFAULT '0',
  `always_show_required_fields` tinyint(1) NOT NULL DEFAULT '1',
  `settings` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `company_gateways_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `company_gateways_gateway_key_foreign` (`gateway_key`),
  KEY `company_gateways_user_id_foreign` (`user_id`),
  CONSTRAINT `company_gateways_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `company_gateways_gateway_key_foreign` FOREIGN KEY (`gateway_key`) REFERENCES `gateways` (`key`),
  CONSTRAINT `company_gateways_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_gateways`
--

LOCK TABLES `company_gateways` WRITE;
/*!40000 ALTER TABLE `company_gateways` DISABLE KEYS */;
/*!40000 ALTER TABLE `company_gateways` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_ledgers`
--

DROP TABLE IF EXISTS `company_ledgers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_ledgers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `activity_id` int unsigned DEFAULT NULL,
  `adjustment` decimal(20,6) DEFAULT NULL,
  `balance` decimal(20,6) DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `hash` text COLLATE utf8mb4_unicode_ci,
  `company_ledgerable_id` int unsigned NOT NULL,
  `company_ledgerable_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_ledgers_company_id_foreign` (`company_id`),
  KEY `company_ledgers_client_id_foreign` (`client_id`),
  CONSTRAINT `company_ledgers_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `company_ledgers_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_ledgers`
--

LOCK TABLES `company_ledgers` WRITE;
/*!40000 ALTER TABLE `company_ledgers` DISABLE KEYS */;
/*!40000 ALTER TABLE `company_ledgers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_tokens`
--

DROP TABLE IF EXISTS `company_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `account_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `company_tokens_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `company_tokens_account_id_foreign` (`account_id`),
  KEY `company_tokens_user_id_foreign` (`user_id`),
  KEY `company_tokens_company_id_index` (`company_id`),
  KEY `company_tokens_token_deleted_at_index` (`token`,`deleted_at`),
  CONSTRAINT `company_tokens_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `company_tokens_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `company_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_tokens`
--

LOCK TABLES `company_tokens` WRITE;
/*!40000 ALTER TABLE `company_tokens` DISABLE KEYS */;
INSERT INTO `company_tokens` VALUES (1,1,1,1,'am22bQTcfMdCLUIXWs2pRIAdPG1Gv1t2JEQRNOPzYRmSUhws846s8S7ig6HrNKgi','User Token','2026-09-16 07:56:54.076905','2026-09-16 07:56:54.076905',NULL,0,1);
/*!40000 ALTER TABLE `company_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_user`
--

DROP TABLE IF EXISTS `company_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_user` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `account_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `permissions` mediumtext COLLATE utf8mb4_unicode_ci,
  `notifications` mediumtext COLLATE utf8mb4_unicode_ci,
  `settings` mediumtext COLLATE utf8mb4_unicode_ci,
  `slack_webhook_url` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_owner` tinyint(1) NOT NULL DEFAULT '0',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `permissions_updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ninja_portal_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `react_settings` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `company_user_company_id_user_id_unique` (`company_id`,`user_id`),
  KEY `company_user_account_id_company_id_deleted_at_index` (`account_id`,`company_id`,`deleted_at`),
  KEY `company_user_user_id_index` (`user_id`),
  CONSTRAINT `company_user_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `company_user_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_user`
--

LOCK TABLES `company_user` WRITE;
/*!40000 ALTER TABLE `company_user` DISABLE KEYS */;
INSERT INTO `company_user` VALUES (1,1,1,1,NULL,'{\"email\":[\"invoice_sent_all\"]}',NULL,'',1,1,0,NULL,'2026-09-16 07:56:54.078685','2026-09-16 07:56:54.078685','2026-09-16 07:56:54','',NULL);
/*!40000 ALTER TABLE `company_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `capital` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `citizenship` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_code` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency_sub_unit` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `iso_3166_2` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `iso_3166_3` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `region_code` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_region_code` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eea` tinyint(1) NOT NULL DEFAULT '0',
  `swap_postal_code` tinyint(1) NOT NULL DEFAULT '0',
  `swap_currency_symbol` tinyint(1) NOT NULL DEFAULT '0',
  `thousand_separator` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `decimal_separator` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=895 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES (4,'Kabul','Afghan','004','afghani','AFN','pul','Islamic Republic of Afghanistan','AF','AFG','Afghanistan','142','034',0,0,0,'',''),(8,'Tirana','Albanian','008','lek','ALL','(qindar (pl. qindarka))','Republic of Albania','AL','ALB','Albania','150','039',0,0,0,'',''),(10,'Antartica','of Antartica','010','','','','Antarctica','AQ','ATA','Antarctica','','',0,0,0,'',''),(12,'Algiers','Algerian','012','Algerian dinar','DZD','centime','People’s Democratic Republic of Algeria','DZ','DZA','Algeria','002','015',0,0,0,'',''),(16,'Pago Pago','American Samoan','016','US dollar','USD','cent','Territory of American','AS','ASM','American Samoa','009','061',0,0,0,'',''),(20,'Andorra la Vella','Andorran','020','euro','EUR','cent','Principality of Andorra','AD','AND','Andorra','150','039',0,0,0,'',''),(24,'Luanda','Angolan','024','kwanza','AOA','cêntimo','Republic of Angola','AO','AGO','Angola','002','017',0,0,0,'',''),(28,'St John’s','of Antigua and Barbuda','028','East Caribbean dollar','XCD','cent','Antigua and Barbuda','AG','ATG','Antigua and Barbuda','019','029',0,0,0,'',''),(31,'Baku','Azerbaijani','031','Azerbaijani manat','AZN','kepik (inv.)','Republic of Azerbaijan','AZ','AZE','Azerbaijan','142','145',0,0,0,'',''),(32,'Buenos Aires','Argentinian','032','Argentine peso','ARS','centavo','Argentine Republic','AR','ARG','Argentina','019','005',0,1,0,'',''),(36,'Canberra','Australian','036','Australian dollar','AUD','cent','Commonwealth of Australia','AU','AUS','Australia','009','053',0,0,0,'',''),(40,'Vienna','Austrian','040','euro','EUR','cent','Republic of Austria','AT','AUT','Austria','150','155',1,1,1,'',''),(44,'Nassau','Bahamian','044','Bahamian dollar','BSD','cent','Commonwealth of the Bahamas','BS','BHS','Bahamas','019','029',0,0,0,'',''),(48,'Manama','Bahraini','048','Bahraini dinar','BHD','fils (inv.)','Kingdom of Bahrain','BH','BHR','Bahrain','142','145',0,0,0,'',''),(50,'Dhaka','Bangladeshi','050','taka (inv.)','BDT','poisha (inv.)','People’s Republic of Bangladesh','BD','BGD','Bangladesh','142','034',0,0,0,'',''),(51,'Yerevan','Armenian','051','dram (inv.)','AMD','luma','Republic of Armenia','AM','ARM','Armenia','142','145',0,0,0,'',''),(52,'Bridgetown','Barbadian','052','Barbados dollar','BBD','cent','Barbados','BB','BRB','Barbados','019','029',0,0,0,'',''),(56,'Brussels','Belgian','056','euro','EUR','cent','Kingdom of Belgium','BE','BEL','Belgium','150','155',1,1,0,'',''),(60,'Hamilton','Bermudian','060','Bermuda dollar','BMD','cent','Bermuda','BM','BMU','Bermuda','019','021',0,0,0,'',''),(64,'Thimphu','Bhutanese','064','ngultrum (inv.)','BTN','chhetrum (inv.)','Kingdom of Bhutan','BT','BTN','Bhutan','142','034',0,0,0,'',''),(68,'Sucre (BO1)','Bolivian','068','boliviano','BOB','centavo','Plurinational State of Bolivia','BO','BOL','Bolivia, Plurinational State of','019','005',0,0,0,'',''),(70,'Sarajevo','of Bosnia and Herzegovina','070','convertible mark','BAM','fening','Bosnia and Herzegovina','BA','BIH','Bosnia and Herzegovina','150','039',0,0,0,'',''),(72,'Gaborone','Botswanan','072','pula (inv.)','BWP','thebe (inv.)','Republic of Botswana','BW','BWA','Botswana','002','018',0,0,0,'',''),(74,'Bouvet island','of Bouvet island','074','','','','Bouvet Island','BV','BVT','Bouvet Island','','',0,0,0,'',''),(76,'Brasilia','Brazilian','076','real (pl. reais)','BRL','centavo','Federative Republic of Brazil','BR','BRA','Brazil','019','005',0,0,0,'',''),(84,'Belmopan','Belizean','084','Belize dollar','BZD','cent','Belize','BZ','BLZ','Belize','019','013',0,0,0,'',''),(86,'Diego Garcia','Changosian','086','US dollar','USD','cent','British Indian Ocean Territory','IO','IOT','British Indian Ocean Territory','','',0,0,0,'',''),(90,'Honiara','Solomon Islander','090','Solomon Islands dollar','SBD','cent','Solomon Islands','SB','SLB','Solomon Islands','009','054',0,0,0,'',''),(92,'Road Town','British Virgin Islander;','092','US dollar','USD','cent','British Virgin Islands','VG','VGB','Virgin Islands, British','019','029',0,0,0,'',''),(96,'Bandar Seri Begawan','Bruneian','096','Brunei dollar','BND','sen (inv.)','Brunei Darussalam','BN','BRN','Brunei Darussalam','142','035',0,0,0,'',''),(100,'Sofia','Bulgarian','100','lev (pl. leva)','BGN','stotinka','Republic of Bulgaria','BG','BGR','Bulgaria','150','151',1,0,1,'',''),(104,'Yangon','Burmese','104','kyat','MMK','pya','Union of Myanmar/','MM','MMR','Myanmar','142','035',0,0,0,'',''),(108,'Bujumbura','Burundian','108','Burundi franc','BIF','centime','Republic of Burundi','BI','BDI','Burundi','002','014',0,0,0,'',''),(112,'Minsk','Belarusian','112','Belarusian rouble','BYR','kopek','Republic of Belarus','BY','BLR','Belarus','150','151',0,0,0,'',''),(116,'Phnom Penh','Cambodian','116','riel','KHR','sen (inv.)','Kingdom of Cambodia','KH','KHM','Cambodia','142','035',0,0,0,'',''),(120,'Yaoundé','Cameroonian','120','CFA franc (BEAC)','XAF','centime','Republic of Cameroon','CM','CMR','Cameroon','002','017',0,0,0,'',''),(124,'Ottawa','Canadian','124','Canadian dollar','CAD','cent','Canada','CA','CAN','Canada','019','021',0,0,0,',','.'),(132,'Praia','Cape Verdean','132','Cape Verde escudo','CVE','centavo','Republic of Cape Verde','CV','CPV','Cape Verde','002','011',0,0,0,'',''),(136,'George Town','Caymanian','136','Cayman Islands dollar','KYD','cent','Cayman Islands','KY','CYM','Cayman Islands','019','029',0,0,0,'',''),(140,'Bangui','Central African','140','CFA franc (BEAC)','XAF','centime','Central African Republic','CF','CAF','Central African Republic','002','017',0,0,0,'',''),(144,'Colombo','Sri Lankan','144','Sri Lankan rupee','LKR','cent','Democratic Socialist Republic of Sri Lanka','LK','LKA','Sri Lanka','142','034',0,0,0,'',''),(148,'N’Djamena','Chadian','148','CFA franc (BEAC)','XAF','centime','Republic of Chad','TD','TCD','Chad','002','017',0,0,0,'',''),(152,'Santiago','Chilean','152','Chilean peso','CLP','centavo','Republic of Chile','CL','CHL','Chile','019','005',0,0,0,'',''),(156,'Beijing','Chinese','156','renminbi-yuan (inv.)','CNY','jiao (10)','People’s Republic of China','CN','CHN','China','142','030',0,0,0,'',''),(158,'Taipei','Taiwanese','158','new Taiwan dollar','TWD','fen (inv.)','Republic of China, Taiwan (TW1)','TW','TWN','Taiwan, Province of China','142','030',0,0,0,'',''),(162,'Flying Fish Cove','Christmas Islander','162','Australian dollar','AUD','cent','Christmas Island Territory','CX','CXR','Christmas Island','','',0,0,0,'',''),(166,'Bantam','Cocos Islander','166','Australian dollar','AUD','cent','Territory of Cocos (Keeling) Islands','CC','CCK','Cocos (Keeling) Islands','','',0,0,0,'',''),(170,'Santa Fe de Bogotá','Colombian','170','Colombian peso','COP','centavo','Republic of Colombia','CO','COL','Colombia','019','005',0,0,0,'',''),(174,'Moroni','Comorian','174','Comorian franc','KMF','','Union of the Comoros','KM','COM','Comoros','002','014',0,0,0,'',''),(175,'Mamoudzou','Mahorais','175','euro','EUR','cent','Departmental Collectivity of Mayotte','YT','MYT','Mayotte','002','014',0,0,0,'',''),(178,'Brazzaville','Congolese','178','CFA franc (BEAC)','XAF','centime','Republic of the Congo','CG','COG','Congo','002','017',0,0,0,'',''),(180,'Kinshasa','Congolese','180','Congolese franc','CDF','centime','Democratic Republic of the Congo','CD','COD','Congo, the Democratic Republic of the','002','017',0,0,0,'',''),(184,'Avarua','Cook Islander','184','New Zealand dollar','NZD','cent','Cook Islands','CK','COK','Cook Islands','009','061',0,0,0,'',''),(188,'San José','Costa Rican','188','Costa Rican colón (pl. colones)','CRC','céntimo','Republic of Costa Rica','CR','CRI','Costa Rica','019','013',0,0,0,'',''),(191,'Zagreb','Croatian','191','kuna (inv.)','HRK','lipa (inv.)','Republic of Croatia','HR','HRV','Croatia','150','039',1,0,1,'',''),(192,'Havana','Cuban','192','Cuban peso','CUP','centavo','Republic of Cuba','CU','CUB','Cuba','019','029',0,0,0,'',''),(196,'Nicosia','Cypriot','196','euro','EUR','cent','Republic of Cyprus','CY','CYP','Cyprus','142','145',1,0,0,'',''),(203,'Prague','Czech','203','Czech koruna (pl. koruny)','CZK','halér','Czech Republic','CZ','CZE','Czech Republic','150','151',1,0,1,'',''),(204,'Porto Novo (BJ1)','Beninese','204','CFA franc (BCEAO)','XOF','centime','Republic of Benin','BJ','BEN','Benin','002','011',0,0,0,'',''),(208,'Copenhagen','Danish','208','Danish krone','DKK','øre (inv.)','Kingdom of Denmark','DK','DNK','Denmark','150','154',1,1,0,'',''),(212,'Roseau','Dominican','212','East Caribbean dollar','XCD','cent','Commonwealth of Dominica','DM','DMA','Dominica','019','029',0,0,0,'',''),(214,'Santo Domingo','Dominican','214','Dominican peso','DOP','centavo','Dominican Republic','DO','DOM','Dominican Republic','019','029',0,0,0,'',''),(218,'Quito','Ecuadorian','218','US dollar','USD','cent','Republic of Ecuador','EC','ECU','Ecuador','019','005',0,0,0,'',''),(222,'San Salvador','Salvadoran','222','Salvadorian colón (pl. colones)','SVC','centavo','Republic of El Salvador','SV','SLV','El Salvador','019','013',0,0,0,'',''),(226,'Malabo','Equatorial Guinean','226','CFA franc (BEAC)','XAF','centime','Republic of Equatorial Guinea','GQ','GNQ','Equatorial Guinea','002','017',0,0,0,'',''),(231,'Addis Ababa','Ethiopian','231','birr (inv.)','ETB','cent','Federal Democratic Republic of Ethiopia','ET','ETH','Ethiopia','002','014',0,0,0,'',''),(232,'Asmara','Eritrean','232','nakfa','ERN','cent','State of Eritrea','ER','ERI','Eritrea','002','014',0,0,0,'',''),(233,'Tallinn','Estonian','233','euro','EUR','cent','Republic of Estonia','EE','EST','Estonia','150','154',1,0,1,' ',''),(234,'Tórshavn','Faeroese','234','Danish krone','DKK','øre (inv.)','Faeroe Islands','FO','FRO','Faroe Islands','150','154',0,0,0,'',''),(238,'Stanley','Falkland Islander','238','Falkland Islands pound','FKP','new penny','Falkland Islands','FK','FLK','Falkland Islands (Malvinas)','019','005',0,0,0,'',''),(239,'King Edward Point (Grytviken)','of South Georgia and the South Sandwich Islands','239','','','','South Georgia and the South Sandwich Islands','GS','SGS','South Georgia and the South Sandwich Islands','','',0,0,0,'',''),(242,'Suva','Fijian','242','Fiji dollar','FJD','cent','Republic of Fiji','FJ','FJI','Fiji','009','054',0,0,0,'',''),(246,'Helsinki','Finnish','246','euro','EUR','cent','Republic of Finland','FI','FIN','Finland','150','154',1,1,1,'',''),(248,'Mariehamn','Åland Islander','248','euro','EUR','cent','Åland Islands','AX','ALA','Åland Islands','150','154',0,0,0,'',''),(250,'Paris','French','250','euro','EUR','cent','French Republic','FR','FRA','France','150','155',1,1,1,' ',''),(254,'Cayenne','Guianese','254','euro','EUR','cent','French Guiana','GF','GUF','French Guiana','019','005',0,0,0,'',''),(258,'Papeete','Polynesian','258','CFP franc','XPF','centime','French Polynesia','PF','PYF','French Polynesia','009','061',0,0,0,'',''),(260,'Port-aux-Francais','of French Southern and Antarctic Lands','260','euro','EUR','cent','French Southern and Antarctic Lands','TF','ATF','French Southern Territories','','',0,0,0,'',''),(262,'Djibouti','Djiboutian','262','Djibouti franc','DJF','','Republic of Djibouti','DJ','DJI','Djibouti','002','014',0,0,0,'',''),(266,'Libreville','Gabonese','266','CFA franc (BEAC)','XAF','centime','Gabonese Republic','GA','GAB','Gabon','002','017',0,0,0,'',''),(268,'Tbilisi','Georgian','268','lari','GEL','tetri (inv.)','Georgia','GE','GEO','Georgia','142','145',0,0,0,'',''),(270,'Banjul','Gambian','270','dalasi (inv.)','GMD','butut','Republic of the Gambia','GM','GMB','Gambia','002','011',0,0,0,'',''),(275,NULL,'Palestinian','275',NULL,NULL,NULL,NULL,'PS','PSE','Palestine','142','145',0,0,0,'',''),(276,'Berlin','German','276','euro','EUR','cent','Federal Republic of Germany','DE','DEU','Germany','150','155',1,1,1,'',''),(288,'Accra','Ghanaian','288','Ghana cedi','GHS','pesewa','Republic of Ghana','GH','GHA','Ghana','002','011',0,0,0,'',''),(292,'Gibraltar','Gibraltarian','292','Gibraltar pound','GIP','penny','Gibraltar','GI','GIB','Gibraltar','150','039',0,0,0,'',''),(296,'Tarawa','Kiribatian','296','Australian dollar','AUD','cent','Republic of Kiribati','KI','KIR','Kiribati','009','057',0,0,0,'',''),(300,'Athens','Greek','300','euro','EUR','cent','Hellenic Republic','GR','GRC','Greece','150','039',1,0,1,'',''),(304,'Nuuk','Greenlander','304','Danish krone','DKK','øre (inv.)','Greenland','GL','GRL','Greenland','019','021',0,1,0,'',''),(308,'St George’s','Grenadian','308','East Caribbean dollar','XCD','cent','Grenada','GD','GRD','Grenada','019','029',0,0,0,'',''),(312,'Basse Terre','Guadeloupean','312','euro','EUR','cent','Guadeloupe','GP','GLP','Guadeloupe','019','029',0,0,0,'',''),(316,'Agaña (Hagåtña)','Guamanian','316','US dollar','USD','cent','Territory of Guam','GU','GUM','Guam','009','057',0,0,0,'',''),(320,'Guatemala City','Guatemalan','320','quetzal (pl. quetzales)','GTQ','centavo','Republic of Guatemala','GT','GTM','Guatemala','019','013',0,0,0,'',''),(324,'Conakry','Guinean','324','Guinean franc','GNF','','Republic of Guinea','GN','GIN','Guinea','002','011',0,0,0,'',''),(328,'Georgetown','Guyanese','328','Guyana dollar','GYD','cent','Cooperative Republic of Guyana','GY','GUY','Guyana','019','005',0,0,0,'',''),(332,'Port-au-Prince','Haitian','332','gourde','HTG','centime','Republic of Haiti','HT','HTI','Haiti','019','029',0,0,0,'',''),(334,'Territory of Heard Island and McDonald Islands','of Territory of Heard Island and McDonald Islands','334','','','','Territory of Heard Island and McDonald Islands','HM','HMD','Heard Island and McDonald Islands','','',0,0,0,'',''),(336,'Vatican City','of the Holy See/of the Vatican','336','euro','EUR','cent','the Holy See/ Vatican City State','VA','VAT','Holy See (Vatican City State)','150','039',0,0,0,'',''),(340,'Tegucigalpa','Honduran','340','lempira','HNL','centavo','Republic of Honduras','HN','HND','Honduras','019','013',0,0,0,'',''),(344,'(HK3)','Hong Kong Chinese','344','Hong Kong dollar','HKD','cent','Hong Kong Special Administrative Region of the People’s Republic of China (HK2)','HK','HKG','Hong Kong','142','030',0,0,0,'',''),(348,'Budapest','Hungarian','348','forint (inv.)','HUF','(fillér (inv.))','Republic of Hungary','HU','HUN','Hungary','150','151',1,0,1,'',''),(352,'Reykjavik','Icelander','352','króna (pl. krónur)','ISK','','Republic of Iceland','IS','ISL','Iceland','150','154',0,1,1,'',''),(356,'New Delhi','Indian','356','Indian rupee','INR','paisa','Republic of India','IN','IND','India','142','034',0,0,0,'',''),(360,'Jakarta','Indonesian','360','Indonesian rupiah (inv.)','IDR','sen (inv.)','Republic of Indonesia','ID','IDN','Indonesia','142','035',0,0,0,'',''),(364,'Tehran','Iranian','364','Iranian rial','IRR','(dinar) (IR1)','Islamic Republic of Iran','IR','IRN','Iran, Islamic Republic of','142','034',0,0,0,'',''),(368,'Baghdad','Iraqi','368','Iraqi dinar','IQD','fils (inv.)','Republic of Iraq','IQ','IRQ','Iraq','142','145',0,0,0,'',''),(372,'Dublin','Irish','372','euro','EUR','cent','Ireland (IE1)','IE','IRL','Ireland','150','154',1,0,0,',','.'),(376,'(IL1)','Israeli','376','shekel','ILS','agora','State of Israel','IL','ISR','Israel','142','145',0,1,0,'',''),(380,'Rome','Italian','380','euro','EUR','cent','Italian Republic','IT','ITA','Italy','150','039',1,1,1,'',''),(384,'Yamoussoukro (CI1)','Ivorian','384','CFA franc (BCEAO)','XOF','centime','Republic of Côte d’Ivoire','CI','CIV','Côte d\'Ivoire','002','011',0,0,0,'',''),(388,'Kingston','Jamaican','388','Jamaica dollar','JMD','cent','Jamaica','JM','JAM','Jamaica','019','029',0,0,0,'',''),(392,'Tokyo','Japanese','392','yen (inv.)','JPY','(sen (inv.)) (JP1)','Japan','JP','JPN','Japan','142','030',0,1,1,'',''),(398,'Astana','Kazakh','398','tenge (inv.)','KZT','tiyn','Republic of Kazakhstan','KZ','KAZ','Kazakhstan','142','143',0,0,0,'',''),(400,'Amman','Jordanian','400','Jordanian dinar','JOD','100 qirsh','Hashemite Kingdom of Jordan','JO','JOR','Jordan','142','145',0,0,0,'',''),(404,'Nairobi','Kenyan','404','Kenyan shilling','KES','cent','Republic of Kenya','KE','KEN','Kenya','002','014',0,0,0,'',''),(408,'Pyongyang','North Korean','408','North Korean won (inv.)','KPW','chun (inv.)','Democratic People’s Republic of Korea','KP','PRK','Korea, Democratic People\'s Republic of','142','030',0,0,0,'',''),(410,'Seoul','South Korean','410','South Korean won (inv.)','KRW','(chun (inv.))','Republic of Korea','KR','KOR','Korea, Republic of','142','030',0,0,0,'',''),(414,'Kuwait City','Kuwaiti','414','Kuwaiti dinar','KWD','fils (inv.)','State of Kuwait','KW','KWT','Kuwait','142','145',0,0,0,'',''),(417,'Bishkek','Kyrgyz','417','som','KGS','tyiyn','Kyrgyz Republic','KG','KGZ','Kyrgyzstan','142','143',0,0,0,'',''),(418,'Vientiane','Lao','418','kip (inv.)','LAK','(at (inv.))','Lao People’s Democratic Republic','LA','LAO','Lao People\'s Democratic Republic','142','035',0,0,0,'',''),(422,'Beirut','Lebanese','422','Lebanese pound','LBP','(piastre)','Lebanese Republic','LB','LBN','Lebanon','142','145',0,0,0,'',''),(426,'Maseru','Basotho','426','loti (pl. maloti)','LSL','sente','Kingdom of Lesotho','LS','LSO','Lesotho','002','018',0,0,0,'',''),(428,'Riga','Latvian','428','euro','EUR','cent','Republic of Latvia','LV','LVA','Latvia','150','154',1,0,0,'',''),(430,'Monrovia','Liberian','430','Liberian dollar','LRD','cent','Republic of Liberia','LR','LBR','Liberia','002','011',0,0,0,'',''),(434,'Tripoli','Libyan','434','Libyan dinar','LYD','dirham','Socialist People’s Libyan Arab Jamahiriya','LY','LBY','Libya','002','015',0,0,0,'',''),(438,'Vaduz','Liechtensteiner','438','Swiss franc','CHF','centime','Principality of Liechtenstein','LI','LIE','Liechtenstein','150','155',0,0,0,'',''),(440,'Vilnius','Lithuanian','440','euro','EUR','cent','Republic of Lithuania','LT','LTU','Lithuania','150','154',1,0,1,'',''),(442,'Luxembourg','Luxembourger','442','euro','EUR','cent','Grand Duchy of Luxembourg','LU','LUX','Luxembourg','150','155',1,1,0,'',''),(446,'Macao (MO3)','Macanese','446','pataca','MOP','avo','Macao Special Administrative Region of the People’s Republic of China (MO2)','MO','MAC','Macao','142','030',0,0,0,'',''),(450,'Antananarivo','Malagasy','450','ariary','MGA','iraimbilanja (inv.)','Republic of Madagascar','MG','MDG','Madagascar','002','014',0,0,0,'',''),(454,'Lilongwe','Malawian','454','Malawian kwacha (inv.)','MWK','tambala (inv.)','Republic of Malawi','MW','MWI','Malawi','002','014',0,0,0,'',''),(458,'Kuala Lumpur (MY1)','Malaysian','458','ringgit (inv.)','MYR','sen (inv.)','Malaysia','MY','MYS','Malaysia','142','035',0,1,0,'',''),(462,'Malé','Maldivian','462','rufiyaa','MVR','laari (inv.)','Republic of Maldives','MV','MDV','Maldives','142','034',0,0,0,'',''),(466,'Bamako','Malian','466','CFA franc (BCEAO)','XOF','centime','Republic of Mali','ML','MLI','Mali','002','011',0,0,0,'',''),(470,'Valletta','Maltese','470','euro','EUR','cent','Republic of Malta','MT','MLT','Malta','150','039',1,0,0,',','.'),(474,'Fort-de-France','Martinican','474','euro','EUR','cent','Martinique','MQ','MTQ','Martinique','019','029',0,0,0,'',''),(478,'Nouakchott','Mauritanian','478','ouguiya','MRO','khoum','Islamic Republic of Mauritania','MR','MRT','Mauritania','002','011',0,0,0,'',''),(480,'Port Louis','Mauritian','480','Mauritian rupee','MUR','cent','Republic of Mauritius','MU','MUS','Mauritius','002','014',0,0,0,'',''),(484,'Mexico City','Mexican','484','Mexican peso','MXN','centavo','United Mexican States','MX','MEX','Mexico','019','013',0,1,0,'',''),(492,'Monaco','Monegasque','492','euro','EUR','cent','Principality of Monaco','MC','MCO','Monaco','150','155',0,0,0,'',''),(496,'Ulan Bator','Mongolian','496','tugrik','MNT','möngö (inv.)','Mongolia','MN','MNG','Mongolia','142','030',0,0,0,'',''),(498,'Chisinau','Moldovan','498','Moldovan leu (pl. lei)','MDL','ban','Republic of Moldova','MD','MDA','Moldova, Republic of','150','151',0,0,0,'',''),(499,'Podgorica','Montenegrin','499','euro','EUR','cent','Montenegro','ME','MNE','Montenegro','150','039',0,0,0,'',''),(500,'Plymouth (MS2)','Montserratian','500','East Caribbean dollar','XCD','cent','Montserrat','MS','MSR','Montserrat','019','029',0,0,0,'',''),(504,'Rabat','Moroccan','504','Moroccan dirham','MAD','centime','Kingdom of Morocco','MA','MAR','Morocco','002','015',0,0,0,'',''),(508,'Maputo','Mozambican','508','metical','MZN','centavo','Republic of Mozambique','MZ','MOZ','Mozambique','002','014',0,0,0,'',''),(512,'Muscat','Omani','512','Omani rial','OMR','baiza','Sultanate of Oman','OM','OMN','Oman','142','145',0,0,0,'',''),(516,'Windhoek','Namibian','516','Namibian dollar','NAD','cent','Republic of Namibia','NA','NAM','Namibia','002','018',0,0,0,'',''),(520,'Yaren','Nauruan','520','Australian dollar','AUD','cent','Republic of Nauru','NR','NRU','Nauru','009','057',0,0,0,'',''),(524,'Kathmandu','Nepalese','524','Nepalese rupee','NPR','paisa (inv.)','Nepal','NP','NPL','Nepal','142','034',0,0,0,'',''),(528,'Amsterdam (NL2)','Dutch','528','euro','EUR','cent','Kingdom of the Netherlands','NL','NLD','Netherlands','150','155',1,1,0,'',''),(531,'Willemstad','Curaçaoan','531','Netherlands Antillean guilder (CW1)','ANG','cent','Curaçao','CW','CUW','Curaçao','019','029',0,0,0,'',''),(533,'Oranjestad','Aruban','533','Aruban guilder','AWG','cent','Aruba','AW','ABW','Aruba','019','029',0,0,0,'',''),(534,'Philipsburg','Sint Maartener','534','Netherlands Antillean guilder (SX1)','ANG','cent','Sint Maarten','SX','SXM','Sint Maarten (Dutch part)','019','029',0,0,0,'',''),(535,NULL,'of Bonaire, Sint Eustatius and Saba','535','US dollar','USD','cent',NULL,'BQ','BES','Bonaire, Sint Eustatius and Saba','019','029',0,0,0,'',''),(540,'Nouméa','New Caledonian','540','CFP franc','XPF','centime','New Caledonia','NC','NCL','New Caledonia','009','054',0,0,0,'',''),(548,'Port Vila','Vanuatuan','548','vatu (inv.)','VUV','','Republic of Vanuatu','VU','VUT','Vanuatu','009','054',0,0,0,'',''),(554,'Wellington','New Zealander','554','New Zealand dollar','NZD','cent','New Zealand','NZ','NZL','New Zealand','009','053',0,0,0,'',''),(558,'Managua','Nicaraguan','558','córdoba oro','NIO','centavo','Republic of Nicaragua','NI','NIC','Nicaragua','019','013',0,0,0,'',''),(562,'Niamey','Nigerien','562','CFA franc (BCEAO)','XOF','centime','Republic of Niger','NE','NER','Niger','002','011',0,0,0,'',''),(566,'Abuja','Nigerian','566','naira (inv.)','NGN','kobo (inv.)','Federal Republic of Nigeria','NG','NGA','Nigeria','002','011',0,0,0,'',''),(570,'Alofi','Niuean','570','New Zealand dollar','NZD','cent','Niue','NU','NIU','Niue','009','061',0,0,0,'',''),(574,'Kingston','Norfolk Islander','574','Australian dollar','AUD','cent','Territory of Norfolk Island','NF','NFK','Norfolk Island','009','053',0,0,0,'',''),(578,'Oslo','Norwegian','578','Norwegian krone (pl. kroner)','NOK','øre (inv.)','Kingdom of Norway','NO','NOR','Norway','150','154',0,0,0,'',''),(580,'Saipan','Northern Mariana Islander','580','US dollar','USD','cent','Commonwealth of the Northern Mariana Islands','MP','MNP','Northern Mariana Islands','009','057',0,0,0,'',''),(581,'United States Minor Outlying Islands','of United States Minor Outlying Islands','581','US dollar','USD','cent','United States Minor Outlying Islands','UM','UMI','United States Minor Outlying Islands','','',0,0,0,'',''),(583,'Palikir','Micronesian','583','US dollar','USD','cent','Federated States of Micronesia','FM','FSM','Micronesia, Federated States of','009','057',0,0,0,'',''),(584,'Majuro','Marshallese','584','US dollar','USD','cent','Republic of the Marshall Islands','MH','MHL','Marshall Islands','009','057',0,0,0,'',''),(585,'Melekeok','Palauan','585','US dollar','USD','cent','Republic of Palau','PW','PLW','Palau','009','057',0,0,0,'',''),(586,'Islamabad','Pakistani','586','Pakistani rupee','PKR','paisa','Islamic Republic of Pakistan','PK','PAK','Pakistan','142','034',0,0,0,'',''),(591,'Panama City','Panamanian','591','balboa','PAB','centésimo','Republic of Panama','PA','PAN','Panama','019','013',0,0,0,'',''),(598,'Port Moresby','Papua New Guinean','598','kina (inv.)','PGK','toea (inv.)','Independent State of Papua New Guinea','PG','PNG','Papua New Guinea','009','054',0,0,0,'',''),(600,'Asunción','Paraguayan','600','guaraní','PYG','céntimo','Republic of Paraguay','PY','PRY','Paraguay','019','005',0,0,0,'',''),(604,'Lima','Peruvian','604','new sol','PEN','céntimo','Republic of Peru','PE','PER','Peru','019','005',0,0,0,'',''),(608,'Manila','Filipino','608','Philippine peso','PHP','centavo','Republic of the Philippines','PH','PHL','Philippines','142','035',0,0,0,'',''),(612,'Adamstown','Pitcairner','612','New Zealand dollar','NZD','cent','Pitcairn Islands','PN','PCN','Pitcairn','009','061',0,0,0,'',''),(616,'Warsaw','Polish','616','zloty','PLN','grosz (pl. groszy)','Republic of Poland','PL','POL','Poland','150','151',1,1,1,'',''),(620,'Lisbon','Portuguese','620','euro','EUR','cent','Portuguese Republic','PT','PRT','Portugal','150','039',1,1,1,'',''),(624,'Bissau','Guinea-Bissau national','624','CFA franc (BCEAO)','XOF','centime','Republic of Guinea-Bissau','GW','GNB','Guinea-Bissau','002','011',0,0,0,'',''),(626,'Dili','East Timorese','626','US dollar','USD','cent','Democratic Republic of East Timor','TL','TLS','Timor-Leste','142','035',0,0,0,'',''),(630,'San Juan','Puerto Rican','630','US dollar','USD','cent','Commonwealth of Puerto Rico','PR','PRI','Puerto Rico','019','029',0,0,0,'',''),(634,'Doha','Qatari','634','Qatari riyal','QAR','dirham','State of Qatar','QA','QAT','Qatar','142','145',0,0,0,'',''),(638,'Saint-Denis','Reunionese','638','euro','EUR','cent','Réunion','RE','REU','Réunion','002','014',0,0,0,'',''),(642,'Bucharest','Romanian','642','Romanian leu (pl. lei)','RON','ban (pl. bani)','Romania','RO','ROU','Romania','150','151',1,0,1,'',''),(643,'Moscow','Russian','643','Russian rouble','RUB','kopek','Russian Federation','RU','RUS','Russian Federation','150','151',0,0,0,'',''),(646,'Kigali','Rwandan; Rwandese','646','Rwandese franc','RWF','centime','Republic of Rwanda','RW','RWA','Rwanda','002','014',0,0,0,'',''),(652,'Gustavia','of Saint Barthélemy','652','euro','EUR','cent','Collectivity of Saint Barthélemy','BL','BLM','Saint Barthélemy','019','029',0,0,0,'',''),(654,'Jamestown','Saint Helenian','654','Saint Helena pound','SHP','penny','Saint Helena, Ascension and Tristan da Cunha','SH','SHN','Saint Helena, Ascension and Tristan da Cunha','002','011',0,0,0,'',''),(659,'Basseterre','Kittsian; Nevisian','659','East Caribbean dollar','XCD','cent','Federation of Saint Kitts and Nevis','KN','KNA','Saint Kitts and Nevis','019','029',0,0,0,'',''),(660,'The Valley','Anguillan','660','East Caribbean dollar','XCD','cent','Anguilla','AI','AIA','Anguilla','019','029',0,0,0,'',''),(662,'Castries','Saint Lucian','662','East Caribbean dollar','XCD','cent','Saint Lucia','LC','LCA','Saint Lucia','019','029',0,0,0,'',''),(663,'Marigot','of Saint Martin','663','euro','EUR','cent','Collectivity of Saint Martin','MF','MAF','Saint Martin (French part)','019','029',0,0,0,'',''),(666,'Saint-Pierre','St-Pierrais; Miquelonnais','666','euro','EUR','cent','Territorial Collectivity of Saint Pierre and Miquelon','PM','SPM','Saint Pierre and Miquelon','019','021',0,0,0,'',''),(670,'Kingstown','Vincentian','670','East Caribbean dollar','XCD','cent','Saint Vincent and the Grenadines','VC','VCT','Saint Vincent and the Grenadines','019','029',0,0,0,'',''),(674,'San Marino','San Marinese','674','euro','EUR','cent','Republic of San Marino','SM','SMR','San Marino','150','039',0,0,0,'',''),(678,'São Tomé','São Toméan','678','dobra','STD','centavo','Democratic Republic of São Tomé and Príncipe','ST','STP','Sao Tome and Principe','002','017',0,0,0,'',''),(682,'Riyadh','Saudi Arabian','682','riyal','SAR','halala','Kingdom of Saudi Arabia','SA','SAU','Saudi Arabia','142','145',0,0,0,'',''),(686,'Dakar','Senegalese','686','CFA franc (BCEAO)','XOF','centime','Republic of Senegal','SN','SEN','Senegal','002','011',0,0,0,'',''),(688,'Belgrade','Serb','688','Serbian dinar','RSD','para (inv.)','Republic of Serbia','RS','SRB','Serbia','150','039',0,0,0,'',''),(690,'Victoria','Seychellois','690','Seychelles rupee','SCR','cent','Republic of Seychelles','SC','SYC','Seychelles','002','014',0,0,0,'',''),(694,'Freetown','Sierra Leonean','694','leone','SLL','cent','Republic of Sierra Leone','SL','SLE','Sierra Leone','002','011',0,0,0,'',''),(702,'Singapore','Singaporean','702','Singapore dollar','SGD','cent','Republic of Singapore','SG','SGP','Singapore','142','035',0,0,0,'',''),(703,'Bratislava','Slovak','703','euro','EUR','cent','Slovak Republic','SK','SVK','Slovakia','150','151',1,0,1,'',''),(704,'Hanoi','Vietnamese','704','dong','VND','(10 hào','Socialist Republic of Vietnam','VN','VNM','Viet Nam','142','035',0,0,0,'',''),(705,'Ljubljana','Slovene','705','euro','EUR','cent','Republic of Slovenia','SI','SVN','Slovenia','150','039',1,0,1,'',''),(706,'Mogadishu','Somali','706','Somali shilling','SOS','cent','Somali Republic','SO','SOM','Somalia','002','014',0,0,0,'',''),(710,'Pretoria (ZA1)','South African','710','rand','ZAR','cent','Republic of South Africa','ZA','ZAF','South Africa','002','018',0,0,0,'',''),(716,'Harare','Zimbabwean','716','Zimbabwe dollar (ZW1)','ZWL','cent','Republic of Zimbabwe','ZW','ZWE','Zimbabwe','002','014',0,0,0,'',''),(724,'Madrid','Spaniard','724','euro','EUR','cent','Kingdom of Spain','ES','ESP','Spain','150','039',1,1,1,'',''),(728,'Juba','South Sudanese','728','South Sudanese pound','SSP','piaster','Republic of South Sudan','SS','SSD','South Sudan','002','015',0,0,0,'',''),(729,'Khartoum','Sudanese','729','Sudanese pound','SDG','piastre','Republic of the Sudan','SD','SDN','Sudan','002','015',0,0,0,'',''),(732,'Al aaiun','Sahrawi','732','Moroccan dirham','MAD','centime','Western Sahara','EH','ESH','Western Sahara','002','015',0,0,0,'',''),(740,'Paramaribo','Surinamese','740','Surinamese dollar','SRD','cent','Republic of Suriname','SR','SUR','Suriname','019','005',0,0,1,'',''),(744,'Longyearbyen','of Svalbard','744','Norwegian krone (pl. kroner)','NOK','øre (inv.)','Svalbard and Jan Mayen','SJ','SJM','Svalbard and Jan Mayen','150','154',0,0,0,'',''),(748,'Mbabane','Swazi','748','lilangeni','SZL','cent','Kingdom of Swaziland','SZ','SWZ','Swaziland','002','018',0,0,0,'',''),(752,'Stockholm','Swedish','752','krona (pl. kronor)','SEK','öre (inv.)','Kingdom of Sweden','SE','SWE','Sweden','150','154',1,1,1,'',''),(756,'Berne','Swiss','756','Swiss franc','CHF','centime','Swiss Confederation','CH','CHE','Switzerland','150','155',0,1,0,'',''),(760,'Damascus','Syrian','760','Syrian pound','SYP','piastre','Syrian Arab Republic','SY','SYR','Syrian Arab Republic','142','145',0,0,0,'',''),(762,'Dushanbe','Tajik','762','somoni','TJS','diram','Republic of Tajikistan','TJ','TJK','Tajikistan','142','143',0,0,0,'',''),(764,'Bangkok','Thai','764','baht (inv.)','THB','satang (inv.)','Kingdom of Thailand','TH','THA','Thailand','142','035',0,0,0,'',''),(768,'Lomé','Togolese','768','CFA franc (BCEAO)','XOF','centime','Togolese Republic','TG','TGO','Togo','002','011',0,0,0,'',''),(772,'(TK2)','Tokelauan','772','New Zealand dollar','NZD','cent','Tokelau','TK','TKL','Tokelau','009','061',0,0,0,'',''),(776,'Nuku’alofa','Tongan','776','pa’anga (inv.)','TOP','seniti (inv.)','Kingdom of Tonga','TO','TON','Tonga','009','061',0,0,0,'',''),(780,'Port of Spain','Trinidadian; Tobagonian','780','Trinidad and Tobago dollar','TTD','cent','Republic of Trinidad and Tobago','TT','TTO','Trinidad and Tobago','019','029',0,0,0,'',''),(784,'Abu Dhabi','Emirian','784','UAE dirham','AED','fils (inv.)','United Arab Emirates','AE','ARE','United Arab Emirates','142','145',0,0,0,'',''),(788,'Tunis','Tunisian','788','Tunisian dinar','TND','millime','Republic of Tunisia','TN','TUN','Tunisia','002','015',0,0,0,'',''),(792,'Ankara','Turk','792','Turkish lira (inv.)','TRY','kurus (inv.)','Republic of Turkey','TR','TUR','Turkey','142','145',0,0,0,'',''),(795,'Ashgabat','Turkmen','795','Turkmen manat (inv.)','TMT','tenge (inv.)','Turkmenistan','TM','TKM','Turkmenistan','142','143',0,0,0,'',''),(796,'Cockburn Town','Turks and Caicos Islander','796','US dollar','USD','cent','Turks and Caicos Islands','TC','TCA','Turks and Caicos Islands','019','029',0,0,0,'',''),(798,'Funafuti','Tuvaluan','798','Australian dollar','AUD','cent','Tuvalu','TV','TUV','Tuvalu','009','061',0,0,0,'',''),(800,'Kampala','Ugandan','800','Uganda shilling','UGX','cent','Republic of Uganda','UG','UGA','Uganda','002','014',0,0,0,'',''),(804,'Kiev','Ukrainian','804','hryvnia','UAH','kopiyka','Ukraine','UA','UKR','Ukraine','150','151',0,0,0,'',''),(807,'Skopje','of the former Yugoslav Republic of Macedonia','807','denar (pl. denars)','MKD','deni (inv.)','the former Yugoslav Republic of Macedonia','MK','MKD','Macedonia, the former Yugoslav Republic of','150','039',0,0,0,'',''),(818,'Cairo','Egyptian','818','Egyptian pound','EGP','piastre','Arab Republic of Egypt','EG','EGY','Egypt','002','015',0,0,0,'',''),(826,'London','British','826','pound sterling','GBP','penny (pl. pence)','United Kingdom of Great Britain and Northern Ireland','GB','GBR','United Kingdom','150','154',1,0,0,'',''),(831,'St Peter Port','of Guernsey','831','Guernsey pound (GG2)','GGP (GG2)','penny (pl. pence)','Bailiwick of Guernsey','GG','GGY','Guernsey','150','154',0,0,0,'',''),(832,'St Helier','of Jersey','832','Jersey pound (JE2)','JEP (JE2)','penny (pl. pence)','Bailiwick of Jersey','JE','JEY','Jersey','150','154',0,0,0,'',''),(833,'Douglas','Manxman; Manxwoman','833','Manx pound (IM2)','IMP (IM2)','penny (pl. pence)','Isle of Man','IM','IMN','Isle of Man','150','154',0,0,0,'',''),(834,'Dodoma (TZ1)','Tanzanian','834','Tanzanian shilling','TZS','cent','United Republic of Tanzania','TZ','TZA','Tanzania, United Republic of','002','014',0,0,0,'',''),(840,'Washington DC','American','840','US dollar','USD','cent','United States of America','US','USA','United States','019','021',0,0,0,',','.'),(850,'Charlotte Amalie','US Virgin Islander','850','US dollar','USD','cent','United States Virgin Islands','VI','VIR','Virgin Islands, U.S.','019','029',0,0,0,'',''),(854,'Ouagadougou','Burkinabe','854','CFA franc (BCEAO)','XOF','centime','Burkina Faso','BF','BFA','Burkina Faso','002','011',0,0,0,'',''),(858,'Montevideo','Uruguayan','858','Uruguayan peso','UYU','centésimo','Eastern Republic of Uruguay','UY','URY','Uruguay','019','005',0,1,0,'',''),(860,'Tashkent','Uzbek','860','sum (inv.)','UZS','tiyin (inv.)','Republic of Uzbekistan','UZ','UZB','Uzbekistan','142','143',0,0,0,'',''),(862,'Caracas','Venezuelan','862','bolívar fuerte (pl. bolívares fuertes)','VEF','céntimo','Bolivarian Republic of Venezuela','VE','VEN','Venezuela, Bolivarian Republic of','019','005',0,0,0,'',''),(876,'Mata-Utu','Wallisian; Futunan; Wallis and Futuna Islander','876','CFP franc','XPF','centime','Wallis and Futuna','WF','WLF','Wallis and Futuna','009','061',0,0,0,'',''),(882,'Apia','Samoan','882','tala (inv.)','WST','sene (inv.)','Independent State of Samoa','WS','WSM','Samoa','009','061',0,0,0,'',''),(887,'San’a','Yemenite','887','Yemeni rial','YER','fils (inv.)','Republic of Yemen','YE','YEM','Yemen','142','145',0,0,0,'',''),(894,'Lusaka','Zambian','894','Zambian kwacha (inv.)','ZMW','ngwee (inv.)','Republic of Zambia','ZM','ZMB','Zambia','002','014',0,0,0,'','');
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credit_invitations`
--

DROP TABLE IF EXISTS `credit_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_invitations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `client_contact_id` int unsigned NOT NULL,
  `credit_id` int unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `signature_ip` text COLLATE utf8mb4_unicode_ci,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credit_invitations_client_contact_id_credit_id_unique` (`client_contact_id`,`credit_id`),
  KEY `credit_invitations_user_id_foreign` (`user_id`),
  KEY `credit_invitations_company_id_foreign` (`company_id`),
  KEY `credit_invitations_deleted_at_credit_id_company_id_index` (`deleted_at`,`credit_id`,`company_id`),
  KEY `credit_invitations_credit_id_index` (`credit_id`),
  KEY `credit_invitations_key_index` (`key`),
  KEY `credit_invitations_message_id_index` (`message_id`),
  CONSTRAINT `credit_invitations_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `credit_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `credit_invitations_credit_id_foreign` FOREIGN KEY (`credit_id`) REFERENCES `credits` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `credit_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credit_invitations`
--

LOCK TABLES `credit_invitations` WRITE;
/*!40000 ALTER TABLE `credit_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `credit_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credits`
--

DROP TABLE IF EXISTS `credits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credits` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `status_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `recurring_id` int unsigned DEFAULT NULL,
  `design_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `last_sent_date` datetime DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `next_send_date` datetime DEFAULT NULL,
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `amount` decimal(20,6) NOT NULL,
  `balance` decimal(20,6) NOT NULL,
  `partial` decimal(20,6) DEFAULT NULL,
  `partial_due_date` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `reminder1_sent` date DEFAULT NULL,
  `reminder2_sent` date DEFAULT NULL,
  `reminder3_sent` date DEFAULT NULL,
  `reminder_last_sent` date DEFAULT NULL,
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `subscription_id` int unsigned DEFAULT NULL,
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `location_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credits_company_id_number_unique` (`company_id`,`number`),
  KEY `credits_user_id_foreign` (`user_id`),
  KEY `credits_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `credits_client_id_index` (`client_id`),
  KEY `credits_company_id_index` (`company_id`),
  KEY `credits_location_id_foreign` (`location_id`),
  CONSTRAINT `credits_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `credits_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `credits_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `credits_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credits`
--

LOCK TABLES `credits` WRITE;
/*!40000 ALTER TABLE `credits` DISABLE KEYS */;
/*!40000 ALTER TABLE `credits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precision` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thousand_separator` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `decimal_separator` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `swap_currency_symbol` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(13,6) NOT NULL DEFAULT '1.000000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
INSERT INTO `currencies` VALUES (1,'US Dollar','$','2',',','.','USD',0,1.000000),(2,'British Pound','£','2',',','.','GBP',0,1.000000),(3,'Euro','€','2','.',',','EUR',0,1.000000),(4,'South African Rand','R','2',',','.','ZAR',0,1.000000),(5,'Danish Krone','kr','2','.',',','DKK',1,1.000000),(6,'Israeli Shekel','NIS ','2',',','.','ILS',0,1.000000),(7,'Swedish Krona','kr','2','.',',','SEK',1,1.000000),(8,'Kenyan Shilling','KSh ','2',',','.','KES',0,1.000000),(9,'Canadian Dollar','$','2',',','.','CAD',0,1.000000),(10,'Philippine Peso','P ','2',',','.','PHP',0,1.000000),(11,'Indian Rupee','₹','2',',','.','INR',0,1.000000),(12,'Australian Dollar','$','2',',','.','AUD',0,1.000000),(13,'Singapore Dollar','','2',',','.','SGD',0,1.000000),(14,'Norske Kroner','kr','2','.',',','NOK',1,1.000000),(15,'New Zealand Dollar','$','2',',','.','NZD',0,1.000000),(16,'Vietnamese Dong','₫','0','.',',','VND',0,1.000000),(17,'Swiss Franc','CHF','2','\'','.','CHF',0,1.000000),(18,'Guatemalan Quetzal','Q','2',',','.','GTQ',0,1.000000),(19,'Malaysian Ringgit','RM','2',',','.','MYR',0,1.000000),(20,'Brazilian Real','R$','2','.',',','BRL',0,1.000000),(21,'Thai Baht','฿','2',',','.','THB',0,1.000000),(22,'Nigerian Naira','','2',',','.','NGN',0,1.000000),(23,'Argentine Peso','$','2','.',',','ARS',0,1.000000),(24,'Bangladeshi Taka','Tk','2',',','.','BDT',0,1.000000),(25,'United Arab Emirates Dirham','DH ','2',',','.','AED',0,1.000000),(26,'Hong Kong Dollar','','2',',','.','HKD',0,1.000000),(27,'Indonesian Rupiah','Rp','2','.',',','IDR',0,1.000000),(28,'Mexican Peso','$','2',',','.','MXN',0,1.000000),(29,'Egyptian Pound','E£','2',',','.','EGP',0,1.000000),(30,'Colombian Peso','$','2','.',',','COP',0,1.000000),(31,'West African Franc','CFA ','2',',','.','XOF',0,1.000000),(32,'Chinese Renminbi','RMB ','2',',','.','CNY',0,1.000000),(33,'Rwandan Franc','RF ','2',',','.','RWF',0,1.000000),(34,'Tanzanian Shilling','TSh ','2',',','.','TZS',0,1.000000),(35,'Netherlands Antillean Guilder','','2','.',',','ANG',0,1.000000),(36,'Trinidad and Tobago Dollar','TT$','2',',','.','TTD',0,1.000000),(37,'East Caribbean Dollar','EC$','2',',','.','XCD',0,1.000000),(38,'Ghanaian Cedi','','2',',','.','GHS',0,1.000000),(39,'Bulgarian Lev','лв','2',' ','.','BGN',0,1.000000),(40,'Aruban Florin','Afl. ','2',' ','.','AWG',0,1.000000),(41,'Turkish Lira','TL ','2','.',',','TRY',0,1.000000),(42,'Romanian New Leu','','2',',','.','RON',0,1.000000),(43,'Croatian Kuna','kn','2','.',',','HRK',0,1.000000),(44,'Saudi Riyal','','2',',','.','SAR',0,1.000000),(45,'Japanese Yen','¥','0',',','.','JPY',0,1.000000),(46,'Maldivian Rufiyaa','','2',',','.','MVR',0,1.000000),(47,'Costa Rican Colón','','2',',','.','CRC',0,1.000000),(48,'Pakistani Rupee','Rs ','0',',','.','PKR',0,1.000000),(49,'Polish Zloty','zł','2',' ',',','PLN',1,1.000000),(50,'Sri Lankan Rupee','LKR','2',',','.','LKR',1,1.000000),(51,'Czech Koruna','Kč','2',' ',',','CZK',1,1.000000),(52,'Uruguayan Peso','$','2','.',',','UYU',0,1.000000),(53,'Namibian Dollar','$','2',',','.','NAD',0,1.000000),(54,'Tunisian Dinar','','2',',','.','TND',0,1.000000),(55,'Russian Ruble','','2',',','.','RUB',0,1.000000),(56,'Mozambican Metical','MT','2','.',',','MZN',1,1.000000),(57,'Omani Rial','','2',',','.','OMR',0,1.000000),(58,'Ukrainian Hryvnia','','2',',','.','UAH',0,1.000000),(59,'Macanese Pataca','MOP$','2',',','.','MOP',0,1.000000),(60,'Taiwan New Dollar','NT$','2',',','.','TWD',0,1.000000),(61,'Dominican Peso','RD$','2',',','.','DOP',0,1.000000),(62,'Chilean Peso','$','0','.',',','CLP',0,1.000000),(63,'Icelandic Króna','kr','0','.',',','ISK',1,1.000000),(64,'Papua New Guinean Kina','K','2',',','.','PGK',0,1.000000),(65,'Jordanian Dinar','','2',',','.','JOD',0,1.000000),(66,'Myanmar Kyat','K','2',',','.','MMK',0,1.000000),(67,'Peruvian Sol','S/ ','2',',','.','PEN',0,1.000000),(68,'Botswana Pula','P','2',',','.','BWP',0,1.000000),(69,'Hungarian Forint','Ft','0','.',',','HUF',1,1.000000),(70,'Ugandan Shilling','USh ','2',',','.','UGX',0,1.000000),(71,'Barbadian Dollar','$','2',',','.','BBD',0,1.000000),(72,'Brunei Dollar','B$','2',',','.','BND',0,1.000000),(73,'Georgian Lari','','2',' ',',','GEL',0,1.000000),(74,'Qatari Riyal','QR','2',',','.','QAR',0,1.000000),(75,'Honduran Lempira','L','2',',','.','HNL',0,1.000000),(76,'Surinamese Dollar','SRD','2','.',',','SRD',0,1.000000),(77,'Bahraini Dinar','BD ','2',',','.','BHD',0,1.000000),(78,'Venezuelan Bolivars','Bs.','2','.',',','VES',0,1.000000),(79,'South Korean Won','W ','2',',','.','KRW',0,1.000000),(80,'Moroccan Dirham','MAD ','2',',','.','MAD',0,1.000000),(81,'Jamaican Dollar','$','2',',','.','JMD',0,1.000000),(82,'Angolan Kwanza','Kz','2','.',',','AOA',0,1.000000),(83,'Haitian Gourde','G','2',',','.','HTG',0,1.000000),(84,'Zambian Kwacha','ZK','2',',','.','ZMW',0,1.000000),(85,'Nepalese Rupee','Rs. ','2',',','.','NPR',0,1.000000),(86,'CFP Franc','','2',',','.','XPF',0,1.000000),(87,'Mauritian Rupee','Rs','2',',','.','MUR',0,1.000000),(88,'Cape Verdean Escudo','','2','.','$','CVE',0,1.000000),(89,'Kuwaiti Dinar','KD','3',',','.','KWD',0,1.000000),(90,'Algerian Dinar','DA','2',',','.','DZD',0,1.000000),(91,'Macedonian Denar','ден','2',',','.','MKD',0,1.000000),(92,'Fijian Dollar','FJ$','2',',','.','FJD',0,1.000000),(93,'Bolivian Boliviano','Bs','2',',','.','BOB',0,1.000000),(94,'Albanian Lek','L ','2','.',',','ALL',0,1.000000),(95,'Serbian Dinar','din','2','.',',','RSD',0,1.000000),(96,'Lebanese Pound','LL ','2',',','.','LBP',0,1.000000),(97,'Armenian Dram','','2',',','.','AMD',0,1.000000),(98,'Azerbaijan Manat','','2',',','.','AZN',0,1.000000),(99,'Bosnia and Herzegovina Convertible Mark','','2',',','.','BAM',0,1.000000),(100,'Belarusian Ruble','','2',',','.','BYN',0,1.000000),(101,'Gibraltar Pound','','2',',','.','GIP',0,1.000000),(102,'Moldovan Leu','','2',',','.','MDL',0,1.000000),(103,'Kazakhstani Tenge','','2',',','.','KZT',0,1.000000),(104,'Ethiopian Birr','','2',',','.','ETB',0,1.000000),(105,'Gambia Dalasi','D','2',',','.','GMD',0,1.000000),(106,'Paraguayan Guarani','₲','0',',','.','PYG',0,1.000000),(107,'Malawi Kwacha','MK','2',',','.','MWK',0,1.000000),(108,'Zimbabwean Dollar','Z$','2',',','.','ZWL',0,1.000000),(109,'Cambodian Riel','៛','2',',','.','KHR',0,1.000000),(110,'Vanuatu Vatu','VT','0',',','.','VUV',0,1.000000),(111,'Cuban Peso','₱','2',',','.','CUP',0,1.000000),(112,'Cayman Island Dollar','','2',',','.','KYD',0,1.000000),(113,'Swazi lilangeni','E','2',',','.','SZL',0,1.000000),(114,'BZ Dollar','$','2',',','.','BZD',0,1.000000),(115,'Libyan Dinar','LD','3',',','.','LYD',0,1.000000),(116,'Silver Troy Ounce','XAG','2',',','.','XAG',0,1.000000),(117,'Gold Troy Ounce','XAU','3',',','.','XAU',0,1.000000),(118,'Nicaraguan Córdoba','C$','2',',','.','NIO',0,1.000000),(119,'Malagasy ariary','Ar','0',',','.','MGA',0,1.000000),(120,'Tongan Pa anga','T$','2',',','.','TOP',0,1.000000),(121,'Lao kip','₭','2',',','.','LAK',0,1.000000),(122,'Bhutan Ngultrum','Nu','2',',','.','BTN',0,1.000000),(123,'Mauritanian Ouguiya','UM','2',',','.','MRU',0,1.000000),(124,'Bermudian Dollar','$','2',',','.','BMD',0,1.000000),(125,'Central African CFA Franc','Fr','0',',','.','XAF',0,1.000000),(126,'Congolese Franc','Fr','2',',','.','CDF',0,1.000000),(127,'Djiboutian Franc','Fr','0',',','.','DJF',0,1.000000),(128,'Eritrean Nakfa','Nfk','2',',','.','ERN',0,1.000000),(129,'Falkland Islands Pound','£','2',',','.','FKP',0,1.000000),(130,'Guinean Franc','Fr','0',',','','GNF',0,1.000000),(131,'Iraqi Dinar','ع.د','3',',','.','IQD',0,1.000000),(132,'Lesotho Loti','L','2',',','.','LSL',0,1.000000),(133,'Mongolian Tugrik','₮','2',',','.','MNT',0,1.000000),(134,'Seychellois Rupee','₨','2',',','.','SCR',0,1.000000),(135,'Solomon Islands Dollar','$','2',',','.','SBD',0,1.000000),(136,'Somali Shilling','Sh','2',',','.','SOS',0,1.000000),(137,'South Sudanese Pound','£','2',',','.','SSP',0,1.000000),(138,'Sudanese Pound','£','2',',','.','SDG',0,1.000000),(139,'Tajikistani Somoni','ЅM','2',',','.','TJS',0,1.000000),(140,'Turkmenistani Manat','T','2',',','.','TMT',0,1.000000),(141,'Uzbekistani Som','so\'m','2',',','.','UZS',0,1.000000),(142,'Samoan Tala','$','2',',','.','WST',0,1.000000);
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `date_formats`
--

DROP TABLE IF EXISTS `date_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `date_formats` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `format` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `format_moment` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `format_dart` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `date_formats`
--

LOCK TABLES `date_formats` WRITE;
/*!40000 ALTER TABLE `date_formats` DISABLE KEYS */;
INSERT INTO `date_formats` VALUES (1,'d/M/Y','DD/MMM/YYYY','dd/MMM/yyyy'),(2,'d-M-Y','DD-MMM-YYYY','dd-MMM-yyyy'),(3,'d/F/Y','DD/MMMM/YYYY','dd/MMMM/yyyy'),(4,'d-F-Y','DD-MMMM-YYYY','dd-MMMM-yyyy'),(5,'M j, Y','MMM D, YYYY','MMM d, yyyy'),(6,'F j, Y','MMMM D, YYYY','MMMM d, yyyy'),(7,'D M j, Y','ddd MMM D, YYYY','EEE MMM d, yyyy'),(8,'Y-m-d','YYYY-MM-DD','yyyy-MM-dd'),(9,'d-m-Y','DD-MM-YYYY','dd-MM-yyyy'),(10,'m/d/Y','MM/DD/YYYY','MM/dd/yyyy'),(11,'d.m.Y','D.MM.YYYY','dd.MM.yyyy'),(12,'j. M. Y','DD. MMM. YYYY','d. MMM. yyyy'),(13,'j. F Y','DD. MMMM YYYY','d. MMMM yyyy'),(14,'d/m/Y','DD/MM/YYYY','dd/MM/yyyy');
/*!40000 ALTER TABLE `date_formats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `datetime_formats`
--

DROP TABLE IF EXISTS `datetime_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `datetime_formats` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `format` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `format_moment` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `format_dart` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datetime_formats`
--

LOCK TABLES `datetime_formats` WRITE;
/*!40000 ALTER TABLE `datetime_formats` DISABLE KEYS */;
INSERT INTO `datetime_formats` VALUES (1,'d/M/Y g:i a','DD/MMM/YYYY h:mm:ss a','dd/MMM/yyyy h:mm a'),(2,'d-M-Y g:i a','DD-MMM-YYYY h:mm:ss a','dd-MMM-yyyy h:mm a'),(3,'d/F/Y g:i a','DD/MMMM/YYYY h:mm:ss a','dd/MMMM/yyyy h:mm a'),(4,'d-F-Y g:i a','DD-MMMM-YYYY h:mm:ss a','dd-MMMM-yyyy h:mm a'),(5,'M j, Y g:i a','MMM D, YYYY h:mm:ss a','MMM d, yyyy h:mm a'),(6,'F j, Y g:i a','MMMM D, YYYY h:mm:ss a','MMMM d, yyyy h:mm a'),(7,'D M jS, Y g:i a','ddd MMM Do, YYYY h:mm:ss a','EEE MMM d, yyyy h:mm a'),(8,'Y-m-d g:i a','YYYY-MM-DD h:mm:ss a','yyyy-MM-dd h:mm a'),(9,'d-m-Y g:i a','DD-MM-YYYY h:mm:ss a','dd-MM-yyyy h:mm a'),(10,'m/d/Y g:i a','MM/DD/YYYY h:mm:ss a','MM/dd/yyyy h:mm a'),(11,'d.m.Y g:i a','D.MM.YYYY h:mm:ss a','dd.MM.yyyy h:mm a'),(12,'j. M. Y g:i a','DD. MMM. YYYY h:mm:ss a','d. MMM. yyyy h:mm a'),(13,'j. F Y g:i a','DD. MMMM YYYY h:mm:ss a','d. MMMM yyyy h:mm a'),(14,'d/m/Y g:i a','DD/MM/YYYY h:mm:ss a','dd/MM/yyyy h:mm a');
/*!40000 ALTER TABLE `datetime_formats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `designs`
--

DROP TABLE IF EXISTS `designs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `designs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_custom` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `design` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `is_template` tinyint(1) NOT NULL DEFAULT '0',
  `entities` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `designs_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `designs_company_id_index` (`company_id`),
  CONSTRAINT `designs_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `designs`
--

LOCK TABLES `designs` WRITE;
/*!40000 ALTER TABLE `designs` DISABLE KEYS */;
INSERT INTO `designs` VALUES (1,NULL,NULL,'Plain',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    @page {\\n        margin-left: $global_margin;\\n        margin-right: $global_margin;\\n        margin-top: 0;\\n        margin-bottom: 0;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-wrapper {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr 1fr;\\n        line-height: var(--line-height);\\n        margin-bottom: 10px;\\n    }\\n\\n    .client-wrapper {\\n        display: grid;\\n        grid-template-columns: auto 1fr auto;\\n        border: 0px solid #000;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n    }\\n\\n    .header-wrapper #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    #entity-container {\\n        border: 0px solid #000;\\n        margin-right: 0;\\n        margin-left: auto;\\n    }\\n\\n    #entity-details {\\n        text-align: left;\\n        line-height: var(--line-height) !important;\\n        white-space: nowrap;\\n        border: 0px solid #000;\\n        float: right;\\n    }\\n\\n    #entity-details>tr,\\n    #entity-details th {\\n        font-weight: normal;\\n        padding-right: 3rem;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    .header-wrapper #entity-details [data-element=\'entity-balance-due-label\'],\\n    .header-wrapper #entity-details [data-element=\'entity-balance-due\'] {\\n        background-color: #e6e6e6;\\n    }\\n\\n    #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        \\/* white-space: nowrap; *\\/\\n        border: 0px solid #000;\\n    }\\n\\n    #shipping-details {\\n        opacity: $show_shipping_address_visibility;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        white-space: nowrap;\\n        border: 0px solid #000;\\n        margin-left: auto;\\n        margin-right: auto;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 1rem;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        padding: 0.75rem;\\n        background-color: #e6e6e6;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th:last-child {\\n        text-align: right;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        border-bottom: 1px solid #e6e6e6;\\n        padding: 0.75rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td:last-child {\\n        text-align: right;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        margin-right: .75rem;\\n        gap: 80px;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .25rem;\\n        padding-left: 7px;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.25rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.25rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        padding-right: 0px;\\n    }\\n\\n    #table-totals>* [data-element=\'total-table-balance-due-label\'],\\n    #table-totals>* [data-element=\'total-table-balance-due\'] {\\n        font-weight: bold;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        padding-left: 0rem;\\n    }\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        color: var(--primary-color)\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding-label\\\"],\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        background-color: #e6e6e6;\\n        color: black;\\n        padding-top: 7px;\\n        padding-bottom: 7px;\\n        padding-right: 7px;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-ref=\'product_table-product.description-td\'],\\n    [data-ref=\'task_table-task.description-th\'] {\\n        min-width: 150px !important;\\n        overflow-wrap: break-word;\\n    }\\n\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    #logo-container {\\n        margin-right: 0;\\n        margin-left: auto;\\n        text-align: right;\\n        border: 0px solid #000;\\n    }\\n\\n    .pqrcode {}\\n\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-wrapper\\\">\\n                        <div id=\\\"company-details\\\"><\\/div>\\n                        <div id=\\\"company-address\\\"><\\/div>\\n                        <div id=\\\"logo-container\\\">\\n                            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                        <\\/div>\\n                    <\\/div>\\n                    <div class=\\\"client-wrapper\\\">\\n                        <div id=\\\"client-details\\\"><\\/div>\\n                        <div id=\\\"vendor-details\\\"><\\/div>\\n                        <div id=\\\"shipping-details\\\"><\\/div>\\n                        <div id=\\\"entity-container\\\">\\n                            <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-unapplied-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-unapplied-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.453847','2026-09-16 07:56:52.462911',NULL,0,NULL),(2,NULL,NULL,'Clean',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin-left: $global_margin;\\n        margin-right: $global_margin;\\n        margin-top: 5;\\n        margin-bottom: 5;\\n        size: $page_size $page_layout;\\n    }\\n\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    .header-container {\\n        display: grid;\\n        grid-template-columns: minmax(0, 1.5fr) auto minmax(0, 1fr);\\n        align-items: start;\\n        gap: 1rem;\\n        width: 100%;\\n    }\\n\\n    .company-logo-container {\\n        justify-self: start;\\n        align-self: start;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n    }\\n\\n    #company-details {\\n        justify-self: center;\\n        align-self: start;\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    #company-details>p:first-child {\\n        color: var(--primary-color);\\n    }\\n\\n    #company-address {\\n        justify-self: end;\\n        align-self: start;\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    .entity-label {\\n        margin-top: 2.5rem;\\n        text-transform: uppercase;\\n        padding-left: 1rem;\\n        margin-bottom: 1rem;\\n        font-weight: bold;\\n        color: var(--primary-color);\\n    }\\n\\n    .client-and-entity-wrapper {\\n        padding-top: 1rem;\\n        padding-bottom: 1rem;\\n        display: grid;\\n        grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);\\n        align-items: start;\\n        border-top: 1px solid #d8d8d8;\\n        border-bottom: 1px solid #d8d8d8;\\n    }\\n\\n    #entity-details {\\n        display: flex;\\n        text-align: left;\\n        margin-right: 20px;\\n        line-height: var(--line-height) !important;\\n        justify-self: start;\\n        align-self: start;\\n        padding-left: 1rem;\\n    }\\n\\n    #entity-details>tr,\\n    #entity-details th {\\n        font-weight: normal;\\n        padding-right: 15px;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        justify-self: center;\\n        align-self: start;\\n    }\\n\\n    #client-details> :first-child {\\n        font-weight: bold;\\n    }\\n\\n    #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        justify-self: end;\\n        align-self: start;\\n        padding-left: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 1rem;\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        font-size: 1.1rem;\\n        padding-bottom: 1.5rem;\\n        padding-left: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        border-top: 1px solid #d8d8d8;\\n        border-bottom: 1px solid #d8d8d8;\\n        padding: 1rem 1rem;\\n    }\\n\\n    th.right-radius {\\n        padding-right: 1rem;\\n        text-align: right;\\n    }\\n\\n    td.right-radius {\\n        text-align: right;\\n    }\\n\\n    [data-ref=\'product_table-product.item-td\'] {\\n        color: var(--primary-color);\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(odd) {\\n        background-color: #f5f5f5;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        padding-top: 0rem;\\n        padding-right: 1rem;\\n        gap: 80px;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 0.5rem;\\n    }\\n\\n    #footer {\\n        margin-top: 10px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    #product-table h3,\\n    #task-table h3,\\n    #delivery-note-table h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"total_table-public_notes\\\"] {\\n        margin-top: 1rem;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-ref=\'product_table-product.description-td\'],\\n    td {\\n        min-width: 100%;\\n        max-width: 300px;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n        float: right;\\n\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-container\\\">\\n                        <div class=\\\"company-logo-container\\\">\\n                            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                        <\\/div>\\n                        <div id=\\\"company-details\\\"><\\/div>\\n                        <div id=\\\"company-address\\\"><\\/div>\\n                    <\\/div>\\n                    <p class=\\\"entity-label\\\">$entity_label<\\/p>\\n                    <div class=\\\"client-and-entity-wrapper\\\">\\n                        <div class=\\\"entity-details-container\\\">\\n                            <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                        <\\/div>\\n                        <div id=\\\"client-details\\\"><\\/div>\\n                        <div id=\\\"vendor-details\\\"><\\/div>\\n                        <div id=\\\"shipping-details\\\"><\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.454689','2026-09-16 07:56:52.464706',NULL,0,NULL),(3,NULL,NULL,'Bold',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.4;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n        margin: 0;\\n        padding: 0;\\n\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n\\n    html {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    @page {\\n        margin: 0 !important;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    #spacer-table>*>tr>td {\\n        padding: 0;\\n    }\\n\\n    #spacer-table {\\n        width: 100%;\\n    }\\n\\n    #header {\\n        display: grid;\\n        grid-template-columns: 1.5fr 1fr 1fr;\\n        gap: 20px;\\n        background-color: #2d2c2a;\\n        color: white;\\n        line-height: var(--line-height);\\n        position: fixed;\\n        top: 0;\\n        width: 100%;\\n    }\\n\\n\\n    #header,\\n    #header-spacer {\\n        height: 160px;\\n        padding-top: 1rem;\\n        padding-bottom: 1rem;\\n        padding-left: 1rem;\\n        padding-right: 1rem;\\n        margin-bottom: 1rem;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n        object-fit: contain;\\n        object-position: left center;\\n        max-height: 160px;\\n    }\\n\\n    #company-details,\\n    #company-address {\\n        display: flex;\\n        flex-direction: column;\\n    }\\n\\n    #company-details,\\n    #company-address,\\n    .logo-container {\\n        max-height: 160px;\\n    }\\n\\n    #client-details {\\n        padding-right: 1rem;\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height) !important;\\n        padding-left: 1rem;\\n    }\\n\\n    #vendor-details {\\n        padding-right: 1rem;\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height) !important;\\n        padding-left: 1rem;\\n    }\\n\\n    #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    #client-details> :first-child {\\n        font-weight: bold;\\n    }\\n\\n    .client-entity-wrapper {\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n\\n    }\\n\\n    .client-wrapper-left-side {\\n        display: flex;\\n    }\\n\\n    .entity-details-wrapper {\\n        background-color: var(--primary-color);\\n        padding: 1rem;\\n    }\\n\\n    #entity-details {\\n        width: 100%;\\n        text-align: left;\\n        color: white !important;\\n    }\\n\\n    #entity-details>tr,\\n    #entity-details th {\\n        font-weight: normal;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        width: 100% !important;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n        margin-top: 0.5rem;\\n        margin-bottom: 0px;\\n    }\\n\\n    [data-ref=\\\"table\\\"]:last-child {\\n        margin-bottom: 0;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        padding-top: 1.5rem;\\n        padding-bottom: 1.5rem;\\n        padding-left: 0;\\n        padding-right: 0;\\n        font-size: 1rem;\\n    }\\n\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        padding-top: 1.5rem;\\n        padding-bottom: 1.5rem;\\n        padding-left: 0;\\n        padding-right: 0;\\n    }\\n\\n    th.left-radius {\\n        padding-left: 1rem !important;\\n    }\\n\\n    th.right-radius {\\n        text-align: right !important;\\n        padding-right: 1rem !important;\\n    }\\n\\n    td.right-radius {\\n        text-align: right !important;\\n        padding-right: 1rem !important;\\n    }\\n\\n    td.left-radius {\\n        font-weight: bold;\\n        padding-left: 1rem !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(odd) {\\n        background-color: #ebebeb;\\n    }\\n\\n    #table-totals {\\n        page-break-inside: avoid;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        padding-top: .5rem;\\n        padding-left: 1rem;\\n        padding-right: 1rem;\\n        gap: 80px;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1.5rem;\\n    }\\n\\n    .entity-label {\\n        text-transform: uppercase;\\n        color: var(--primary-color);\\n        padding-left: 1rem;\\n        font-size: 1.5rem;\\n    }\\n\\n    #footer {\\n        margin-top: 1rem;\\n        background-color: #2d2c2a;\\n        min-width: 100%;\\n        position: fixed;\\n        bottom: 0;\\n        display: grid;\\n        grid-template-columns: 1fr;\\n        gap: 15px;\\n        color: white;\\n    }\\n\\n    #footer,\\n    #footer-spacer {\\n        height: 160px;\\n        padding: 1rem 1rem;\\n        margin-top: 1rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        padding-top: 0.5rem\\n    }\\n\\n    [data-ref=\\\"footer_content\\\"] {\\n        padding-right: 1rem;\\n        margin-right: 1rem;\\n    }\\n\\n    table {\\n        width: 100%;\\n    }\\n\\n    table[data-ref=\\\"table\\\"] th,\\n    table[data-ref=\\\"table\\\"] td {\\n        padding: .2rem .4rem;\\n        text-align: left;\\n        vertical-align: top;\\n        border-top: 1px solid #dee2e6;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    #product-table h3,\\n    #task-table h3,\\n    #delivery-note-table h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    #statement-invoice-table-totals>p {\\n        margin-right: 2rem;\\n        margin-top: 1rem;\\n    }\\n\\n    [data-ref=\'product_table-product.description-th\'],\\n    [data-ref=\'product_table-product.description-td\'] {\\n        width: 30%;\\n        overflow-wrap: break-word;\\n        padding-right: 1rem !important;\\n    }\\n\\n    [data-ref=\'product_table-product.tax1-th\'],\\n    [data-ref=\'product_table-product.tax1-td\'],\\n    [data-ref=\'product_table-product.discount-th\'],\\n    [data-ref=\'product_table-product.discount-td\'] {\\n        width: 9%;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div id=\\\"header\\\">\\n    <div class=\\\"logo-container\\\">\\n        <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n    <\\/div>\\n    <div id=\\\"company-details\\\"><\\/div>\\n    <div id=\\\"company-address\\\"><\\/div>\\n<\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n    <table id=\\\"spacer-table\\\" cellspacing=\\\"0\\\">\\n        <thead>\\n            <tr>\\n                <td>\\n                    <div id=\\\"header-spacer\\\"><\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/thead>\\n        <tbody>\\n            <tr>\\n                <td>\\n                    <div class=\\\"client-entity-wrapper\\\">\\n                        <div class=\\\"client-wrapper-left-side\\\">\\n                            <div>\\n                                <h4 class=\\\"entity-label\\\" style=\\\"margin-top:0px; margin-bottom:10px;\\\">$entity_label<\\/h4>\\n                                <div id=\\\"client-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\"><\\/div>\\n                                <div id=\\\"vendor-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\"><\\/div>\\n                            <\\/div>\\n                            <div>\\n                                <h4 class=\\\"entity-label\\\" style=\\\"opacity: 0; margin-top:0px; margin-bottom:10px;\\\">&amp;<\\/h4>\\n                                <div id=\\\"shipping-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\"><\\/div>\\n                            <\\/div>\\n                        <\\/div>\\n\\n                        <div class=\\\"entity-details-wrapper-right-side\\\">\\n                            <h4 class=\\\"entity-label\\\" style=\\\"margin-top:0px; margin-bottom:10px; color:transparent;\\\">\\n                                $entity_label<\\/h4>\\n                            <div class=\\\"entity-details-wrapper\\\">\\n                                <table id=\\\"entity-details\\\" dir=\\\"$dir\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\"><\\/table>\\n                            <\\/div>\\n                        <\\/div>\\n                    <\\/div>\\n\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tbody>\\n        <tfoot>\\n            <tr>\\n                <td>\\n                    <div id=\\\"footer-spacer\\\"><\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tfoot>\\n    <\\/table>\\n<\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div id=\\\"footer\\\">\\n    <div style=\\\"width: 100%;\\\">\\n        <p data-ref=\\\"footer_content\\\">$entity_footer<\\/p>\\n    <\\/div>\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.455475','2026-09-16 07:56:52.466745',NULL,0,NULL),(4,NULL,NULL,'Modern',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n  @import url($font_url);\\n\\n  :root {\\n    --primary-color: $primary_color;\\n    --secondary-color: $secondary_color;\\n  }\\n\\n  html {\\n    width: 210mm;\\n    height: 200mm;\\n  }\\n\\n  body {\\n    -webkit-font-smoothing: antialiased;\\n    -moz-osx-font-smoothing: grayscale;\\n    font-family: $font_name, Helvetica, sans-serif;\\n    font-size: $font_size !important;\\n    zoom: 80%;\\n  }\\n\\n  table tr td,\\n  table tr,\\n  th {\\n    font-size: $font_size !important;\\n  }\\n\\n  body,\\n  html {\\n    margin: 0;\\n    padding: 0;\\n  }\\n\\n  @page {\\n    margin: 0 !important;\\n    size: $page_size $page_layout;\\n  }\\n\\n  p {\\n    margin: 0;\\n    padding: 0;\\n  }\\n\\n  #spacer-table>*>tr>td {\\n    padding: 0;\\n  }\\n\\n  #spacer-table {\\n    width: 100%;\\n  }\\n\\n  #header {\\n    background-color: var(--primary-color);\\n    color: white;\\n    display: grid;\\n    grid-template-columns: 1.5fr 1fr;\\n    position: fixed;\\n    top: 0;\\n    width: 100%;\\n  }\\n\\n  #header,\\n  #header-spacer {\\n    height: 160px;\\n    padding: 1rem;\\n    margin-bottom: 1rem;\\n  }\\n\\n  .company-name {\\n    text-align: left;\\n    margin-left: 1rem;\\n  }\\n\\n  #header .company-name {\\n    font-size: 2rem;\\n  }\\n\\n  #entity-details {\\n    margin-top: 1rem;\\n    text-align: left;\\n    color: #fff4e9 !important;\\n    line-height: 1.6 !important;\\n  }\\n\\n  #entity-details>tr,\\n  #entity-details th {\\n    font-weight: normal;\\n  }\\n\\n  .logo-client-wrapper {\\n    margin-left: 2rem;\\n    display: grid;\\n    grid-template-columns: 2fr auto auto;\\n    margin-top: 1rem;\\n    margin-bottom: 1rem;\\n  }\\n\\n  .company-logo {\\n    max-width: $company_logo_size;\\n  }\\n\\n  #client-details {\\n    display: flex;\\n    flex-direction: column;\\n    margin-left: 10px;\\n    margin-right: 2rem;\\n    float: right;\\n\\n  }\\n\\n  #shipping-details {\\n    display: $show_shipping_address;\\n    flex-direction: column;\\n    padding-left: 10px;\\n    padding-right: 2rem;\\n    float: right;\\n  }\\n\\n  #shipping-details>* {\\n    margin-bottom: 0.5rem;\\n  }\\n\\n  #client-details>* {\\n    margin-bottom: 0.5rem;\\n  }\\n\\n  .table-wrapper {\\n    margin: 0rem 2rem;\\n  }\\n\\n  [data-ref=\\\"delivery_note-client.city_state_postal\\\"] p {\\n    display: inline-block;\\n    white-space: nowrap;\\n  }\\n\\n  [data-ref=\\\"table\\\"] {\\n    min-width: 100%;\\n    table-layout: fixed;\\n    overflow-wrap: break-word;\\n  }\\n\\n  .task-time-details {\\n    display: block;\\n    margin-top: 5px;\\n    color: grey;\\n  }\\n\\n  [data-ref=\\\"table\\\"]>thead {\\n    text-align: left;\\n    width: 100%;\\n  }\\n\\n  [data-ref=\\\"table\\\"] th+th {\\n    border-left: 2px solid white;\\n  }\\n\\n  [data-ref=\\\"table\\\"]>thead>tr>th {\\n    padding: 0.8rem;\\n    background-color: var(--secondary-color);\\n    color: white;\\n  }\\n\\n  .right-radius {\\n    text-align: right !important;\\n  }\\n\\n  [data-ref=\\\"table\\\"]>tbody>tr>td {\\n    border-bottom: 1px solid var(--secondary-color);\\n    padding: 0.8rem;\\n  }\\n\\n  td.left-radius {\\n    font-weight: bold;\\n  }\\n\\n\\n  #footer {\\n    background-color: var(--primary-color);\\n    width: 100%;\\n    position: fixed;\\n    bottom: 0;\\n    padding-left: 1rem;\\n  }\\n\\n\\n  #footer,\\n  #footer-spacer {\\n    height: 220px;\\n    padding: 0rem 0rem;\\n    margin-top: 0rem;\\n  }\\n\\n  .footer-content {\\n    display: flex;\\n    width: calc(100% - 2rem);\\n    margin: 0 1rem;\\n    color: #fff4e9;\\n    justify-content: space-between;\\n    align-items: flex-start;\\n  }\\n\\n  \\/* Main footer text area *\\/\\n  .footer-content>div:first-child {\\n    width: 50%;\\n    margin-right: 2rem;\\n  }\\n\\n  \\/* Company details\\/address wrapper *\\/\\n  .footer-company-details-address-wrapper {\\n    width: 50%;\\n    display: grid;\\n    grid-template-columns: 1fr 1fr;\\n    gap: 1rem;\\n    margin-top: 1rem;\\n  }\\n\\n  #company-details,\\n  #company-address {\\n    display: flex;\\n    flex-direction: column;\\n  }\\n\\n  #company-address>*,\\n  #company-details>* {\\n  }\\n\\n  #table-totals {\\n    page-break-inside: avoid;\\n  }\\n\\n  #table-totals {\\n    display: grid;\\n    grid-template-columns: 2fr 1fr;\\n    padding-top: 0.5rem;\\n    padding-left: 2rem;\\n    padding-right: 3rem;\\n    gap: 80px;\\n  }\\n\\n  #table-totals .totals-table-right-side>* {\\n    display: grid;\\n    grid-template-columns: 1fr 1fr;\\n  }\\n\\n  #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n    text-align: \\\"left\\\";\\n    margin-top: 0.75rem;\\n  }\\n\\n  #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n    --tw-space-y-reverse: 0;\\n    margin-top: calc(0.75rem * calc(1 - var(--tw-space-y-reverse)));\\n    margin-bottom: calc(0.75rem * var(--tw-space-y-reverse));\\n  }\\n\\n  #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n    text-align: right;\\n  }\\n\\n  [data-ref=\\\"total_table-footer\\\"] {\\n    margin-top: 1rem;\\n    margin-bottom: 1rem;\\n  }\\n\\n  table {\\n    width: 100%;\\n  }\\n\\n  table[data-ref=\\\"table\\\"] th,\\n  table[data-ref=\\\"table\\\"] td {\\n    padding: 0.2rem 0.4rem;\\n    text-align: left;\\n    vertical-align: top;\\n    border-top: 1px solid #dee2e6;\\n  }\\n\\n  \\/** Markdown-specific styles. **\\/\\n  #product-table h3,\\n  #task-table h3,\\n  #delivery-note-table h3 {\\n    font-size: 1rem;\\n    margin-bottom: 0;\\n  }\\n\\n  [data-ref=\\\"statement-totals\\\"] {\\n    margin-top: 1rem;\\n    margin-bottom: 1rem;\\n    text-align: right;\\n    margin-right: .75rem;\\n  }\\n\\n  [data-ref*=\\\".line_total-td\\\"] {\\n    white-space: nowrap;\\n  }\\n\\n\\n  [data-ref=\'product_table-product.description-th\'],\\n  [data-ref=\'product_table-product.description-td\'] {\\n    min-width: 150px !important;\\n    overflow-wrap: break-word;\\n  }\\n\\n  [data-ref=\'product_table-product.item-td\'] {\\n    font-weight: bold;\\n  }\\n\\n  [data-ref=\'product_table-product.item-th\'] {\\n    width: 10%;\\n  }\\n\\n  [data-ref=\'product_table-product.unit_cost-th\'],\\n  [data-ref=\'product_table-product.quantity-th\'],\\n  [data-ref=\'product_table-product.product1-th\'],\\n  [data-ref=\'product_table-product.product2-th\'],\\n  [data-ref=\'product_table-product.product3-th\'],\\n  [data-ref=\'product_table-product.product4-th\'],\\n  [data-ref=\'task_table-task.hours-th\'],\\n  [data-ref=\'task_table-task.cost-th\'],\\n  [data-ref=\'task_table-task.quantity-th\'],\\n  [data-ref=\'task_table-task.task1-th\'],\\n  [data-ref=\'task_table-task.task2-th\'],\\n  [data-ref=\'task_table-task.task3-th\'],\\n  [data-ref=\'task_table-task.task4-th\'] {\\n    width: 10%;\\n  }\\n\\n  [data-ref=\'product_table-product.tax1-th\'],\\n  [data-ref=\'task_table-task.tax1-th\'] {\\n    width: 7%;\\n  }\\n\\n  [data-ref=\'product_table-product.discount-th\'],\\n  [data-ref=\'task_table-task.discount-th\'] {\\n    width: 8%;\\n  }\\n\\n  [data-ref=\'product_table-product.line_total-th\'],\\n  [data-ref=\'product_table-product.line_total-td\'],\\n  [data-ref=\'task_table-task.line_total-th\'],\\n  [data-ref=\'task_table-task.line_total-td\'] {\\n    width: 12%;\\n    text-align: right;\\n  }\\n\\n  [data-ref=\'task_table-task.description-th\'] {\\n    overflow-wrap: break-word;\\n    min-width: 100px !important;\\n  }\\n\\n  [data-ref=\'task_table-task.service-th\'] {\\n    width: 10%;\\n  }\\n\\n\\n  .stamp {\\n    transform: rotate(12deg);\\n    color: #555;\\n    font-size: 3rem;\\n    font-weight: 700;\\n    border: 0.25rem solid #555;\\n    display: inline-block;\\n    padding: 0.25rem 1rem;\\n    text-transform: uppercase;\\n    border-radius: 1rem;\\n    font-family: \'Courier\';\\n    mix-blend-mode: multiply;\\n    z-index: 200 !important;\\n    position: fixed;\\n    text-align: center;\\n  }\\n\\n  .is-paid {\\n    color: #D23;\\n    border: 1rem double #D23;\\n    transform: rotate(-5deg);\\n    font-size: 6rem;\\n    font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n    border-radius: 0;\\n    padding: 0.5rem;\\n    opacity: 0.2;\\n    z-index: 200 !important;\\n    position: fixed;\\n    display: $show_paid_stamp;\\n\\n  }\\n\\n  .project-header {\\n    font-size: 1.2em;\\n    margin-top: 0.1em;\\n    margin-bottom: 0;\\n    padding-bottom: 0;\\n    margin-left: 0;\\n    margin-right: 0;\\n    font-weight: bold;\\n    color: #505050;\\n  }\\n\\n  .pqrcode {}\\n\\n  #qr-bill {\\n    width: 100% !important;\\n  }\\n\\n  \\/** Useful snippets, uncomment to enable. **\\/\\n\\n  \\/** Hide company logo **\\/\\n  \\/* .company-logo { display: none } *\\/\\n\\n  \\/* Hide company details *\\/\\n  \\/* #company-details > * { display: none } *\\/\\n\\n  \\/* Hide company address *\\/\\n  \\/* #company-address > * { display: none } *\\/\\n\\n  \\/* Hide public notes *\\/\\n  \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n  \\/* Hide terms label *\\/\\n  \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n  \\/* Hide totals table *\\/\\n  \\/* #table-totals { display: none } *\\/\\n\\n  \\/* Hide totals table left side *\\/\\n  \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n  \\/* Hide totals table right side *\\/\\n  \\/* .totals-table-right-side { display: none } *\\/\\n\\n  \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n  \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div id=\\\"header\\\">\\n  <div id=\\\"company-name-wrapper\\\">\\n    <h1 class=\\\"company-name\\\">$company.name<\\/h1>\\n  <\\/div>\\n  <div id=\\\"entity-details-wrapper\\\">\\n    <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n  <\\/div>\\n<\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n  <table id=\\\"spacer-table\\\" cellspacing=\\\"0\\\">\\n    <thead>\\n      <tr>\\n        <td>\\n          <div id=\\\"header-spacer\\\"><\\/div>\\n        <\\/td>\\n      <\\/tr>\\n    <\\/thead>\\n    <tbody>\\n      <tr>\\n        <td>\\n          <div class=\\\"logo-client-wrapper\\\">\\n            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n            <div id=\\\"shipping-details\\\"><\\/div>\\n            <div id=\\\"client-details\\\"><\\/div>\\n            <div id=\\\"vendor-details\\\"><\\/div>\\n          <\\/div>\\n          <div class=\\\"table-wrapper\\\">\\n            <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n\\n            <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n\\n            <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n\\n            <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n            <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n\\n            <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n            <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n            <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n            <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n            <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n            <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n          <\\/div>\\n          <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n        <\\/td>\\n      <\\/tr>\\n    <\\/tbody>\\n    <tfoot>\\n      <tr>\\n        <td>\\n          <div id=\\\"footer-spacer\\\"><\\/div>\\n        <\\/td>\\n      <\\/tr>\\n    <\\/tfoot>\\n  <\\/table>\\n<\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div id=\\\"footer\\\">\\n  <div class=\\\"footer-content\\\">\\n    <div class=\\\"footer-text\\\">\\n      <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n    <\\/div>\\n    <div class=\\\"footer-company-details-address-wrapper\\\">\\n      <div id=\\\"company-details\\\"><\\/div>\\n      <div id=\\\"company-address\\\"><\\/div>\\n    <\\/div>\\n  <\\/div>\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.456370','2026-09-16 07:56:52.469065',NULL,0,NULL),(5,NULL,NULL,'Business',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n\\n    }\\n\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin-left: $global_margin;\\n        margin-right: $global_margin;\\n        margin-top: 0;\\n        margin-bottom: 0;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-container {\\n        display: grid;\\n        grid-template-columns: 1fr auto 1fr;\\n        align-items: start;\\n        gap: 1rem;\\n        width: 100%;\\n        margin-bottom: 2rem;\\n    }\\n\\n    .company-logo-container {\\n        justify-self: start;\\n        align-self: start;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n    }\\n\\n    .header-container>span {\\n        display: block;\\n    }\\n\\n    #company-details {\\n        justify-self: center;\\n        align-self: start;\\n        display: flex;\\n        flex-direction: column;\\n        color: #AAA9A9;\\n        line-height: var(--line-height);\\n    }\\n\\n    #company-address {\\n        justify-self: end;\\n        align-self: start;\\n        display: flex;\\n        flex-direction: column;\\n        color: #b1b1b1;\\n        line-height: var(--line-height);\\n    }\\n\\n    .entity-issued-to {\\n        \\/* margin-top: 2rem; *\\/\\n        font-weight: bold;\\n    }\\n\\n    .entity-issued-to:not(:empty)::after {\\n        content: \\\":\\\";\\n    }\\n\\n    .client-and-entity-wrapper {\\n        display: flex;\\n        justify-content: space-between;\\n        margin-bottom: 2rem;\\n    }\\n\\n    #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        vertical-align: top;\\n    }\\n\\n    #client-details>p:nth-child(2) {\\n        color: var(--primary-color);\\n        font-size: 120%;\\n    }\\n\\n    #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    #entity-details {\\n        background-color: var(--primary-color);\\n        padding: 1.2rem;\\n        border-radius: 1rem;\\n        width: 100%;\\n        color: white;\\n        text-align: left;\\n    }\\n\\n    #entity-details p {\\n        margin-right: 20px;\\n    }\\n\\n    #entity-details th {\\n        font-weight: normal;\\n        padding-bottom: .5rem;\\n    }\\n\\n    #entity-details>tbody>tr>th:nth-child(2) {\\n        text-align: right;\\n        padding-left: 10px;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 0.5rem;\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n        background: var(--secondary-color);\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        padding: 1rem;\\n        color: white;\\n        font-weight: semibold;\\n    }\\n\\n    th.left-radius {\\n        border-top-left-radius: 10px;\\n    }\\n\\n    th.right-radius {\\n        border-top-right-radius: 10px;\\n        text-align: right;\\n    }\\n\\n    td.right-radius {\\n        text-align: right;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(odd)>td {\\n        background: #F7F7F7;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(even)>td {\\n        background: #f7f7f7;\\n    }\\n\\n    #table-totals>*:last-child {\\n        border-bottom-left-radius: 1rem;\\n        border-bottom-right-radius: 1rem;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        gap: 80px;\\n        padding-top: 0.5rem;\\n        padding-bottom: 0.8rem;\\n        \\/*page-break-inside:auto; this may cause weird breaking*\\/\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n        padding-left: 7px;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        padding-right: 17px;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding-label\\\"] {\\n        background-color: var(--secondary-color);\\n        color: white;\\n        font-size: 120%;\\n        font-weight: bold;\\n        padding: 1rem;\\n        border-top-left-radius: 7px;\\n        border-bottom-left-radius: 7px;\\n        white-space: nowrap;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        background-color: var(--secondary-color);\\n        color: white;\\n        font-size: 120%;\\n        font-weight: bold;\\n        padding: 1rem;\\n        border-top-right-radius: 7px;\\n        border-bottom-right-radius: 7px;\\n        white-space: nowrap;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-element=\'product_table-product.description-td\'],\\n    td {\\n        min-width: 100%;\\n        max-width: 300px;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-container\\\">\\n                        <div class=\\\"company-logo-container\\\">\\n                            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                        <\\/div>\\n                        <div id=\\\"company-details\\\"><\\/div>\\n                        <div id=\\\"company-address\\\"><\\/div>\\n                    <\\/div>\\n                    <div class=\\\"client-and-entity-wrapper\\\">\\n                        <div id=\\\"client-details\\\">\\n                            <p class=\\\"entity-issued-to\\\">$entity_issued_to_label<\\/p>\\n                        <\\/div>\\n                        <div id=\\\"vendor-details\\\"><\\/div>\\n                        <div id=\\\"shipping-details\\\"><\\/div>\\n                        <div class=\\\"entity-details-wrapper\\\">\\n                            <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.457117','2026-09-16 07:56:52.471281',NULL,0,NULL),(6,NULL,NULL,'Creative',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin-left: $global_margin;\\n        margin-right: $global_margin;\\n        margin-top: 0;\\n        margin-bottom: 0;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-wrapper {\\n        display: grid;\\n        grid-template-rows: 0.5fr;\\n        grid-template-columns: auto auto auto auto auto;\\n        grid-template-areas: \\\"a b c d e\\\";\\n        grid-auto-columns: minmax(0, 1fr);\\n        grid-auto-flow: column;\\n        align-items: start;\\n        gap: 0px;\\n        line-height: var(--line-height);\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n        float: right;\\n    }\\n\\n    .logo-wrapper {\\n        grid-area: e;\\n        justify-self: end;\\n        align-self: start;\\n    }\\n\\n    #entity-details {\\n        width: 100%;\\n        white-space: nowrap;\\n        text-align: right;\\n    }\\n\\n    #entity-details p {\\n        margin-top: 5px;\\n    }\\n\\n    .header-wrapper #client-details,\\n    .header-wrapper #company-details,\\n    .header-wrapper #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    [data-ref=\\\"company_details-company.name\\\"] {\\n        color: var(--primary-color);\\n        font-weight: bold;\\n    }\\n\\n    .header-wrapper #client-details>*:first-child {\\n        font-weight: bold;\\n    }\\n\\n    .header-wrapper .company-info-wrapper>* {\\n        margin-bottom: 1rem;\\n        grid-row-end: 4;\\n    }\\n\\n    .entity-label-wrapper {\\n        \\/* display: flex; *\\/\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        width: 100%;\\n        word-break: break-all;\\n        box-sizing: border-box;\\n        margin-top: 1rem;\\n        margin-bottom: 1rem;\\n\\n    }\\n\\n    .entity-label {\\n        display: flex;\\n    }\\n\\n    .entity-label h4 {\\n        margin-top: 0rem;\\n        margin-bottom: 0rem;\\n    }\\n\\n    .entity-details-wrapper {\\n        flex-shrink: 0;\\n    }\\n\\n    .entity-label-wrapper .entity-label>* {\\n        font-size: 2.5rem;\\n\\n    }\\n\\n    .entity-label-wrapper .entity-label>*:first-child {\\n        text-transform: uppercase;\\n        white-space: nowrap;\\n    }\\n\\n    .entity-label-wrapper .entity-label>*:last-child {\\n        color: var(--primary-color);\\n        font-style: italic;\\n\\n    }\\n\\n    #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        line-height: var(--line-height) !important;\\n        margin-left: 1rem;\\n    }\\n\\n    .entity-label-wrapper #entity-details>tr,\\n    .entity-label-wrapper #entity-details th {\\n        font-weight: normal;\\n        line-height: var(--line-height);\\n        padding-left: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\\\"table\\\"]:not(:empty) {\\n        border-top: 5px solid var(--primary-color);\\n        margin-top: 1rem;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n\\n    [data-ref=\'product_table-product.description-th\'],\\n    [data-ref=\'task_table-task.description-th\'] {\\n        width: 35% !important;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\'product_table-product.item-td\'] {\\n        color: var(--primary-color);\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        font-size: 1.1rem;\\n        padding: 1rem;\\n    }\\n\\n    th.right-radius {\\n        text-align: right !important;\\n    }\\n\\n    td.right-radius {\\n        text-align: right !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(odd) {\\n        background-color: #e8e8e8;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        padding-top: 1rem;\\n        margin-right: .75rem;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n    }\\n\\n    #table-totals>*>* {}\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        padding-right: 0.8rem;\\n    }\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-element=\'product_table-product.description-td\'],\\n    td {\\n        min-width: 100%;\\n        max-width: 300px;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-wrapper\\\">\\n                        <div id=\\\"client-details\\\"><\\/div>\\n                        <div id=\\\"vendor-details\\\"><\\/div>\\n                        <div id=\\\"shipping-details\\\"><\\/div>\\n\\n                        <div class=\\\"company-info-wrapper\\\">\\n                            <div id=\\\"company-details\\\"><\\/div>\\n                            <div id=\\\"company-address\\\"><\\/div>\\n                        <\\/div>\\n                        <div class=\\\"logo-wrapper\\\">\\n                            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                        <\\/div>\\n                    <\\/div>\\n                    <div class=\\\"entity-label-wrapper\\\">\\n                        <div class=\\\"entity-label\\\">\\n                            <h4>$entity_label<\\/h4>\\n                            <h4>#$entity_number<\\/h4>\\n                        <\\/div>\\n                        <div class=\\\"entity-details-wrapper\\\">\\n                            <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.457788','2026-09-16 07:56:52.473314',NULL,0,NULL),(7,NULL,NULL,'Elegant',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin: $global_margin;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .company-logo {\\n        \\/*        max-width: 55%;*\\/\\n        max-width: $company_logo_size;\\n        margin-left: auto;\\n        margin-right: auto;\\n        display: block;\\n    }\\n\\n    .company-logo-wrapper {\\n        padding-bottom: 10px;\\n        border-bottom: 4px solid;\\n    }\\n\\n    .company-logo-wrapper {}\\n\\n    .right-radius {\\n        padding-right: 1rem;\\n        text-align: right;\\n    }\\n\\n    .client-entity-wrapper {\\n        width: 100%;\\n        margin-top: 1rem;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    .wrapper-left-side {\\n        display: grid;\\n        grid-template-columns: repeat(2, minmax(0, 1fr)) repeat(2, minmax(0, 1.5fr));\\n        gap: 0px;\\n        width: 100%;\\n    }\\n\\n    #entity-details {\\n        width: 100%;\\n        table-layout: fixed;\\n    }\\n\\n    #entity-details p {\\n        margin-right: 0px;\\n        margin-top: 0px;\\n        white-space: nowrap;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    .client-entity-wrapper .wrapper-info-text {\\n        display: block;\\n        font-size: 1.5rem;\\n        font-weight: normal;\\n    }\\n\\n    .client-entity-wrapper .shipping-info-text {\\n        display: block;\\n        font-size: 1.5rem;\\n        font-weight: normal;\\n        display: $show_shipping_address;\\n    }\\n\\n    .wrapper-right-side {}\\n\\n    .text-with-client {\\n        margin-right: 1px;\\n    }\\n\\n    .client-entity-wrapper .wrapper-left-side #client-details,\\n    .client-entity-wrapper .wrapper-left-side #company-details,\\n    .client-entity-wrapper .wrapper-left-side #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        margin-right: 5px;\\n    }\\n\\n    .client-entity-wrapper .wrapper-left-side #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        margin-right: 5px;\\n    }\\n\\n    .client-entity-wrapper .wrapper-left-side .company-info {\\n        border-left: 1px solid;\\n        padding-left: 1rem;\\n    }\\n\\n    .client-entity-wrapper #entity-details {\\n        text-align: left;\\n        min-width: 100%;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    .client-entity-wrapper #entity-details>tr,\\n    .client-entity-wrapper #entity-details th {\\n        font-weight: normal;\\n        padding-right: 8px;\\n        line-height: var(--line-height) !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 3rem;\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        font-size: 1.1rem;\\n        padding-bottom: 1.5rem;\\n        padding-left: 1rem;\\n        color: var(--primary-color);\\n        font-weight: bold;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th:last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        border-bottom: 1pt solid;\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:first-child>td {\\n        border-top: 1pt solid !important;\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td:last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"shipping_address-label\\\"] {\\n        display: none;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0.5rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        padding-top: 0.5rem;\\n        gap: 80px;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        margin-right: 1rem;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {}\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-ref=\'product_table-product.description-td\'],\\n    td {\\n        min-width: 100%;\\n        max-width: 300px;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\'task_table-task.description-th\'] {\\n        overflow-wrap: break-word;\\n        min-width: 100px !important;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"company-logo-wrapper\\\">\\n                        <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                    <\\/div>\\n                    <hr class=\\\"double-border\\\">\\n                    <div class=\\\"client-entity-wrapper\\\" style=\\\"\\\">\\n                        <div class=\\\"wrapper-left-side\\\">\\n                            <div class=\\\"text-with-client\\\">\\n                                <h2 class=\\\"wrapper-info-text\\\">$to_label<\\/h2>\\n                                <div id=\\\"client-details\\\"><\\/div>\\n                                <div id=\\\"vendor-details\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"shipping-info\\\" style=\\\"\\\">\\n                                <h2 class=\\\"shipping-info-text\\\">$shipping_label<\\/h2>\\n                                <div id=\\\"shipping-details\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"company-info\\\" style=\\\"\\\">\\n                                <h2 class=\\\"wrapper-info-text\\\">$from_label<\\/h2>\\n                                <div id=\\\"company-details\\\"><\\/div>\\n                                <div id=\\\"company-address\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"wrapper-right-side\\\">\\n                                <h2 class=\\\"wrapper-info-text\\\">$details_label<\\/h2>\\n                                <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                            <\\/div>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.458444','2026-09-16 07:56:52.475471',NULL,0,NULL),(8,NULL,NULL,'Hipster',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin: $global_margin;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-wrapper {\\n        display: grid;\\n        grid-template-columns: 0.5fr 1.5fr;\\n        gap: 0px;\\n        line-height: var(--line-height);\\n    }\\n\\n    .header-wrapper .header-text-label {\\n        font-size: 1.1rem;\\n        color: var(--primary-color);\\n        text-transform: uppercase;\\n        font-weight: bold;\\n    }\\n\\n    .header-wrapper .header-left-side-wrapper {\\n        grid-template-columns: 1fr 1fr;\\n        gap: 10px;\\n        border-left: 1px solid #303030;\\n        padding-left: 1rem;\\n    }\\n\\n    .header-wrapper .header-left-side-wrapper>* {\\n        margin-bottom: 0.8rem;\\n    }\\n\\n    .header-wrapper .header-left-side-wrapper #company-details,\\n    .header-wrapper .header-left-side-wrapper #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        padding-right: 1rem;\\n    }\\n\\n    .header-wrapper .header-right-side-wrapper {\\n        display: grid;\\n        gap: 10px;\\n        border-left: 1px solid #303030;\\n        padding-left: 1rem;\\n\\n        grid-template-columns: auto auto auto;\\n        grid-template-areas: \\\"a b c\\\";\\n        grid-auto-columns: minmax(0, 1fr);\\n        grid-auto-flow: column;\\n        align-items: start;\\n    }\\n\\n    .header-wrapper .header-right-side-wrapper #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        margin-top: 0.8rem;\\n        grid-area: a;\\n        justify-self: left !important;\\n        align-self: start !important;\\n    }\\n\\n    .header-wrapper .header-right-side-wrapper #shipping-details {\\n        display: $show_shipping_address_block;\\n        flex-direction: column;\\n        margin-top: 0.8rem;\\n        grid-area: b;\\n    }\\n\\n    .header-wrapper .header-right-side-wrapper-left-shipping {\\n        padding-left: 1rem;\\n        border-left: 1px solid #303030;\\n        float: left;\\n    }\\n\\n    .header-wrapper .header-right-side-wrapper-right {\\n        grid-area: c;\\n        justify-self: end;\\n        align-self: start;\\n        justify-content: end;\\n        float: right;\\n    }\\n\\n    .shipping-text-label {\\n        font-size: 1.1rem;\\n        color: var(--primary-color);\\n        text-transform: uppercase;\\n        font-weight: bold;\\n        display: $show_shipping_address;\\n    }\\n\\n    .header-wrapper {\\n        margin-left: auto;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n        float: right;\\n        object-fit: contain;\\n    }\\n\\n    .entity-label {\\n        font-size: 3rem;\\n        text-transform: uppercase;\\n        margin: 2rem 0;\\n    }\\n\\n    .entity-details-wrapper>* {\\n        margin-right: 1.5rem;\\n        direction: $dir;\\n    }\\n\\n    .entity-details-wrapper {\\n        display: flex;\\n        flex-wrap: wrap;\\n        direction: $dir;\\n        justify-content: space-between;\\n    }\\n\\n    .entity-details-wrapper .entity-property-label {\\n        text-transform: uppercase;\\n    }\\n\\n    .entity-property-label:not(:empty)::after {\\n        content: \\\":\\\";\\n    }\\n\\n    .entity-details-wrapper [data-element=\'entity-details-wrapper-invoice-number-label\'],\\n    .entity-details-wrapper [data-element=\'entity-details-wrapper-amount-due\'] {\\n        color: var(--primary-color);\\n        font-weight: bold;\\n    }\\n\\n    [data-ref=\\\"shipping_address-label\\\"] {\\n        display: none;\\n    }\\n\\n    td.left-radius {\\n        text-align: left !important;\\n        padding-left: 1rem !important;\\n    }\\n\\n    th.left-radius {\\n        text-align: left !important;\\n        padding-left: 0.5rem !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 1rem;\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n        text-transform: uppercase;\\n        font-weight: bold;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        font-size: 1.1rem;\\n        padding-bottom: 1.5rem;\\n        padding-left: 1rem;\\n        border-left: 1px solid;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th:nth-last-child(2) {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        padding-left: 1rem;\\n        padding-top: 1rem;\\n        padding-bottom: 1rem;\\n        border-left: 1px solid;\\n    }\\n\\n    .right-radius {\\n        text-align: right;\\n    }\\n\\n    #table-totals {\\n        margin-top: 1rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        padding-top: 0.5rem;\\n        margin-right: 0rem;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 0rem;\\n    }\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\'task_table-task.service-th\'],\\n    [data-ref=\'product_table-product.item-th\'] {\\n        padding-left: 1rem !important;\\n        width: 14%;\\n    }\\n\\n    [data-ref=\'task_table-task.description-th\'],\\n    [data-ref=\'product_table-product.description-th\'],\\n    [data-ref=\'product_table-product.description-td\'],\\n    [data-ref=\\\"task_table-task.description-td\\\"] {\\n        min-width: 100px !important;\\n        ;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\\\"product_table-product.unit_cost-td\\\"],\\n    [data-ref=\\\"product_table-product.unit_cost-th\\\"],\\n    [data-ref=\'task_table-task.cost-th\'],\\n    [data-ref=\'task_table-task.cost-td\'] {\\n        text-align: center !important;\\n        width: 10%;\\n        padding-left: 0 !important;\\n        padding-right: 0 !important;\\n    }\\n\\n    [data-ref=\\\"product_table-product.quantity-th\\\"],\\n    [data-ref=\\\"product_table-product.quantity-td\\\"],\\n    [data-ref=\'task_table-task.hours-th\'],\\n    [data-ref=\'task_table-task.hours-td\'] {\\n        width: 10%;\\n        text-align: center !important;\\n        padding-left: 0 !important;\\n        padding-right: 0 !important;\\n    }\\n\\n    [data-ref=\\\"task_table-task.discount-th\\\"],\\n    [data-ref=\\\"task_table-task.discount-td\\\"],\\n    [data-ref=\\\"product_table-product.discount-th\\\"],\\n    [data-ref=\\\"product_table-product.discount-td\\\"] {\\n        text-align: left !important;\\n        width: 9%;\\n    }\\n\\n    [data-ref=\\\"task_table-task.tax1-th\\\"],\\n    [data-ref=\\\"task_table-task.tax1-td\\\"],\\n    [data-ref=\\\"product_table-product.tax1-th\\\"],\\n    [data-ref=\\\"product_table-product.tax1-td\\\"] {\\n        text-align: center !important;\\n        width: 9%;\\n        padding-left: 0 !important;\\n        padding-right: 0 !important;\\n    }\\n\\n    [data-ref=\\\"product_table-product.line_total-th\\\"],\\n    [data-ref=\\\"product_table-product.line_total-td\\\"] {\\n        text-align: right;\\n        width: 13%;\\n    }\\n\\n    [data-ref=\\\"task_table-task.line_total-th\\\"],\\n    [data-ref=\\\"task_table-task.line_total-td\\\"] {\\n        text-align: right;\\n        width: 13%;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding-label\\\"] {\\n        font-weight: bold;\\n        font-size: 120%;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        color: var(--primary-color);\\n        font-weight: bold;\\n        font-size: 120%;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 0;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-wrapper\\\">\\n                        <div class=\\\"header-left-side-wrapper\\\">\\n                            <p class=\\\"header-text-label\\\">$from_label:<\\/p>\\n                            <div id=\\\"company-details\\\"><\\/div>\\n                            <div id=\\\"company-address\\\"><\\/div>\\n                        <\\/div>\\n                        <div class=\\\"header-right-side-wrapper\\\">\\n                            <div class=\\\"header-right-side-wrapper-left\\\">\\n                                <p class=\\\"header-text-label\\\">$to_label:<\\/p>\\n                                <div id=\\\"client-details\\\"><\\/div>\\n                                <div id=\\\"vendor-details\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"header-right-side-wrapper-left-shipping\\\">\\n                                <p class=\\\"shipping-text-label\\\">$shipping_label:<\\/p>\\n                                <div id=\\\"shipping-details\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"header-right-side-wrapper-right\\\">\\n                                <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                            <\\/div>\\n                        <\\/div>\\n                    <\\/div>\\n                    <h1 class=\\\"entity-label\\\">$entity_label<\\/h1>\\n                    <div class=\\\"entity-details-wrapper\\\">\\n                        <div>\\n                            <span class=\\\"entity-property-label\\\" data-element=\\\"entity-details-wrapper-invoice-number-label\\\">\\n                                $entity_number_label\\n                            <\\/span>\\n                            <span class=\\\"entity-property-value\\\">$entity_number<\\/span>\\n                        <\\/div>\\n                        <div>\\n                            <span class=\\\"entity-property-label\\\">$date_label<\\/span>\\n                            <span class=\\\"entity-property-value\\\">$date<\\/span>\\n                        <\\/div>\\n                        <div>\\n                            <span class=\\\"entity-property-label\\\">$payment_due_label<\\/span>\\n                            <span class=\\\"entity-property-value\\\">$payment_due<\\/span>\\n                        <\\/div>\\n                        <div>\\n                            <span class=\\\"entity-property-label\\\">$amount_due_label<\\/span>\\n                            <span class=\\\"entity-property-value\\\" data-element=\\\"entity-details-wrapper-amount-due\\\" style=\\\"float:right;\\\">$amount_due<\\/span>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.459160','2026-09-16 07:56:52.477851',NULL,0,NULL),(9,NULL,NULL,'Playful',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    @page {\\n        margin: -0.25cm !important;\\n        size: $page_size $page_layout;\\n        margin-top: 1rem;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-wrapper {\\n        display: grid;\\n        grid-template-columns: 1.5fr 1fr;\\n        gap: 20px;\\n        padding: 1rem 0rem 0rem 2rem;\\n    }\\n\\n    .header-wrapper .entity-details-wrapper {\\n        background-color: var(--primary-color);\\n        padding: 0.5rem;\\n        border-radius: 10px;\\n        align-self: flex-start;\\n    }\\n\\n    #entity-details p {\\n        margin-right: 20px;\\n        white-space: nowrap;\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.5rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.5rem * var(--tw-space-y-reverse));\\n    }\\n\\n    .header-wrapper #entity-details {\\n        width: 100%;\\n        color: white;\\n        text-align: left;\\n        line-height: 1.2;\\n    }\\n\\n    .header-wrapper #entity-details>tr,\\n    .header-wrapper #entity-details th {\\n        font-weight: normal;\\n    }\\n\\n    .company-logo {\\n        \\/*        max-width: 65%;*\\/\\n        max-width: $company_logo_size;\\n    }\\n\\n    .contacts-wrapper {\\n        display: grid;\\n        gap: 0px;\\n        padding: 1rem 0rem 0rem 1rem;\\n        grid-template-columns: 1fr 1fr auto;\\n        grid-template-areas: \\\"a b c\\\";\\n        grid-auto-columns: minmax(0, 5fr);\\n        grid-auto-flow: column;\\n        justify-content: space-between;\\n        margin-left: 1rem;\\n\\n    }\\n\\n    .contacts-wrapper .contact-label {\\n        font-weight: bold;\\n        color: var(--primary-color);\\n        margin-left: 1rem;\\n    }\\n\\n    .contacts-wrapper .shipping-label {\\n        font-weight: bold;\\n        color: var(--primary-color);\\n        margin-left: 1rem;\\n        display: $show_shipping_address;\\n    }\\n\\n    .contacts-wrapper #company-address,\\n    .contacts-wrapper #company-details,\\n    .contacts-wrapper #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        margin-bottom: 0.5rem;\\n    }\\n\\n    .contacts-wrapper #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        margin-bottom: 0.5rem;\\n    }\\n\\n    .contacts-wrapper .company-info {\\n        margin-top: 1rem;\\n        padding-top: 1rem;\\n        border-top: 1px solid var(--primary-color);\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n        gap: 10px;\\n    }\\n\\n    .contacts-wrapper #client-details {\\n        margin-top: 1rem;\\n        padding-top: 1rem;\\n        border-top: 1px solid var(--primary-color);\\n    }\\n\\n    .contacts-wrapper #vendor-details {\\n        margin-top: 1rem;\\n        padding-top: 1rem;\\n        border-top: 1px solid var(--primary-color);\\n    }\\n\\n    .contacts-wrapper #shipping-details {\\n        margin-top: 1rem;\\n        padding: 1rem;\\n        padding-right: 0rem;\\n        border-top: 1px solid var(--primary-color);\\n    }\\n\\n\\n    .contact-wrapper-left-side {\\n        border-bottom: 1px solid var(--primary-color);\\n    }\\n\\n    .contact-wrapper-right-side {\\n        border-bottom: 1px solid var(--primary-color);\\n        margin-left: 20px;\\n    }\\n\\n    .shipping-wrapper-right-side {\\n        border-bottom: 1px solid var(--primary-color);\\n        display: $show_shipping_address_block;\\n        margin-left: 20px;\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        padding-left: 2rem;\\n        padding-right: 0rem;\\n        margin-top: 1rem;\\n        margin-bottom: 5px;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        font-size: 1.2rem;\\n        padding: 1rem;\\n        background: var(--primary-color);\\n        color: white;\\n    }\\n\\n    th.left-radius {\\n        border-top-left-radius: 10px;\\n    }\\n\\n    th.right-radius {\\n        border-top-right-radius: 10px;\\n        text-align: right;\\n    }\\n\\n    td.right-radius {\\n        text-align: right;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        background-color: #F7F7F7;\\n        border-bottom: 1px solid var(--primary-color);\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td.left-radius {\\n        color: var(--primary-color);\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td.right-radius {\\n        text-align: right;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0.5rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        gap: 80px;\\n        padding-left: 2rem;\\n        padding-right: 0rem;\\n        break-inside: avoid;\\n        overflow: visible !important;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        margin-top: .75rem;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.75rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.75rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    #header {\\n        position: fixed;\\n        top: 0;\\n        min-width: 100%;\\n        display: grid;\\n        grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;\\n        margin-left: -10px;\\n    }\\n\\n    #header>* {\\n        padding: 10px;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        text-align: left;\\n        padding-left: 2rem;\\n        padding-right: 2rem;\\n    }\\n\\n    #footer {\\n        margin-top: 1rem;\\n        break-inside: avoid;\\n        overflow: visible !important;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    #footer-colors {\\n        position: fixed;\\n        bottom: 0;\\n        min-width: 100%;\\n        display: grid;\\n        grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;\\n        margin-left: -10px;\\n    }\\n\\n    #footer-colors>* {\\n        padding: 10px;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        padding-left: 3rem;\\n        padding-right: 3rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    .repeating-header,\\n    .repeating-header-space {\\n        height: 20px;\\n        page-break-inside: avoid;\\n        page-break-before: avoid;\\n        page-break-after: avoid;\\n    }\\n\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 20px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n    [data-element=\'product_table-product.description-td\'],\\n    td {\\n        min-width: 100%;\\n        max-width: 300px;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\\\"shipping_address-label\\\"] {\\n        display: none;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div id=\\\"header\\\">\\n        <div style=\\\"background-color: #00968B\\\"><!-- 1 --><\\/div>\\n        <div style=\\\"background-color: #1D756E\\\"><!-- 2 --><\\/div>\\n        <div style=\\\"background-color: #FCB600\\\"><!-- 3 --><\\/div>\\n        <div style=\\\"background-color: #BA932F\\\"><!-- 4 --><\\/div>\\n        <div style=\\\"background-color: #A72A4E\\\"><!-- 5 --><\\/div>\\n        <div style=\\\"background-color: #E20041\\\"><!-- 6 --><\\/div>\\n        <div style=\\\"background-color: #F8B300\\\"><!-- 7 --><\\/div>\\n        <div style=\\\"background-color: #009B8F\\\"><!-- 8 --><\\/div>\\n    <\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n    <table style=\\\"min-width: 100%\\\">\\n        <thead>\\n            <tr>\\n                <td>\\n                    <div class=\\\"repeating-header-space\\\">&#xA0;<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/thead>\\n        <tbody>\\n            <tr>\\n                <td>\\n                    <div class=\\\"header-wrapper\\\">\\n                        <div>\\n                            <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                        <\\/div>\\n                        <div class=\\\"entity-details-wrapper\\\">\\n                            <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" dir=\\\"$dir\\\"><\\/table>\\n                        <\\/div>\\n                    <\\/div>\\n                    <div class=\\\"contacts-wrapper\\\">\\n                        <div class=\\\"contact-wrapper-left-side\\\">\\n                            <p class=\\\"contact-label\\\">$from_label:<\\/p>\\n                            <div class=\\\"company-info\\\">\\n                                <div id=\\\"company-details\\\"><\\/div>\\n                                <div id=\\\"company-address\\\"><\\/div>\\n                            <\\/div>\\n                        <\\/div>\\n                        <div class=\\\"contact-wrapper-right-side\\\">\\n                            <p class=\\\"contact-label\\\">$to_label:<\\/p>\\n                            <div id=\\\"client-details\\\"><\\/div>\\n                            <div id=\\\"vendor-details\\\"><\\/div>\\n                        <\\/div>\\n\\n                        <div class=\\\"shipping-wrapper-right-side\\\">\\n                            <p class=\\\"shipping-label\\\">$shipping_label:<\\/p>\\n                            <div id=\\\"shipping-details\\\"><\\/div>\\n                        <\\/div>\\n                    <\\/div>\\n                    <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                    <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                    <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tbody>\\n        <tfoot>\\n            <tr>\\n                <td>\\n                    <div class=\\\"repeating-footer-space\\\">&#xA0;<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tfoot>\\n    <\\/table>\\n<\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <div data-ref=\\\"total_table-footer\\\">$entity_footer<\\/div>\\n\\n    <div id=\\\"footer-colors\\\">\\n        <div style=\\\"background-color: #00968B\\\"><!-- 1 --><\\/div>\\n        <div style=\\\"background-color: #1D756E\\\"><!-- 2 --><\\/div>\\n        <div style=\\\"background-color: #FCB600\\\"><!-- 3 --><\\/div>\\n        <div style=\\\"background-color: #BA932F\\\"><!-- 4 --><\\/div>\\n        <div style=\\\"background-color: #A72A4E\\\"><!-- 5 --><\\/div>\\n        <div style=\\\"background-color: #E20041\\\"><!-- 6 --><\\/div>\\n        <div style=\\\"background-color: #F8B300\\\"><!-- 7 --><\\/div>\\n        <div style=\\\"background-color: #009B8F\\\"><!-- 8 --><\\/div>\\n    <\\/div>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.459816','2026-09-16 07:56:52.480250',NULL,0,NULL),(10,NULL,NULL,'Tech',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n    }\\n\\n    html {\\n        width: 210mm;\\n        height: 200mm;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n        margin: 0;\\n    }\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    @page {\\n        margin: 0;\\n        size: $page_size $page_layout;\\n    }\\n\\n    @media print {\\n\\n        .header-wrapper,\\n        .body-wrapper {\\n            margin: $global_margin;\\n        }\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    \\/** End of global, standard CSS *\\/\\n    .header-wrapper {\\n        display: grid;\\n        grid-template-columns: auto 1fr auto;\\n        grid-template-areas: \\\"a b c\\\";\\n        grid-auto-columns: minmax(0, 5fr);\\n        grid-auto-flow: column;\\n        justify-content: space-between;\\n    }\\n\\n    .top-right-side-section {\\n        display: inline-block;\\n        flex-direction: column;\\n        justify-content: flex-end;\\n        white-space: nowrap;\\n        vertical-align: top;\\n    }\\n\\n    .logo-and-partial-entity-info {\\n        display: flex;\\n        flex-direction: column;\\n        justify-content: space-between;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n    }\\n\\n    .header-invoice-number {\\n        color: var(--primary-color);\\n    }\\n\\n    .header-payment-due-label,\\n    .header-amount-due-label {\\n        text-transform: uppercase;\\n    }\\n\\n    .header-amount-due-value {\\n        color: var(--primary-color);\\n    }\\n\\n    .hero-section {\\n        margin-top: 5px;\\n        min-width: 100% !important;\\n        background: url(\'$tech_hero_image\');\\n        \\/** If you want to replace the image, this is the place to do it. *\\/\\n        -webkit-background-size: cover;\\n        -moz-background-size: cover;\\n        -o-background-size: cover;\\n        background-size: cover;\\n        display: grid;\\n        grid-template-columns: 1fr 1.5fr;\\n    }\\n\\n    .hero-contact-section {\\n        background-color: rgba(255, 255, 255, 0.98);\\n        margin: 1rem;\\n        padding: 1rem;\\n        border-radius: 5px;\\n    }\\n\\n    .client-details,\\n    .company-details {\\n        display: flex;\\n        flex-direction: row;\\n        justify-items: start;\\n    }\\n\\n    .spacer {\\n        display: flex;\\n    }\\n\\n    .client-details-to-label {\\n        text-transform: uppercase;\\n        font-weight: bold;\\n        color: var(--primary-color);\\n        margin-right: 10px;\\n    }\\n\\n    .shipping-to-label {\\n        text-transform: uppercase;\\n        font-weight: bold;\\n        color: var(--primary-color);\\n        margin-right: 10px;\\n        display: $show_shipping_address;\\n    }\\n\\n    #shipping-details {\\n        display: $show_shipping_address;\\n        flex-direction: column;\\n        white-space: nowrap;\\n    }\\n\\n    [data-ref=\\\"shipping_address-label\\\"] {\\n        display: none;\\n    }\\n\\n    #client-details,\\n    #company-details,\\n    #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        white-space: nowrap;\\n    }\\n\\n    .company-details-wrapper {\\n        display: flex;\\n        flex-direction: column;\\n    }\\n\\n    .company-details {\\n        margin-top: 20px;\\n    }\\n\\n    .body-wrapper {}\\n\\n    [data-ref=\\\"table\\\"] {\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n        margin-top: 3rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        text-transform: uppercase;\\n        font-weight: normal;\\n        padding: 1rem;\\n        border-bottom: 5px solid black;\\n        text-align: left;\\n        font-size: 1.1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th:last-child {\\n        text-align: right;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        border-bottom: 1px solid #e6e6e6;\\n        padding: 1rem;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td:first-child {\\n        color: var(--primary-color);\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td:last-child {\\n        text-align: right;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    #table-totals {\\n        page-break-inside: avoid;\\n    }\\n\\n    #table-totals {\\n        margin-top: 2rem;\\n        display: grid;\\n        grid-template-columns: 2fr 1fr;\\n        gap: 80px;\\n        margin-right: .5rem;\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: $dir_text_align;\\n        padding: 7px;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        padding: 7px;\\n    }\\n\\n    #table-totals>* [data-element=\'total-table-balance-due-label\'],\\n    #table-totals>* [data-element=\'total-table-balance-due\'] {\\n        font-weight: bold;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        padding-left: 1.5rem;\\n        padding-right: 2rem;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding-label\\\"],\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        background-color: var(--primary-color);\\n        color: white;\\n    }\\n\\n    #footer {\\n        margin-top: 30px;\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    \\/** .repeating-header,\\n    .repeating-header-space, **\\/\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 10px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n    }\\n\\n\\n    [data-ref=\'product_table-product.description-td\'],\\n    [data-ref=\'task_table-task.description-td\'] {\\n        min-width: 150px !important;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\'product_table-product.item-th\'],\\n    [data-ref=\'task_table-task.service-th\'] {\\n        width: 10%;\\n    }\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* #company-details > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide public notes *\\/\\n    \\/* [data-ref=\\\"total_table-public_notes\\\"] { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n                    <div class=\\\"header-wrapper\\\">\\n                        <div class=\\\"logo-and-partial-entity-info\\\">\\n                            <div class=\\\"company-logo-wrapper\\\">\\n                                <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                            <\\/div>\\n                        <\\/div>\\n                        <div class=\\\"spacer\\\"><\\/div>\\n                        <div class=\\\"top-right-side-section\\\">\\n                            <table style=\\\"white-space: nowrap;\\\" cellspacing=\\\"10\\\">\\n                                <tr>\\n                                    <td>$entity_number_label:<\\/td>\\n                                    <td class=\\\"header-invoice-number\\\">$entity_number<\\/td>\\n                                <\\/tr>\\n                                <tr>\\n                                    <td>$date_label <\\/td>\\n                                    <td>$date<\\/td>\\n                                <\\/tr>\\n                                <tr class=\\\"header-payment-due-label\\\">\\n                                    <td>$payment_due_label <\\/td>\\n                                    <td>$due_date<\\/td>\\n                                <\\/tr>\\n                                <tr>\\n                                    <td class=\\\"header-amount-due-label\\\">$amount_due_label<\\/td>\\n                                    <td class=\\\"header-amount-due-value\\\">$balance_due<\\/td>\\n                                <\\/tr>\\n                            <\\/table>\\n                        <\\/div>\\n                    <\\/div>\\n                    <div class=\\\"hero-section\\\">\\n                        <div class=\\\"hero-contact-section\\\">\\n                            <div class=\\\"client-details\\\">\\n                                <span class=\\\"client-details-to-label\\\">$to_label:<\\/span>\\n                                <div id=\\\"client-details\\\"><\\/div>\\n                                <div id=\\\"vendor-details\\\"><\\/div>\\n                                <span class=\\\"shipping-to-label\\\">$shipping_label:<\\/span>\\n                                <div id=\\\"shipping-details\\\"><\\/div>\\n                            <\\/div>\\n                            <div class=\\\"company-details\\\">\\n                                <span class=\\\"client-details-to-label\\\">$from_label:<\\/span>\\n                                <div class=\\\"company-details-wrapper\\\">\\n                                    <div id=\\\"company-details\\\"><\\/div>\\n                                    <div id=\\\"company-address\\\"><\\/div>\\n                                <\\/div>\\n                            <\\/div>\\n                        <\\/div>\\n                    <\\/div>\\n                    <div class=\\\"body-wrapper\\\">\\n                        <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                    <\\/div>\\n                <\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div class=\\\"repeating-footerx\\\" id=\\\"footer\\\">\\n    <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.460460','2026-09-16 07:56:52.482423',NULL,0,NULL),(11,NULL,NULL,'Calm',0,1,'{\"includes\":\"<style id=\\\"style\\\">\\n    @import url($font_url);\\n\\n    :root {\\n        --primary-color: $primary_color;\\n        --secondary-color: $secondary_color;\\n        --line-height: 1.6;\\n    }\\n\\n    body {\\n        -webkit-font-smoothing: antialiased;\\n        -moz-osx-font-smoothing: grayscale;\\n        font-family: $font_name, Helvetica, sans-serif;\\n        font-size: $font_size !important;\\n        zoom: 80%;\\n    }\\n\\n\\n    table tr td,\\n    table tr,\\n    th {\\n        font-size: $font_size !important;\\n    }\\n\\n    html {\\n        margin: 0;\\n        padding-top: 1rem;\\n        padding-left: 4rem;\\n        padding-right: 4rem;\\n    }\\n\\n    @page {\\n        margin: 0 !important;\\n        size: $page_size $page_layout;\\n    }\\n\\n    p {\\n        margin: 0;\\n        padding: 0;\\n    }\\n\\n    .header-wrapper {\\n        display: grid;\\n        margin-top: 2rem;\\n        grid-template-columns: 2fr 1fr 1fr;\\n        grid-template-areas: \\\"a b c\\\";\\n        grid-auto-columns: minmax(0, 5fr);\\n        grid-auto-flow: column;\\n        justify-content: left;\\n    }\\n\\n    .header-wrapper2 {\\n        display: grid;\\n        margin-top: 2rem;\\n        grid-template-columns: 2fr 2fr auto;\\n        grid-template-areas: \\\"a b c\\\";\\n        grid-auto-columns: minmax(0, 5fr);\\n        grid-auto-flow: column;\\n        justify-content: space-between;\\n\\n    }\\n\\n    .header-wrapper2 .entity-container {\\n        justify-self: end;\\n        align-self: start;\\n    }\\n\\n    .company-logo {\\n        max-width: $company_logo_size;\\n    }\\n\\n    .logo-container {\\n        display: flex;\\n        flex-direction: column;\\n    }\\n\\n    .company-container {\\n        display: flex;\\n        flex-direction: column;\\n    }\\n\\n    .client-and-entity-wrapper {\\n        display: flex;\\n        padding: 1rem;\\n        border-top: 1px solid #d8d8d8;\\n        border-bottom: 1px solid #d8d8d8;\\n    }\\n\\n    .header-wrapper #company-address {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        margin-left: 20px;\\n    }\\n\\n    .header-wrapper #company-details {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n        margin-left: 20px;\\n    }\\n\\n    .header-wrapper #entity-details {\\n        text-align: left;\\n        line-height: var(--line-height);\\n        width: 100%;\\n    }\\n\\n    .header-wrapper #entity-details>tr,\\n    .header-wrapper #entity-details th {\\n        font-weight: normal;\\n        white-space: nowrap;\\n    }\\n\\n    .header-wrapper #entity-details [data-element=\'entity-balance-due-label\'],\\n    .header-wrapper #entity-details [data-element=\'entity-balance-due\'] {\\n        background-color: #e6e6e6;\\n    }\\n\\n    .entity-label {\\n        padding-left: 1rem;\\n    }\\n\\n    #entity-details {\\n        text-align: left;\\n        width: 100%;\\n    }\\n\\n    #entity-details th {\\n        font-weight: normal;\\n        line-height: 1.5rem;\\n        padding-left: 1rem;\\n    }\\n\\n    #client-details {\\n        display: flex;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    #shipping-details {\\n        opacity: $show_shipping_address_visibility;\\n        flex-direction: column;\\n        line-height: var(--line-height);\\n    }\\n\\n    [data-ref=\\\"table\\\"] {\\n        margin-top: 2rem;\\n        min-width: 100%;\\n        table-layout: fixed;\\n        overflow-wrap: break-word;\\n        page-break-inside: auto;\\n    }\\n\\n    .task-time-details {\\n        display: block;\\n        margin-top: 5px;\\n        color: grey;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead {\\n        text-align: left;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>thead>tr>th {\\n        padding: 1rem;\\n        background-color: #f5f5f5;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr>td {\\n        border-bottom: 1px solid #e6e6e6;\\n        padding: 0.75rem;\\n    }\\n\\n    td.left-radius {\\n        padding-left: 1rem !important;\\n    }\\n\\n    th.right-radius {\\n        text-align: right !important;\\n    }\\n\\n    td.right-radius {\\n        text-align: right !important;\\n    }\\n\\n    [data-ref=\\\"table\\\"]>tbody>tr:nth-child(even) {\\n        background-color: #f5f5f5;\\n    }\\n\\n    #table-totals {\\n        margin-top: 0.5rem;\\n        display: grid;\\n        grid-template-columns: 1.5fr 1fr;\\n        padding-top: .5rem;\\n        gap: 80px;\\n        page-break-inside: auto;\\n        overflow: visible !important;\\n        font-weight: bold;\\n        line-height: var(--line-height);\\n\\n    }\\n\\n    #table-totals .totals-table-right-side>* {\\n        display: grid;\\n        grid-template-columns: 1fr 1fr;\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(1) {\\n        text-align: left;\\n        margin-top: .25rem;\\n        padding-left: 7px;\\n\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :not([hidden])~ :not([hidden]) {\\n        --tw-space-y-reverse: 0;\\n        margin-top: calc(.25rem * calc(1 - var(--tw-space-y-reverse)));\\n        margin-bottom: calc(.25rem * var(--tw-space-y-reverse));\\n    }\\n\\n    #table-totals>.totals-table-right-side>*> :nth-child(2) {\\n        text-align: right;\\n        padding-right: 0.75rem;\\n    }\\n\\n    #table-totals>* [data-element=\'total-table-balance-due-label\'],\\n    #table-totals>* [data-element=\'total-table-balance-due\'] {\\n        font-weight: bold;\\n    }\\n\\n    #table-totals>*> :last-child {\\n        text-align: right;\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"total_table-footer\\\"] {\\n        padding-right: 1rem;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        color: var(--primary-color)\\n    }\\n\\n    \\/** Markdown-specific styles. **\\/\\n    [data-ref=\\\"table\\\"] h3 {\\n        font-size: 1rem;\\n        margin-bottom: 0;\\n    }\\n\\n    [data-ref=\\\"totals_table-outstanding-label\\\"],\\n    [data-ref=\\\"totals_table-outstanding\\\"] {\\n        background-color: #e6e6e6;\\n        color: black;\\n        padding-top: 7px;\\n        padding-bottom: 7px;\\n        padding-right: 7px;\\n    }\\n\\n    [data-ref=\\\"statement-totals\\\"] {\\n        margin-top: 1rem;\\n        text-align: right;\\n        margin-right: .75rem;\\n    }\\n\\n    [data-ref*=\\\".line_total-td\\\"] {\\n        white-space: nowrap;\\n    }\\n\\n    .repeating-footer,\\n    .repeating-footer-space {\\n        height: 250px;\\n    }\\n\\n    .repeating-header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    .repeating-footer {\\n        position: fixed;\\n        bottom: 0;\\n\\n    }\\n\\n    #header {\\n        position: fixed;\\n        top: 0;\\n    }\\n\\n    #footer {\\n        position: fixed;\\n        bottom: 0;\\n        border-top: 1px solid #000;\\n        width: 82%;\\n        min-height: 100px;\\n        padding-top: 0.5rem;\\n        margin-top: 40px;\\n    }\\n\\n    [data-ref=\'product_table-product.description-th\'] {\\n        width: 35%;\\n        overflow-wrap: break-word;\\n    }\\n\\n    [data-ref=\\\"total_table-public_notes\\\"] {\\n        font-weight: normal;\\n    }\\n\\n    [data-ref=\\\"total_table-terms\\\"] {\\n        font-weight: normal;\\n    }\\n\\n    \\/* [data-ref=\\\"shipping_address-label\\\"] {\\n        display: none;\\n    } *\\/\\n\\n    .stamp {\\n        transform: rotate(12deg);\\n        color: #555;\\n        font-size: 3rem;\\n        font-weight: 700;\\n        border: 0.25rem solid #555;\\n        display: inline-block;\\n        padding: 0.25rem 1rem;\\n        text-transform: uppercase;\\n        border-radius: 1rem;\\n        font-family: \'Courier\';\\n        mix-blend-mode: multiply;\\n        z-index: 200 !important;\\n        position: fixed;\\n        text-align: center;\\n    }\\n\\n    .is-paid {\\n        color: #D23;\\n        border: 1rem double #D23;\\n        transform: rotate(-5deg);\\n        font-size: 6rem;\\n        font-family: \\\"Open sans\\\", Helvetica, Arial, sans-serif;\\n        border-radius: 0;\\n        padding: 0.5rem;\\n        opacity: 0.2;\\n        z-index: 200 !important;\\n        position: fixed;\\n        display: $show_paid_stamp;\\n    }\\n\\n    .project-header {\\n        font-size: 1.2em;\\n        margin-top: 0.1em;\\n        margin-bottom: 0;\\n        padding-bottom: 0;\\n        margin-left: 0;\\n        margin-right: 0;\\n        font-weight: bold;\\n        color: #505050;\\n    }\\n\\n    .pqrcode {}\\n\\n    #qr-bill {\\n        width: 100% !important;\\n    }\\n\\n    \\/** Useful snippets, uncomment to enable. **\\/\\n\\n    \\/** Hide company logo **\\/\\n    \\/* .company-logo { display: none } *\\/\\n\\n    \\/* Hide company details *\\/\\n    \\/* # > * { display: none } *\\/\\n\\n    \\/* Hide company address *\\/\\n    \\/* #company-address > * { display: none } *\\/\\n\\n    \\/* Hide terms label *\\/\\n    \\/* [data-ref=\\\"total_table-terms-label\\\"] { display: none } *\\/\\n\\n    \\/* Hide totals table *\\/\\n    \\/* #table-totals { display: none } *\\/\\n\\n    \\/* Hide totals table left side *\\/\\n    \\/* #table-totals div:first-child > * { display: none !important } *\\/\\n\\n    \\/* Hide totals table right side *\\/\\n    \\/* .totals-table-right-side { display: none } *\\/\\n\\n    \\/** For more info, please check our docs: https:\\/\\/invoiceninja.github.io **\\/\\n    \\/** To find out selectors on your own: https:\\/\\/invoiceninja.github.io\\/docs\\/custom-fields\\/#snippets **\\/\\n<\\/style>\\n\",\"header\":\"<div class=\\\"repeating-header\\\" id=\\\"header\\\"><\\/div>\\n\",\"body\":\"<div id=\\\"body\\\">\\n    <table style=\\\"min-width: 100%\\\">\\n        <thead>\\n            <tr>\\n                <td>\\n                    <div class=\\\"repeating-header-space\\\">&#xA0;<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/thead>\\n        <tbody>\\n            <tr>\\n                <td>\\n                    <div id=\\\"\\\">\\n                        <div class=\\\"header-wrapper\\\">\\n                            <div class=\\\"logo-container\\\">\\n                                <img class=\\\"company-logo\\\" src=\\\"$company.logo\\\" alt=\\\"$company.name logo\\\">\\n                            <\\/div>\\n                            <div id=\\\"company-details\\\"><\\/div>\\n                            <div id=\\\"company-address\\\"><\\/div>\\n                        <\\/div>\\n                        <div class=\\\"header-wrapper2\\\">\\n                            <div id=\\\"client-details\\\"><\\/div>\\n                            <div id=\\\"vendor-details\\\"><\\/div>\\n                            <div id=\\\"shipping-details\\\"><\\/div>\\n                            <div class=\\\"entity-container\\\">\\n                                <p class=\\\"entity-label\\\" style=\\\"font-size:32px; font-weight: bold; color:$primary_color;\\\">$entity_label<\\/p>\\n                                <table id=\\\"entity-details\\\" cellspacing=\\\"0\\\" cellpadding=\\\"0\\\" dir=\\\"ltr\\\"><\\/table>\\n                            <\\/div>\\n                        <\\/div>\\n\\n                        <table id=\\\"product-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"task-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"delivery-note-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <table id=\\\"statement-invoice-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-invoice-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-payment-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-payment-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-credit-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-credit-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <table id=\\\"statement-aging-table\\\" cellspacing=\\\"0\\\" data-ref=\\\"table\\\"><\\/table>\\n                        <div id=\\\"statement-aging-table-totals\\\" data-ref=\\\"statement-totals\\\"><\\/div>\\n                        <div id=\\\"table-totals\\\" cellspacing=\\\"0\\\">$status_logo<\\/div>\\n                    <\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tbody>\\n        <tfoot>\\n            <tr>\\n                <td>\\n                    <div class=\\\"repeating-footer-space\\\">&#xA0;<\\/div>\\n                <\\/td>\\n            <\\/tr>\\n        <\\/tfoot>\\n    <\\/table>\\n<\\/div>\\n\",\"product\":\"\",\"task\":\"\",\"footer\":\"<div id=\\\"footer\\\" style=\\\"\\\">\\n    <div style=\\\"width: 100%;\\\">\\n        <p data-ref=\\\"total_table-footer\\\">$entity_footer<\\/p>\\n\\n    <\\/div>\\n<\\/div>\\n\"}',0,'2026-09-16 07:56:52.461110','2026-09-16 07:56:52.484431',NULL,0,NULL);
/*!40000 ALTER TABLE `designs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `url` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preview` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `disk` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hash` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` int unsigned DEFAULT NULL,
  `width` int unsigned DEFAULT NULL,
  `height` int unsigned DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `documentable_id` int unsigned NOT NULL,
  `documentable_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `documents_company_id_index` (`company_id`),
  KEY `documents_documentable_id_documentable_type_deleted_at_index` (`documentable_id`,`documentable_type`,`deleted_at`),
  CONSTRAINT `documents_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `e_invoicing_logs`
--

DROP TABLE IF EXISTS `e_invoicing_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_invoicing_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `legal_entity_id` int unsigned NOT NULL,
  `license_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direction` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sent',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `counter` int NOT NULL DEFAULT '0',
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `e_invoicing_logs_legal_entity_id_index` (`legal_entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `e_invoicing_logs`
--

LOCK TABLES `e_invoicing_logs` WRITE;
/*!40000 ALTER TABLE `e_invoicing_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `e_invoicing_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `e_invoicing_tokens`
--

DROP TABLE IF EXISTS `e_invoicing_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_invoicing_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `license` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_key` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `e_invoicing_tokens_token_unique` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `e_invoicing_tokens`
--

LOCK TABLES `e_invoicing_tokens` WRITE;
/*!40000 ALTER TABLE `e_invoicing_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `e_invoicing_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_categories`
--

DROP TABLE IF EXISTS `expense_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_categories` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `company_id` int unsigned NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `color` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#fff',
  `bank_category_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `expense_categories_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `expense_categories_company_id_index` (`company_id`),
  CONSTRAINT `expense_categories_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_categories`
--

LOCK TABLES `expense_categories` WRITE;
/*!40000 ALTER TABLE `expense_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `expense_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `bank_id` int unsigned DEFAULT NULL,
  `invoice_currency_id` int unsigned DEFAULT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `payment_type_id` int unsigned DEFAULT NULL,
  `recurring_expense_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `amount` decimal(20,6) NOT NULL,
  `foreign_amount` decimal(20,6) NOT NULL,
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `date` date DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `transaction_reference` text COLLATE utf8mb4_unicode_ci,
  `should_be_invoiced` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_documents` tinyint(1) NOT NULL DEFAULT '1',
  `transaction_id` bigint unsigned DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `tax_amount1` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `tax_amount2` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `tax_amount3` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `calculate_tax_by_amount` tinyint(1) NOT NULL DEFAULT '0',
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `expenses_company_id_number_unique` (`company_id`,`number`),
  KEY `expenses_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `expenses_user_id_foreign` (`user_id`),
  KEY `expenses_company_id_index` (`company_id`),
  KEY `expenses_invoice_id_deleted_at_index` (`invoice_id`,`deleted_at`),
  CONSTRAINT `expenses_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `expenses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gateway_types`
--

DROP TABLE IF EXISTS `gateway_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gateway_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `alias` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gateway_types`
--

LOCK TABLES `gateway_types` WRITE;
/*!40000 ALTER TABLE `gateway_types` DISABLE KEYS */;
INSERT INTO `gateway_types` VALUES (1,'credit_card','Credit Card'),(2,'bank_transfer','Bank Transfer'),(3,'paypal','PayPal'),(4,'crypto','Crypto'),(5,'dwolla','Dwolla'),(6,'custom1','Custom'),(7,'alipay','Alipay'),(8,'sofort','Sofort'),(9,'sepa','SEPA'),(10,'gocardless','GoCardless'),(11,'apple_pay','Apple Pay'),(12,'custom2','Custom'),(13,'custom3','Custom'),(14,'credit','Credit');
/*!40000 ALTER TABLE `gateway_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gateways`
--

DROP TABLE IF EXISTS `gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gateways` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int unsigned NOT NULL DEFAULT '10000',
  `site_url` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_offsite` tinyint(1) NOT NULL DEFAULT '0',
  `is_secure` tinyint(1) NOT NULL DEFAULT '0',
  `fields` longtext COLLATE utf8mb4_unicode_ci,
  `default_gateway_type_id` int unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `gateways_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gateways`
--

LOCK TABLES `gateways` WRITE;
/*!40000 ALTER TABLE `gateways` DISABLE KEYS */;
INSERT INTO `gateways` VALUES (1,'Authorize.Net','3b6621f970ab18887c4f6dca78d3f8bb','Authorize',1,5,'http://reseller.authorize.net/application/?id=5560364',0,0,'\"{\\\"apiLoginId\\\":\\\"\\\",\\\"transactionKey\\\":\\\"\\\",\\\"testMode\\\":false,\\\"developerMode\\\":false,\\\"liveEndpoint\\\":\\\"https:\\\\\\/\\\\\\/api2.authorize.net\\\\\\/xml\\\\\\/v1\\\\\\/request.api\\\",\\\"developerEndpoint\\\":\\\"https:\\\\\\/\\\\\\/apitest.authorize.net\\\\\\/xml\\\\\\/v1\\\\\\/request.api\\\"}\\n\"',1,'2026-09-16 07:56:51.336928','2026-09-16 07:56:51.404262'),(2,'CardSave','46c5c1fed2c43acf4f379bae9c8b9f76','CardSave',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"password\\\":\\\"\\\"}\\n\"',1,'2026-09-16 07:56:51.338190','2026-09-16 07:56:51.405484'),(3,'Eway Rapid','944c20175bbe6b9972c05bcfe294c2c7','Eway',1,10000,'',1,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"publicApiKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.339687','2026-09-16 07:56:51.406568'),(4,'FirstData Connect','4e0ed0d34552e6cb433506d1ac03a418','FirstData_Connect',0,10000,'',0,0,'\"{\\\"storeId\\\":\\\"\\\",\\\"sharedSecret\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.340931','2026-09-16 07:56:51.407623'),(5,'Migs ThreeParty','513cdc81444c87c4b07258bc2858d3fa','Migs_ThreeParty',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"merchantAccessCode\\\":\\\"\\\",\\\"secureHash\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.342355','2026-09-16 07:56:51.408510'),(6,'Migs TwoParty','99c2a271b5088951334d1302e038c01a','Migs_TwoParty',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"merchantAccessCode\\\":\\\"\\\",\\\"secureHash\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.343639','2026-09-16 07:56:51.409400'),(7,'Mollie','1bd651fb213ca0c9d66ae3c336dc77e8','Mollie',1,8,'',1,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"profileId\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.344691','2026-09-16 07:56:51.410219'),(8,'MultiSafepay','c3dec814e14cbd7d86abd92ce6789f8c','MultiSafepay',0,10000,'',0,0,'\"{\\\"accountId\\\":\\\"\\\",\\\"siteId\\\":\\\"\\\",\\\"siteCode\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.346514','2026-09-16 07:56:51.411140'),(9,'Netaxept','070dffc5ca94f4e66216e44028ebd52d','Netaxept',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.347624','2026-09-16 07:56:51.412009'),(10,'NetBanx','334d419939c06bd99b4dfd8a49243f0f','NetBanx',0,10000,'',0,0,'\"{\\\"accountNumber\\\":\\\"\\\",\\\"storeId\\\":\\\"\\\",\\\"storePassword\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.348594','2026-09-16 07:56:51.412681'),(11,'PayFast','d6814fc83f45d2935e7777071e629ef9','PayFast',1,10000,'',1,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"merchantKey\\\":\\\"\\\",\\\"pdtKey\\\":\\\"\\\",\\\"passphrase\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.349552','2026-09-16 07:56:51.413270'),(12,'Payflow Pro','0d97c97d227f91c5d0cb86d01e4a52c9','Payflow_Pro',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"vendor\\\":\\\"\\\",\\\"partner\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.351054','2026-09-16 07:56:51.414121'),(13,'PaymentExpress PxPay','a66b7062f4c8212d2c428209a34aa6bf','PaymentExpress_PxPay',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"pxPostUsername\\\":\\\"\\\",\\\"pxPostPassword\\\":\\\"\\\",\\\"testMode\\\":false}\"',3,'2026-09-16 07:56:51.352249','2026-09-16 07:56:51.414707'),(14,'PaymentExpress PxPost','7e6fc08b89467518a5953a4839f8baba','PaymentExpress_PxPost',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"testMode\\\":false}\"',3,'2026-09-16 07:56:51.353107','2026-09-16 07:56:51.415298'),(15,'PayPal Express','38f2c48af60c7dd69e04248cbb24c36e','PayPal_Express',1,4,'https://www.paypal.com/us/cgi-bin/webscr?cmd=_login-api-run',1,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"signature\\\":\\\"\\\",\\\"testMode\\\":false,\\\"solutionType\\\":[\\\"Sole\\\",\\\"Mark\\\"],\\\"landingPage\\\":[\\\"Billing\\\",\\\"Login\\\"],\\\"brandName\\\":\\\"\\\",\\\"headerImageUrl\\\":\\\"\\\",\\\"logoImageUrl\\\":\\\"\\\",\\\"borderColor\\\":\\\"\\\"}\"',3,'2026-09-16 07:56:51.354301','2026-09-16 07:56:51.416038'),(16,'PayPal Pro','80af24a6a69f5c0bbec33e930ab40665','PayPal_Pro',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"signature\\\":\\\"\\\",\\\"testMode\\\":false}\"',3,'2026-09-16 07:56:51.355713','2026-09-16 07:56:51.416597'),(17,'Pin','0749cb92a6b36c88bd9ff8aabd2efcab','Pin',0,10000,'',0,0,'\"{\\\"secretKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.356835','2026-09-16 07:56:51.417237'),(18,'SagePay Direct','4c8f4e5d0f353a122045eb9a60cc0f2d','SagePay_Direct',0,10000,'https://applications.sagepay.com/apply/2C02C252-0F8A-1B84-E10D-CF933EFCAA99',0,0,'\"{\\\"vendor\\\":\\\"\\\",\\\"testMode\\\":false,\\\"referrerId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.357682','2026-09-16 07:56:51.417814'),(19,'SecurePay DirectPost','8036a5aadb2bdaafb23502da8790b6a2','SecurePay_DirectPost',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"transactionPassword\\\":\\\"\\\",\\\"testMode\\\":false,\\\"enable_ach\\\":\\\"\\\",\\\"enable_sofort\\\":\\\"\\\",\\\"enable_apple_pay\\\":\\\"\\\",\\\"enable_alipay\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.358706','2026-09-16 07:56:51.418697'),(20,'Stripe','d14dd26a37cecc30fdd65700bfb55b23','Stripe',1,1,'https://dashboard.stripe.com/account/apikeys',0,0,'\"{\\\"publishableKey\\\":\\\"\\\",\\\"apiKey\\\":\\\"\\\",\\\"appleDomainVerification\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.359852','2026-09-16 07:56:51.419479'),(21,'TargetPay Direct eBanking','d14dd26a37cdcc30fdd65700bfb55b23','TargetPay_Directebanking',0,10000,'',0,0,'\"{\\\"subAccountId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.360751','2026-09-16 07:56:51.420249'),(22,'TargetPay Ideal','ea3b328bd72d381387281c3bd83bd97c','TargetPay_Ideal',0,10000,'',0,0,'\"{\\\"subAccountId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.361700','2026-09-16 07:56:51.421123'),(23,'TargetPay Mr Cash','a0035fc0d87c4950fb82c73e2fcb825a','TargetPay_Mrcash',0,10000,'',0,0,'\"{\\\"subAccountId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.362741','2026-09-16 07:56:51.422002'),(24,'TwoCheckout','16dc1d3c8a865425421f64463faaf768','TwoCheckout',0,10000,'https://www.2checkout.com/referral?r=2c37ac2298',1,0,'\"{\\\"accountNumber\\\":\\\"\\\",\\\"secretWord\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.363774','2026-09-16 07:56:51.422730'),(25,'WorldPay','43e639234f660d581ddac725ba7bcd29','WorldPay',0,10000,'',0,0,'\"{\\\"installationId\\\":\\\"\\\",\\\"accountId\\\":\\\"\\\",\\\"secretWord\\\":\\\"\\\",\\\"callbackPassword\\\":\\\"\\\",\\\"testMode\\\":false,\\\"noLanguageMenu\\\":false,\\\"fixContact\\\":false,\\\"hideContact\\\":false,\\\"hideCurrency\\\":false,\\\"signatureFields\\\":\\\"instId:amount:currency:cartId\\\"}\"',1,'2026-09-16 07:56:51.364746','2026-09-16 07:56:51.423394'),(26,'moolah','2f71dc17b0158ac30a7ae0839799e888','AuthorizeNet_AIM',0,10000,'',0,0,'\"{\\\"apiLoginId\\\":\\\"\\\",\\\"transactionKey\\\":\\\"\\\",\\\"testMode\\\":false,\\\"developerMode\\\":false,\\\"liveEndpoint\\\":\\\"https:\\\\\\/\\\\\\/api2.authorize.net\\\\\\/xml\\\\\\/v1\\\\\\/request.api\\\",\\\"developerEndpoint\\\":\\\"https:\\\\\\/\\\\\\/apitest.authorize.net\\\\\\/xml\\\\\\/v1\\\\\\/request.api\\\"}\"',1,'2026-09-16 07:56:51.365648','2026-09-16 07:56:51.424037'),(27,'Alipay','733998ee4760b10f11fb48652571e02c','Alipay_Express',0,10000,'',0,0,'\"{\\\"partner\\\":\\\"\\\",\\\"key\\\":\\\"\\\",\\\"signType\\\":\\\"MD5\\\",\\\"inputCharset\\\":\\\"utf-8\\\",\\\"transport\\\":\\\"http\\\",\\\"paymentType\\\":1,\\\"itBPay\\\":\\\"1d\\\"}\"',1,'2026-09-16 07:56:51.366522','2026-09-16 07:56:51.424741'),(28,'Buckaroo','6312879223e49c5cf92e194646bdee8f','Buckaroo_CreditCard',0,10000,'',0,0,'\"{\\\"websiteKey\\\":\\\"\\\",\\\"secretKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.367483','2026-09-16 07:56:51.425275'),(29,'Coinbase','106ef7e7da9062b0df363903b455711c','Coinbase',0,10000,'',1,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"secret\\\":\\\"\\\",\\\"accountId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.368831','2026-09-16 07:56:51.425757'),(30,'DataCash','e9a38f0896b5b82d196be3b7020c8664','DataCash',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.369697','2026-09-16 07:56:51.426240'),(31,'Pacnet','0da4e18ed44a5bd5c8ec354d0ab7b301','Pacnet',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"sharedSecret\\\":\\\"\\\",\\\"paymentRoutingNumber\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.370420','2026-09-16 07:56:51.427030'),(32,'Realex','d3979e62eb603fbdf1c78fe3a8ba7009','Realex_Remote',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"account\\\":\\\"\\\",\\\"secret\\\":\\\"\\\",\\\"3dSecure\\\":0}\"',1,'2026-09-16 07:56:51.371430','2026-09-16 07:56:51.427686'),(33,'Sisow','557d98977e7ec02dfa53de4b69b335be','Sisow',0,10000,'',0,0,'\"{\\\"shopId\\\":\\\"\\\",\\\"merchantId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.372297','2026-09-16 07:56:51.428384'),(34,'Skrill','54dc60c869a7322d87efbec5c0c25805','Skrill',0,10000,'',1,0,'\"{\\\"email\\\":\\\"\\\",\\\"notifyUrl\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.373054','2026-09-16 07:56:51.429266'),(35,'BitPay','e4a02f0a4b235eb5e9e294730703bb74','BitPay',0,7,'https://bitpay.com/dashboard/signup',1,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.374057','2026-09-16 07:56:51.429881'),(36,'AGMS','1b3c6f3ccfea4f5e7eadeae188cccd7f','Agms',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"apiKey\\\":\\\"\\\",\\\"accountNumber\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.375123','2026-09-16 07:56:51.430411'),(37,'Barclays','7cba6ce5c125f9cb47ea8443ae671b68','BarclaysEpdq\\Essential',0,10000,'',0,0,'\"{\\\"clientId\\\":\\\"\\\",\\\"testMode\\\":false,\\\"language\\\":\\\"en_US\\\",\\\"callbackMethod\\\":\\\"POST\\\"}\"',1,'2026-09-16 07:56:51.375892','2026-09-16 07:56:51.431158'),(38,'Cardgate','b98cfa5f750e16cee3524b7b7e78fbf6','Cardgate',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"language\\\":\\\"nl\\\",\\\"apiKey\\\":\\\"\\\",\\\"siteId\\\":\\\"\\\",\\\"notifyUrl\\\":\\\"\\\",\\\"returnUrl\\\":\\\"\\\",\\\"cancelUrl\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.376796','2026-09-16 07:56:51.431658'),(39,'Checkout.com','3758e7f7c6f4cecf0f4f348b9a00f456','CheckoutCom',1,10000,'',0,0,'\"{\\\"secretApiKey\\\":\\\"\\\",\\\"publicApiKey\\\":\\\"\\\",\\\"testMode\\\":false,\\\"threeds\\\":false}\"',1,'2026-09-16 07:56:51.377721','2026-09-16 07:56:51.432541'),(40,'Creditcall','cbc7ef7c99d31ec05492fbcb37208263','Creditcall',0,10000,'',0,0,'\"{\\\"terminalId\\\":\\\"\\\",\\\"transactionKey\\\":\\\"\\\",\\\"testMode\\\":false,\\\"verifyCvv\\\":true,\\\"verifyAddress\\\":false,\\\"verifyZip\\\":false}\"',1,'2026-09-16 07:56:51.378750','2026-09-16 07:56:51.433122'),(41,'Cybersource','e186a98d3b079028a73390bdc11bdb82','Cybersource',0,10000,'',0,0,'\"{\\\"profileId\\\":\\\"\\\",\\\"secretKey\\\":\\\"\\\",\\\"accessKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.379682','2026-09-16 07:56:51.433939'),(42,'ecoPayz','761040aca40f685d1ab55e2084b30670','Ecopayz',0,10000,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"merchantPassword\\\":\\\"\\\",\\\"merchantAccountNumber\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.380520','2026-09-16 07:56:51.434724'),(43,'Fasapay','1b2cef0e8c800204a29f33953aaf3360','Fasapay',0,10000,'',0,0,'\"\"',1,'2026-09-16 07:56:51.381417','2026-09-16 07:56:51.435442'),(44,'Komoju','7ea2d40ecb1eb69ef8c3d03e5019028a','Komoju',0,10000,'',0,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"accountId\\\":\\\"\\\",\\\"paymentMethod\\\":\\\"credit_card\\\",\\\"testMode\\\":false,\\\"locale\\\":\\\"en\\\"}\"',1,'2026-09-16 07:56:51.382814','2026-09-16 07:56:51.436248'),(45,'Paysafecard','70ab90cd6c5c1ab13208b3cef51c0894','Paysafecard',0,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.383798','2026-09-16 07:56:51.436936'),(46,'Paytrace','bbd736b3254b0aabed6ad7fda1298c88','Paytrace',1,10000,'',0,0,'\"{\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"integratorId\\\":\\\"\\\",\\\"testMode\\\":false,\\\"endpoint\\\":\\\"https:\\\\\\/\\\\\\/paytrace.com\\\\\\/api\\\\\\/default.pay\\\"}\"',1,'2026-09-16 07:56:51.384494','2026-09-16 07:56:51.437763'),(47,'Secure Trading','231cb401487b9f15babe04b1ac4f7a27','SecureTrading',0,10000,'',0,0,'\"{\\\"siteReference\\\":\\\"\\\",\\\"username\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"applyThreeDSecure\\\":false,\\\"accountType\\\":\\\"ECOM\\\"}\"',1,'2026-09-16 07:56:51.385329','2026-09-16 07:56:51.438632'),(48,'SecPay','bad8699d581d9fa040e59c0bb721a76c','SecPay',0,10000,'',0,0,'\"{\\\"mid\\\":\\\"\\\",\\\"vpnPswd\\\":\\\"\\\",\\\"remotePswd\\\":\\\"\\\",\\\"usageType\\\":\\\"\\\",\\\"confirmEmail\\\":\\\"\\\",\\\"testStatus\\\":\\\"true\\\",\\\"mailCustomer\\\":\\\"true\\\",\\\"additionalOptions\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.386044','2026-09-16 07:56:51.439373'),(49,'WePay','8fdeed552015b3c7b44ed6c8ebd9e992','WePay',0,3,'',0,0,'\"{\\\"accountId\\\":\\\"\\\",\\\"accessToken\\\":\\\"\\\",\\\"type\\\":\\\"goods\\\",\\\"testMode\\\":false,\\\"feePayer\\\":\\\"payee\\\"}\"',1,'2026-09-16 07:56:51.387011','2026-09-16 07:56:51.440051'),(50,'Braintree','f7ec488676d310683fb51802d076d713','Braintree',1,3,'',0,0,'\"{\\\"merchantId\\\":\\\"\\\",\\\"merchantAccountId\\\":\\\"\\\",\\\"publicKey\\\":\\\"\\\",\\\"privateKey\\\":\\\"\\\",\\\"testMode\\\":false,\\\"threeds\\\":false}\"',1,'2026-09-16 07:56:51.387905','2026-09-16 07:56:51.440749'),(51,'FirstData Payeezy','30334a52fb698046572c627ca10412e8','FirstData_Payeezy',0,10000,'',0,0,'\"{\\\"gatewayId\\\":\\\"\\\",\\\"password\\\":\\\"\\\",\\\"keyId\\\":\\\"\\\",\\\"hmac\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.388788','2026-09-16 07:56:51.441563'),(52,'GoCardless','b9886f9257f0c6ee7c302f1c74475f6c','GoCardless',1,9,'',1,0,'\"{\\\"accessToken\\\":\\\"\\\",\\\"webhookSecret\\\":\\\"\\\", \\\"verifyBankAccount\\\":false, \\\"testMode\\\":true}\"',1,'2026-09-16 07:56:51.389691','2026-09-16 07:56:51.442439'),(53,'PagSeguro','ef498756b54db63c143af0ec433da803','PagSeguro',0,10000,'',0,0,'\"{\\\"email\\\":\\\"\\\",\\\"token\\\":\\\"\\\",\\\"sandbox\\\":false}\"',1,'2026-09-16 07:56:51.390655','2026-09-16 07:56:51.443336'),(54,'PAYMILL','ca52f618a39367a4c944098ebf977e1c','Paymill',0,10000,'',0,0,'\"{\\\"apiKey\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.391642','2026-09-16 07:56:51.444023'),(55,'Custom','54faab2ab6e3223dbe848b1686490baa','Custom',1,21,'',1,0,'\"{\\\"name\\\":\\\"\\\",\\\"text\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.392430','2026-09-16 07:56:51.444621'),(57,'Square','65faab2ab6e3223dbe848b1686490baz','Square',1,21,'',0,0,'\"{\\\"accessToken\\\":\\\"\\\",\\\"applicationId\\\":\\\"\\\",\\\"locationId\\\":\\\"\\\",\\\"signatureKey\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.393228','2026-09-16 07:56:51.445257'),(58,'Razorpay','hxd6gwg3ekb9tb3v9lptgx1mqyg69zu9','Razorpay',1,21,'',0,0,'\"{\\\"apiKey\\\":\\\"\\\",\\\"apiSecret\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.393990','2026-09-16 07:56:51.446009'),(59,'Forte','kivcvjexxvdiyqtj3mju5d6yhpeht2xs','Forte',1,21,'https://www.forte.net/',0,0,'\"{\\\"testMode\\\":false,\\\"apiLoginId\\\":\\\"\\\",\\\"apiAccessId\\\":\\\"\\\",\\\"secureKey\\\":\\\"\\\",\\\"authOrganizationId\\\":\\\"\\\",\\\"organizationId\\\":\\\"\\\",\\\"locationId\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.394946','2026-09-16 07:56:51.446719'),(60,'PayPal REST','80af24a6a691230bbec33e930ab40665','PayPal_Rest',1,10000,'https://www.paypal.com/us/cgi-bin/webscr?cmd=_login-api-run',0,0,'\"{\\\"clientId\\\":\\\"\\\",\\\"secret\\\":\\\"\\\",\\\"signature\\\":\\\"\\\",\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.395886','2026-09-16 07:56:51.447885'),(61,'PayPal Platform','80af24a6a691230bbec33e930ab40666','PayPal_PPCP',0,10000,'https://www.paypal.com/us/cgi-bin/webscr?cmd=_login-api-run',0,0,'\"{\\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.396616','2026-09-16 07:56:51.448660'),(62,'BTCPay','vpyfbmdrkqcicpkjqdusgjfluebftuva','BTCPay',1,10000,'https://docs.btcpayserver.org/InvoiceNinja/',0,0,'\"{\\\"btcpayUrl\\\":\\\"\\\", \\\"apiKey\\\":\\\"\\\", \\\"storeId\\\":\\\"\\\", \\\"webhookSecret\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.397411','2026-09-16 07:56:51.449269'),(63,'Rotessa','91be24c7b792230bced33e930ac61676','Rotessa',1,22,'https://rotessa.com',0,0,'\"{\\\"apiKey\\\":\\\"\\\", \\\"testMode\\\":false}\"',1,'2026-09-16 07:56:51.398187','2026-09-16 07:56:51.450025'),(64,'CBA PowerBoard','b67581d804dbad1743b61c57285142ad','CBAPowerBoard',1,26,'',0,0,'\"{\\\"publicKey\\\":\\\"\\\", \\\"secretKey\\\":\\\"\\\", \\\"testMode\\\":false, \\\"gatewayId\\\":\\\"\\\", \\\"amex\\\":false, \\\"ausbc\\\":false, \\\"discover\\\":false, \\\"japcb\\\":false, \\\"laser\\\":false, \\\"mastercard\\\":true, \\\"solo\\\":false, \\\"visa\\\":true, \\\"visa_white\\\":false}\"',1,'2026-09-16 07:56:51.398964','2026-09-16 07:56:51.451093'),(65,'Blockonomics','wbhf02us6owgo7p4nfjd0ymssdshks4d','Blockonomics',1,27,'https://help.blockonomics.co/a/solutions/articles/33000291849',0,0,'\"{\\\"apiKey\\\":\\\"\\\"}\"',1,'2026-09-16 07:56:51.399689','2026-09-16 07:56:51.452047');
/*!40000 ALTER TABLE `gateways` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_settings`
--

DROP TABLE IF EXISTS `group_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `settings` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `group_settings_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  CONSTRAINT `group_settings_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_settings`
--

LOCK TABLES `group_settings` WRITE;
/*!40000 ALTER TABLE `group_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `industries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industries`
--

LOCK TABLES `industries` WRITE;
/*!40000 ALTER TABLE `industries` DISABLE KEYS */;
INSERT INTO `industries` VALUES (1,'Accounting & Legal'),(2,'Advertising'),(3,'Aerospace'),(4,'Agriculture'),(5,'Automotive'),(6,'Banking & Finance'),(7,'Biotechnology'),(8,'Broadcasting'),(9,'Business Services'),(10,'Commodities & Chemicals'),(11,'Communications'),(12,'Computers & Hightech'),(13,'Defense'),(14,'Energy'),(15,'Entertainment'),(16,'Government'),(17,'Healthcare & Life Sciences'),(18,'Insurance'),(19,'Manufacturing'),(20,'Marketing'),(21,'Media'),(22,'Nonprofit & Higher Ed'),(23,'Pharmaceuticals'),(24,'Professional Services & Consulting'),(25,'Real Estate'),(26,'Retail & Wholesale'),(27,'Sports'),(28,'Transportation'),(29,'Travel & Luxury'),(30,'Other'),(31,'Photography'),(32,'Construction'),(33,'Restaurant & Catering');
/*!40000 ALTER TABLE `industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_invitations`
--

DROP TABLE IF EXISTS `invoice_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_invitations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `client_contact_id` int unsigned NOT NULL,
  `invoice_id` int unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `signature_ip` text COLLATE utf8mb4_unicode_ci,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_invitations_client_contact_id_invoice_id_unique` (`client_contact_id`,`invoice_id`),
  KEY `invoice_invitations_user_id_foreign` (`user_id`),
  KEY `invoice_invitations_company_id_foreign` (`company_id`),
  KEY `invoice_invitations_deleted_at_invoice_id_company_id_index` (`deleted_at`,`invoice_id`,`company_id`),
  KEY `invoice_invitations_invoice_id_index` (`invoice_id`),
  KEY `invoice_invitations_message_id_index` (`message_id`),
  KEY `invoice_invitations_key_deleted_at_index` (`key`,`deleted_at`),
  CONSTRAINT `invoice_invitations_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoice_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoice_invitations_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoice_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_invitations`
--

LOCK TABLES `invoice_invitations` WRITE;
/*!40000 ALTER TABLE `invoice_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `status_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `recurring_id` int unsigned DEFAULT NULL,
  `design_id` int unsigned DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `last_sent_date` date DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `next_send_date` datetime DEFAULT NULL,
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `amount` decimal(20,6) NOT NULL,
  `balance` decimal(20,6) NOT NULL,
  `partial` decimal(20,6) DEFAULT NULL,
  `partial_due_date` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `reminder1_sent` date DEFAULT NULL,
  `reminder2_sent` date DEFAULT NULL,
  `reminder3_sent` date DEFAULT NULL,
  `reminder_last_sent` date DEFAULT NULL,
  `auto_bill_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `subscription_id` int unsigned DEFAULT NULL,
  `auto_bill_tries` smallint NOT NULL DEFAULT '0',
  `is_proforma` tinyint(1) NOT NULL DEFAULT '0',
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `sync` text COLLATE utf8mb4_unicode_ci,
  `gateway_fee` decimal(13,6) NOT NULL DEFAULT '0.000000',
  `location_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoices_company_id_number_unique` (`company_id`,`number`),
  KEY `invoices_user_id_foreign` (`user_id`),
  KEY `invoices_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `invoices_client_id_index` (`client_id`),
  KEY `invoices_company_id_index` (`company_id`),
  KEY `invoices_recurring_id_index` (`recurring_id`),
  KEY `invoices_status_id_balance_index` (`status_id`,`balance`),
  KEY `invoices_project_id_deleted_at_index` (`project_id`,`deleted_at`),
  KEY `invoices_location_id_foreign` (`location_id`),
  CONSTRAINT `invoices_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoices_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `invoices_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `invoices_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `locale` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'English - United States','en'),(2,'Italian','it'),(3,'German','de'),(4,'French','fr'),(5,'Portuguese - Brazilian','pt_BR'),(6,'Dutch','nl'),(7,'Spanish','es'),(8,'Norwegian','nb_NO'),(9,'Danish','da'),(10,'Japanese','ja'),(11,'Swedish','sv'),(12,'Spanish - Spain','es_ES'),(13,'French - Canada','fr_CA'),(14,'Lithuanian','lt'),(15,'Polish','pl'),(16,'Czech','cs'),(17,'Croatian','hr'),(18,'Albanian','sq'),(19,'Greek','el'),(20,'English - United Kingdom','en_GB'),(21,'Portuguese - Portugal','pt_PT'),(22,'Slovenian','sl'),(23,'Finnish','fi'),(24,'Romanian','ro'),(25,'Turkish - Turkey','tr_TR'),(26,'Thai','th'),(27,'Macedonian','mk_MK'),(28,'Chinese - Taiwan','zh_TW'),(29,'Russian (Russia)','ru_RU'),(30,'Arabic','ar'),(31,'Persian','fa'),(32,'Latvian','lv_LV'),(33,'Serbian','sr'),(34,'Slovak','sk'),(35,'Estonian','et'),(36,'Bulgarian','bg'),(37,'Hebrew','he'),(38,'Khmer','km_KH'),(39,'Hungarian','hu'),(40,'French - Swiss','fr_CH'),(41,'Lao','lo_LA'),(42,'Vietnamese','vi');
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `licenses`
--

DROP TABLE IF EXISTS `licenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `licenses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `first_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `license_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_claimed` tinyint(1) DEFAULT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` int unsigned DEFAULT NULL,
  `recurring_invoice_id` bigint unsigned DEFAULT NULL,
  `e_invoice_quota` int unsigned DEFAULT NULL,
  `is_flagged` tinyint(1) NOT NULL DEFAULT '0',
  `entities` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `licenses_license_key_unique` (`license_key`),
  KEY `licenses_e_invoice_quota_index` (`e_invoice_quota`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `licenses`
--

LOCK TABLES `licenses` WRITE;
/*!40000 ALTER TABLE `licenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `licenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_shipping_location` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `country_id` int unsigned DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `locations_client_id_index` (`client_id`),
  KEY `locations_vendor_id_index` (`vendor_id`),
  KEY `locations_company_id_index` (`company_id`),
  CONSTRAINT `locations_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `locations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `locations_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=281 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2014_10_12_100000_create_password_resets_table',1),(2,'2014_10_13_000000_create_users_table',1),(3,'2019_11_10_115926_create_failed_jobs_table',1),(4,'2020_03_05_123315_create_jobs_table',1),(5,'2020_04_08_234530_add_is_deleted_column_to_company_tokens_table',1),(6,'2020_05_13_035355_add_google_refresh_token_to_users_table',1),(7,'2020_07_05_084934_company_too_large_attribute',1),(8,'2020_07_08_065301_add_token_id_to_activity_table',1),(9,'2020_07_21_112424_update_enabled_modules_value',1),(10,'2020_07_28_104218_shop_token',1),(11,'2020_08_04_080851_add_is_deleted_to_group_settings',1),(12,'2020_08_11_221627_add_is_deleted_flag_to_client_gateway_token_table',1),(13,'2020_08_13_095946_remove_photo_design',1),(14,'2020_08_13_212702_add_reminder_sent_fields_to_entity_tables',1),(15,'2020_08_18_140557_add_is_public_to_documents_table',1),(16,'2020_09_22_205113_id_number_fields_for_missing_entities',1),(17,'2020_09_27_215800_update_gateway_table_visible_column',1),(18,'2020_10_11_211122_vendor_schema_update',1),(19,'2020_10_12_204517_project_number_column',1),(20,'2020_10_14_201320_project_ids_to_entities',1),(21,'2020_10_19_101823_project_name_unique_removal',1),(22,'2020_10_21_222738_expenses_nullable_assigned_user',1),(23,'2020_10_22_204900_company_table_fields',1),(24,'2020_10_27_021751_tasks_invoice_documents',1),(25,'2020_10_28_224711_status_sort_order',1),(26,'2020_10_28_225022_assigned_user_tasks_table',1),(27,'2020_10_29_001541_vendors_phone_column',1),(28,'2020_10_29_093836_change_start_time_column_type',1),(29,'2020_10_29_204434_tasks_table_project_nullable',1),(30,'2020_10_29_210402_change_default_show_tasks_table',1),(31,'2020_10_30_084139_change_expense_currency_id_column',1),(32,'2020_11_01_031750_drop_migrating_column',1),(33,'2020_11_03_200345_company_gateway_fields_refactor',1),(34,'2020_11_08_212050_custom_fields_for_payments_table',1),(35,'2020_11_12_104413_company_gateway_rename_column',1),(36,'2020_11_15_203755_soft_delete_paymentables',1),(37,'2020_12_14_114722_task_fields',1),(38,'2020_12_17_104033_add_enable_product_discount_field_to_companies_table',1),(39,'2020_12_20_005609_change_products_table_cost_resolution',1),(40,'2020_12_23_220648_remove_null_values_in_countries_table',1),(41,'2021_01_03_215053_update_canadian_dollar_symbol',1),(42,'2021_01_05_013203_improve_decimal_resolution',1),(43,'2021_01_07_023350_update_singapore_dollar_symbol',1),(44,'2021_01_08_093324_expenses_table_additional_fields',1),(45,'2021_01_11_092056_fix_company_settings_url',1),(46,'2021_01_17_040331_change_custom_surcharge_column_type',1),(47,'2021_01_23_044502_scheduler_is_running_check',1),(48,'2021_01_24_052645_add_paid_to_date_column',1),(49,'2021_01_25_095351_add_number_field_to_clients_and_vendors',1),(50,'2021_01_29_121502_add_permission_changed_timestamp',1),(51,'2021_02_15_214724_additional_company_properties',1),(52,'2021_02_19_212722_email_last_confirmed_email_address_users_table',1),(53,'2021_02_25_205901_enum_invitations_email_status',1),(54,'2021_02_27_091713_add_invoice_task_datelog_property',1),(55,'2021_03_03_230941_add_has_password_field_to_user_table',1),(56,'2021_03_08_123729_create_billing_subscriptions_table',1),(57,'2021_03_08_205030_add_russian_lang',1),(58,'2021_03_09_132242_add_currency_id_to_billing_subscriptions_table',1),(59,'2021_03_18_113704_change_2fa_column_from_varchar_to_text',1),(60,'2021_03_19_221024_add_unique_constraints_on_all_entities',1),(61,'2021_03_20_033751_add_invoice_id_to_client_subscriptions_table',1),(62,'2021_03_23_233844_add_nullable_constraint_to_recurring_invoice_id',1),(63,'2021_03_25_082025_refactor_billing_scriptions_table',1),(64,'2021_03_26_201148_add_price_column_to_subscriptions_table',1),(65,'2021_04_01_093128_modify_column_on_subscriptions_table',1),(66,'2021_04_05_115345_add_trial_duration_to_accounts_table',1),(67,'2021_04_05_213802_add_rest_fields_to_webhooks_table',1),(68,'2021_04_06_131028_create_licenses_table',1),(69,'2021_04_12_095424_stripe_connect_gateway',1),(70,'2021_04_13_013424_add_subscription_id_to_activities_table',1),(71,'2021_04_22_110240_add_property_to_checkout_gateway_config',1),(72,'2021_04_29_085418_add_number_years_active_to_company_users_table',1),(73,'2021_05_03_152940_make_braintree_provider_visible',1),(74,'2021_05_04_231430_add_task_property_to_companies_table',1),(75,'2021_05_05_014713_activate_we_pay',1),(76,'2021_05_10_041528_add_recurring_invoice_id_to_activities_table',1),(77,'2021_05_27_105157_add_tech_design',1),(78,'2021_05_30_100933_make_documents_assigned_user_nullable',1),(79,'2021_06_10_221012_add_ninja_portal_column_to_accounts_table',1),(80,'2021_06_24_095942_payments_table_currency_nullable',1),(81,'2021_07_10_085821_activate_payfast_payment_driver',1),(82,'2021_07_19_074503_set_invoice_task_datelog_true_in_companies_table',1),(83,'2021_07_20_095537_activate_paytrace_payment_driver',1),(84,'2021_07_21_213344_change_english_languages_tables',1),(85,'2021_07_21_234227_activate_eway_payment_driver',1),(86,'2021_08_03_115024_activate_mollie_payment_driver',1),(87,'2021_08_05_235942_add_zelle_payment_type',1),(88,'2021_08_07_222435_add_markdown_enabled_column_to_companies_table',1),(89,'2021_08_10_034407_add_more_languages',1),(90,'2021_08_14_054458_square_payment_driver',1),(91,'2021_08_18_220124_use_comma_as_decimal_place_companies_table',1),(92,'2021_08_23_101529_recurring_expenses_schema',1),(93,'2021_08_25_093105_report_include_drafts_in_companies_table',1),(94,'2021_09_05_101209_update_braintree_gateway',1),(95,'2021_09_20_233053_set_square_test_mode_boolean',1),(96,'2021_09_23_100629_add_currencies',1),(97,'2021_09_24_201319_add_mollie_bank_transfer_to_payment_types',1),(98,'2021_09_24_211504_add_kbc_to_payment_types',1),(99,'2021_09_24_213858_add_bancontact_to_payment_types',1),(100,'2021_09_28_154647_activate_gocardless_payment_driver',1),(101,'2021_09_29_190258_add_required_client_registration_fields',1),(102,'2021_10_04_134908_add_ideal_to_payment_types',1),(103,'2021_10_06_044800_updated_bold_and_modern_designs',1),(104,'2021_10_07_141737_razorpay',1),(105,'2021_10_07_155410_add_hosted_page_to_payment_types',1),(106,'2021_10_15_00000_stripe_payment_gateways',1),(107,'2021_10_16_135200_add_direct_debit_to_payment_types',1),(108,'2021_10_19_142200_add_gateway_type_for_direct_debit',1),(109,'2021_10_20_005529_add_filename_to_backups_table',1),(110,'2021_11_08_131308_onboarding',1),(111,'2021_11_09_115919_update_designs',1),(112,'2021_11_10_184847_add_is_migrate_column_to_accounts_table',1),(113,'2021_11_11_163121_add_instant_bank_transfer',1),(114,'2021_12_20_095542_add_serbian_language_translations',1),(115,'2022_01_02_022421_add_slovak_language',1),(116,'2022_01_06_061231_add_app_domain_id_to_gateways_table',1),(117,'2022_01_18_004856_add_estonian_language',1),(118,'2022_01_19_085907_add_platform_column_to_accounts_table',1),(119,'2022_01_19_232436_add_kyd_currency',1),(120,'2022_01_27_223617_add_client_count_to_accounts_table',1),(121,'2022_02_06_091629_add_client_currency_conversion_to_companies_table',1),(122,'2022_02_25_015411_update_stripe_apple_domain_config',1),(123,'2022_03_09_053508_transaction_events',1),(124,'2022_03_24_090728_markdown_email_enabled_wysiwyg_editor',1),(125,'2022_03_29_014025_reverse_apple_domain_for_hosted',1),(126,'2022_04_14_121548_forte_payment_gateway',1),(127,'2022_04_22_115838_client_settings_parse_for_types',1),(128,'2022_04_26_032252_convert_custom_fields_column_from_varchar_to_text',1),(129,'2022_05_08_004937_heal_stripe_gateway_configuration',1),(130,'2022_05_12_56879_add_stripe_klarna',1),(131,'2022_05_16_224917_add_auto_bill_tries_to_invoices_table',1),(132,'2022_05_18_055442_update_custom_value_four_columns',1),(133,'2022_05_18_162152_create_scheduled_jobs_table',1),(134,'2022_05_18_162443_create_schedulers_table',1),(135,'2022_05_23_050754_drop_redundant_column_show_production_description_dropdown',1),(136,'2022_05_28_234651_create_purchase_orders_table',1),(137,'2022_05_30_181109_drop_scheduled_jobs_table',1),(138,'2022_05_30_184320_add_job_related_fields_to_schedulers_table',1),(139,'2022_05_31_101504_inventory_management_schema',1),(140,'2022_06_01_215859_set_recurring_client_timestamp',1),(141,'2022_06_01_224339_create_purchase_order_invitations_table',1),(142,'2022_06_10_030503_set_account_flag_for_react',1),(143,'2022_06_16_025156_add_react_switching_flag',1),(144,'2022_06_17_082627_change_refresh_token_column_size',1),(145,'2022_06_21_104350_fixes_for_description_in_pdf_designs',1),(146,'2022_06_22_090547_set_oauth_expiry_column',1),(147,'2022_06_24_141018_upgrade_failed_jobs_table',1),(148,'2022_06_30_000126_add_flag_to_accounts_table',1),(149,'2022_07_06_080127_add_purchase_order_to_expense',1),(150,'2022_07_09_235510_add_index_to_payment_hash',1),(151,'2022_07_12_45766_add_matomo',1),(152,'2022_07_18_033756_fixes_for_date_formats_table_react',1),(153,'2022_07_21_023805_add_hebrew_language',1),(154,'2022_07_26_091216_add_sms_verification_to_hosted_account',1),(155,'2022_07_28_232340_enabled_expense_tax_rates_to_companies_table',1),(156,'2022_07_29_091235_correction_for_companies_table_types',1),(157,'2022_08_05_023357_bank_integration',1),(158,'2022_08_11_011534_licenses_table_for_self_host',1),(159,'2022_08_24_215917_invoice_task_project_companies_table',1),(160,'2022_08_26_232500_add_email_status_column_to_purchase_order_invitations_table',1),(161,'2022_08_28_210111_add_index_to_payments_table',1),(162,'2022_09_05_024719_update_designs_for_tech_template',1),(163,'2022_09_07_101731_add_reporting_option_to_companies_table',1),(164,'2022_09_21_012417_add_threeds_to_braintree',1),(165,'2022_09_30_235337_add_idempotency_key_to_payments',1),(166,'2022_10_05_205645_add_indexes_to_client_hash',1),(167,'2022_10_06_011344_add_key_to_products',1),(168,'2022_10_07_065455_add_key_to_company_tokens_table',1),(169,'2022_10_10_070137_add_documentable_index',1),(170,'2022_10_27_044909_add_user_sms_verification_code',1),(171,'2022_11_02_063742_add_verified_number_flag_to_users_table',1),(172,'2022_11_04_013539_disabled_upstream_bank_integrations_table',1),(173,'2022_11_06_215526_drop_html_backups_column_from_backups_table',1),(174,'2022_11_13_034143_bank_transaction_rules_table',1),(175,'2022_11_16_093535_calmness_design',1),(176,'2022_11_22_215618_lock_tasks_when_invoiced',1),(177,'2022_11_30_063229_add_payment_id_to_bank_transaction_table',1),(178,'2022_12_07_024625_add_properties_to_companies_table',1),(179,'2022_12_14_004639_vendor_currency_update',1),(180,'2022_12_20_063038_set_proforma_invoice_type',1),(181,'2023_01_12_125540_set_auto_bill_on_regular_invoice_setting',1),(182,'2022_16_12_54687_add_stripe_bacs',2),(183,'2023_01_27_023127_update_design_templates',2),(184,'2023_02_02_062938_add_additional_required_fields_gateways',2),(185,'2023_02_05_042351_add_foreign_key_for_vendors',2),(186,'2023_02_07_114011_add_additional_product_fields',2),(187,'2023_02_14_064135_create_react_settings_column_company_user_table',2),(188,'2023_02_28_064453_update_designs',2),(189,'2023_02_28_200056_add_visible_prop_to_companies_table',2),(190,'2023_03_09_121033_add_payment_balance_to_clients_table',2),(191,'2023_03_10_100629_add_currencies',2),(192,'2023_03_13_156872_add_e_invoice_type_to_clients_table',2),(193,'2023_03_17_012309_add_proforma_flag_for_recurring_invoices',2),(194,'2023_03_21_053933_tax_calculations_for_invoices',2),(195,'2023_03_24_054758_add_client_is_exempt_from_taxes',2),(196,'2023_04_20_215159_drop_e_invoice_type_column',2),(197,'2023_04_27_045639_add_kmher_language',2),(198,'2023_05_03_023956_add_shopify_user_id',2),(199,'2023_05_15_103212_e_invoice_ssl_storage',2),(200,'2023_06_04_064713_project_and_task_columns_for_company_model',2),(201,'2023_06_13_220252_add_hungarian_translations',2),(202,'2023_06_20_123355_add_paypal_rest_payment_driver',2),(203,'2023_07_06_063512_update_designs',2),(204,'2023_07_08_000314_add_french_swiss_translations',2),(205,'2023_07_12_074829_add_thai_baht_currency_symbol',2),(206,'2023_07_18_214607_add_start_date_column_to_tasks',2),(207,'2023_07_22_234329_change_currency_format_for_indonesian_rupiah',2),(208,'2023_08_06_070205_create_view_dashboard_permission_migration',2),(209,'2023_08_08_212710_add_signature_ip_address_to_purchase_order_invitations',2),(210,'2023_08_09_224955_add_nicaragua_currency',2),(211,'2023_09_11_003230_add_client_and_company_classifications',2),(212,'2023_09_21_042010_add_template_flag_to_designs_table',2),(213,'2023_10_01_102220_add_language_id_to_users_table',2),(214,'2023_10_08_092508_add_refund_meta_and_category_to_payments_table',2),(215,'2023_10_10_083024_add_ariary_currency',2),(216,'2023_10_15_204204_add_paypal_ppcp',2),(217,'2023_10_18_061415_add_user_notification_suppression',2),(218,'2023_11_26_082959_add_bank_integration_id',2),(219,'2023_11_27_095042_add_hash_and_meta_columns_to_tasks_table',2),(220,'2023_11_30_042431_2023_11_30_add_payment_visibility',2),(221,'2024_01_09_084515_product_cost_field_population',2),(222,'2024_01_10_071427_normalize_product_cost_types',2),(223,'2024_01_10_155555_add_bank_transaction_nordigen_field',2),(224,'2024_01_12_073629_laos_currency_translation',2),(225,'2024_01_29_080555_2024_01_29_update_timezones_naming',2),(226,'2024_02_06_204031_correction_for_krw_currency',2),(227,'2024_02_16_011055_smtp_configuration',2),(228,'2024_02_28_180250_add_steps_to_subscriptions',2),(229,'2024_03_07_195116_add_tax_data_to_quotes',2),(230,'2024_03_14_201844_adjust_discount_column_max_resolution',2),(231,'2024_03_24_200109_new_currencies_03_24',2),(232,'2024_04_24_064301_optional_display_required_fields_payment_gateways',2),(233,'2024_05_02_030103_2024_05_02_update_timezones',2),(234,'2024_05_03_145535_btcpay_gateway',2),(235,'2024_05_19_215103_2024_05_20_einvoice_columns',2),(236,'2024_05_26_210407_2024_05_28_kwd_precision',2),(237,'2024_06_02_083543_2024_06_01_add_einvoice_to_client_table',2),(238,'2024_06_04_123926_2024_06_04_fixes_for_btc_migration',2),(239,'2024_06_08_043343_2024_06_08__i_s_k_currency_precision',2),(240,'2024_06_19_015127_2024_06_19_referral_meta_data',2),(241,'2023_12_10_110951_inbound_mail_parsing',3),(242,'2024_06_11_231143_add_rotessa_gateway',3),(243,'2024_06_23_040253_2024-06-23_indexesforinvoiceid_payment_hashes',3),(244,'2024_07_10_043241_2024_07_10_invoice_id_index_on_projects_table',3),(245,'2024_07_16_231556_2024_07_17_add_dubai_timezone',3),(246,'2024_07_29_235430_2024_30_07_tax_model_migration',3),(247,'2024_08_02_144614_alter_companies_quickbooks',3),(248,'2024_08_04_225558_tax_model_migration_v2',3),(249,'2024_08_21_001832_add_einvoice_option_license',3),(250,'2024_08_26_055523_add_qb_product_hash',3),(251,'2024_08_27_230111_blockonomics_gateway',3),(252,'2024_09_06_042040_cba_powerboard',3),(253,'2024_09_15_022436_add_autonomous_es_regions',3),(254,'2024_09_16_221343_add_remaining_cycles_to_subscriptions',3),(255,'2024_09_21_062105_2024_09_21_add_vn_lang',3),(256,'2024_09_22_084749_2024_09_23_add_sync_column_for_qb',3),(257,'2024_09_29_221552_add_gateway_fee_column',4),(258,'2024_10_03_235524_add_is_tax_exempt_vendors_table',5),(259,'2024_10_08_034355_add_account_e_invoice_quota',6),(260,'2024_10_09_220533_invoice_gateway_fee',6),(261,'2024_10_11_151650_create_e_invoice_tokens_table',6),(262,'2024_10_11_153311_add_e_invoicing_token',6),(263,'2024_10_14_214658_add_routing_id_to_vendors_table',6),(264,'2024_10_18_211558_updated_currencies',6),(265,'2024_11_11_043923_kill_switch_licenses_table',6),(266,'2024_11_19_020259_add_entity_set_to_licenses_table',6),(267,'2024_11_21_011625_add_e_invoicing_logs_table',6),(268,'2024_11_28_054808_add_referral_earning_column_to_users_table',6),(269,'2024_12_18_023826_2024_12_18_enforce_tax_data_model',6),(270,'2025_01_08_024611_2025_01_07_design_updates',6),(271,'2025_01_15_222249_2025_01_16_zim_currency_change',6),(272,'2025_01_18_012550_2025_01_16_wst_currency',6),(273,'2025_01_22_013047_2025_01_22_add_verification_setting_to_gocardless',6),(274,'2025_02_12_000757_change_inr_currency_symbol',6),(275,'2025_02_12_035916_create_sync_column_for_payments',6),(276,'2025_02_16_213917_add_e_invoice_column_to_recurring_invoices_table',6),(277,'2025_02_20_224129_entity_location_schema',6),(278,'2025_03_09_084919_add_payment_unapplied_pdf_variabels',6),(279,'2025_03_11_044138_update_blockonomics_help_url',6),(280,'2025_03_13_073151_update_blockonomics',6);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_hashes`
--

DROP TABLE IF EXISTS `payment_hashes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_hashes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fee_total` decimal(16,4) NOT NULL,
  `fee_invoice_id` int unsigned DEFAULT NULL,
  `data` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_id` int unsigned DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payment_hashes_payment_id_foreign` (`payment_id`),
  KEY `payment_hashes_hash_index` (`hash`),
  KEY `payment_hashes_fee_invoice_id_index` (`fee_invoice_id`),
  CONSTRAINT `payment_hashes_payment_id_foreign` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_hashes`
--

LOCK TABLES `payment_hashes` WRITE;
/*!40000 ALTER TABLE `payment_hashes` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_hashes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_libraries`
--

DROP TABLE IF EXISTS `payment_libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_libraries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_libraries`
--

LOCK TABLES `payment_libraries` WRITE;
/*!40000 ALTER TABLE `payment_libraries` DISABLE KEYS */;
INSERT INTO `payment_libraries` VALUES (1,'2026-09-16 07:56:51.269376','2026-09-16 07:56:51.269376','Omnipay',1);
/*!40000 ALTER TABLE `payment_libraries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_terms`
--

DROP TABLE IF EXISTS `payment_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_terms` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `num_days` int DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payment_terms_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `payment_terms_user_id_foreign` (`user_id`),
  CONSTRAINT `payment_terms_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payment_terms_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_terms`
--

LOCK TABLES `payment_terms` WRITE;
/*!40000 ALTER TABLE `payment_terms` DISABLE KEYS */;
INSERT INTO `payment_terms` VALUES (1,0,'Net 0',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(2,7,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(3,10,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(4,14,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(5,15,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(6,30,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(7,60,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL),(8,90,'',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL);
/*!40000 ALTER TABLE `payment_terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_types`
--

DROP TABLE IF EXISTS `payment_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gateway_type_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_types`
--

LOCK TABLES `payment_types` WRITE;
/*!40000 ALTER TABLE `payment_types` DISABLE KEYS */;
INSERT INTO `payment_types` VALUES (1,'Bank Transfer',2),(2,'Cash',NULL),(3,'Debit',1),(4,'ACH',2),(5,'Visa Card',1),(6,'MasterCard',1),(7,'American Express',1),(8,'Discover Card',1),(9,'Diners Card',1),(10,'EuroCard',1),(11,'Nova',1),(12,'Credit Card Other',1),(13,'PayPal',3),(14,'Google Wallet',NULL),(15,'Check',NULL),(16,'Carte Blanche',1),(17,'UnionPay',1),(18,'JCB',1),(19,'Laser',1),(20,'Maestro',1),(21,'Solo',1),(22,'Switch',1),(23,'iZettle',1),(24,'Swish',2),(25,'Venmo',NULL),(26,'Money Order',NULL),(27,'Alipay',7),(28,'Sofort',8),(29,'SEPA',9),(30,'GoCardless',10),(31,'Crypto',4),(32,'Credit',14),(33,'Zelle',NULL);
/*!40000 ALTER TABLE `payment_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paymentables`
--

DROP TABLE IF EXISTS `paymentables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paymentables` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_id` int unsigned NOT NULL,
  `paymentable_id` int unsigned NOT NULL,
  `amount` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `refunded` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `paymentable_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `paymentables_payment_id_foreign` (`payment_id`),
  KEY `paymentables_paymentable_id_index` (`paymentable_id`),
  CONSTRAINT `paymentables_payment_id_foreign` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paymentables`
--

LOCK TABLES `paymentables` WRITE;
/*!40000 ALTER TABLE `paymentables` DISABLE KEYS */;
/*!40000 ALTER TABLE `paymentables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `client_contact_id` int unsigned DEFAULT NULL,
  `invitation_id` int unsigned DEFAULT NULL,
  `company_gateway_id` int unsigned DEFAULT NULL,
  `gateway_type_id` int unsigned DEFAULT NULL,
  `type_id` int unsigned DEFAULT NULL,
  `status_id` int unsigned NOT NULL,
  `amount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `refunded` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `applied` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `date` date DEFAULT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payer_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_manual` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `currency_id` int unsigned NOT NULL,
  `exchange_currency_id` int unsigned DEFAULT NULL,
  `meta` text COLLATE utf8mb4_unicode_ci,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `transaction_id` bigint unsigned DEFAULT NULL,
  `idempotency_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refund_meta` text COLLATE utf8mb4_unicode_ci,
  `category_id` int unsigned DEFAULT NULL,
  `sync` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payments_company_id_number_unique` (`company_id`,`number`),
  UNIQUE KEY `payments_company_id_idempotency_key_unique` (`company_id`,`idempotency_key`),
  KEY `payments_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `payments_client_contact_id_foreign` (`client_contact_id`),
  KEY `payments_company_gateway_id_foreign` (`company_gateway_id`),
  KEY `payments_user_id_foreign` (`user_id`),
  KEY `payments_company_id_index` (`company_id`),
  KEY `payments_client_id_index` (`client_id`),
  KEY `payments_status_id_index` (`status_id`),
  KEY `payments_transaction_reference_index` (`transaction_reference`),
  KEY `payments_idempotency_key_index` (`idempotency_key`),
  CONSTRAINT `payments_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payments_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payments_company_gateway_id_foreign` FOREIGN KEY (`company_gateway_id`) REFERENCES `company_gateways` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payments_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `product_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `cost` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `quantity` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `in_stock_quantity` int NOT NULL DEFAULT '0',
  `stock_notification` tinyint(1) NOT NULL DEFAULT '1',
  `stock_notification_threshold` int NOT NULL DEFAULT '0',
  `max_quantity` int unsigned DEFAULT NULL,
  `product_image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_id` int unsigned DEFAULT NULL,
  `hash` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sync` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `products_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `products_user_id_foreign` (`user_id`),
  KEY `products_company_id_index` (`company_id`),
  KEY `pro_co_us_up_index` (`company_id`,`user_id`,`assigned_user_id`,`updated_at`),
  KEY `products_product_key_company_id_index` (`product_key`,`company_id`),
  CONSTRAINT `products_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `products_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_rate` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `due_date` date DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `budgeted_hours` decimal(20,6) NOT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#fff',
  `current_hours` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `projects_company_id_number_unique` (`company_id`,`number`),
  KEY `projects_user_id_foreign` (`user_id`),
  KEY `projects_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `projects_company_id_index` (`company_id`),
  CONSTRAINT `projects_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_order_invitations`
--

DROP TABLE IF EXISTS `purchase_order_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order_invitations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `vendor_contact_id` int unsigned NOT NULL,
  `purchase_order_id` bigint unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signature_ip` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_purchase_unique` (`vendor_contact_id`,`purchase_order_id`),
  KEY `purchase_order_invitations_user_id_foreign` (`user_id`),
  KEY `purchase_order_invitations_company_id_foreign` (`company_id`),
  KEY `vendor_purchase_company_index` (`deleted_at`,`purchase_order_id`,`company_id`),
  KEY `purchase_order_invitations_purchase_order_id_index` (`purchase_order_id`),
  KEY `purchase_order_invitations_key_index` (`key`),
  KEY `purchase_order_invitations_message_id_index` (`message_id`),
  CONSTRAINT `purchase_order_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `purchase_order_invitations_purchase_order_id_foreign` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `purchase_order_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `purchase_order_invitations_vendor_contact_id_foreign` FOREIGN KEY (`vendor_contact_id`) REFERENCES `vendor_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order_invitations`
--

LOCK TABLES `purchase_order_invitations` WRITE;
/*!40000 ALTER TABLE `purchase_order_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_order_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `status_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `recurring_id` int unsigned DEFAULT NULL,
  `design_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `last_sent_date` datetime DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `reminder1_sent` date DEFAULT NULL,
  `reminder2_sent` date DEFAULT NULL,
  `reminder3_sent` date DEFAULT NULL,
  `reminder_last_sent` date DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `next_send_date` datetime DEFAULT NULL,
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `balance` decimal(20,6) NOT NULL,
  `partial` decimal(20,6) DEFAULT NULL,
  `amount` decimal(20,6) NOT NULL,
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `partial_due_date` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expense_id` int unsigned DEFAULT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `location_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `purchase_orders_user_id_foreign` (`user_id`),
  KEY `purchase_orders_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `purchase_orders_client_id_index` (`client_id`),
  KEY `purchase_orders_company_id_index` (`company_id`),
  KEY `purchase_orders_expense_id_index` (`expense_id`),
  KEY `purchase_orders_location_id_foreign` (`location_id`),
  CONSTRAINT `purchase_orders_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `purchase_orders_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `purchase_orders_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `purchase_orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quote_invitations`
--

DROP TABLE IF EXISTS `quote_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quote_invitations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `client_contact_id` int unsigned NOT NULL,
  `quote_id` int unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `signature_ip` text COLLATE utf8mb4_unicode_ci,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `quote_invitations_client_contact_id_quote_id_unique` (`client_contact_id`,`quote_id`),
  KEY `quote_invitations_user_id_foreign` (`user_id`),
  KEY `quote_invitations_company_id_foreign` (`company_id`),
  KEY `quote_invitations_deleted_at_quote_id_company_id_index` (`deleted_at`,`quote_id`,`company_id`),
  KEY `quote_invitations_quote_id_index` (`quote_id`),
  KEY `quote_invitations_key_index` (`key`),
  KEY `quote_invitations_message_id_index` (`message_id`),
  CONSTRAINT `quote_invitations_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `quote_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `quote_invitations_quote_id_foreign` FOREIGN KEY (`quote_id`) REFERENCES `quotes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `quote_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quote_invitations`
--

LOCK TABLES `quote_invitations` WRITE;
/*!40000 ALTER TABLE `quote_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `quote_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `status_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `recurring_id` int unsigned DEFAULT NULL,
  `design_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `last_sent_date` date DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `next_send_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `amount` decimal(20,6) NOT NULL,
  `balance` decimal(20,6) NOT NULL,
  `partial` decimal(20,6) DEFAULT NULL,
  `partial_due_date` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `reminder1_sent` date DEFAULT NULL,
  `reminder2_sent` date DEFAULT NULL,
  `reminder3_sent` date DEFAULT NULL,
  `reminder_last_sent` date DEFAULT NULL,
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `subscription_id` int unsigned DEFAULT NULL,
  `tax_data` mediumtext COLLATE utf8mb4_unicode_ci,
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `location_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `quotes_company_id_number_unique` (`company_id`,`number`),
  KEY `quotes_user_id_foreign` (`user_id`),
  KEY `quotes_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `quotes_client_id_index` (`client_id`),
  KEY `quotes_company_id_index` (`company_id`),
  KEY `quotes_company_id_updated_at_index` (`company_id`,`updated_at`),
  KEY `quotes_project_id_deleted_at_index` (`project_id`,`deleted_at`),
  KEY `quotes_location_id_foreign` (`location_id`),
  CONSTRAINT `quotes_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `quotes_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `quotes_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `quotes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotes`
--

LOCK TABLES `quotes` WRITE;
/*!40000 ALTER TABLE `quotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `quotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_expenses`
--

DROP TABLE IF EXISTS `recurring_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_expenses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `status_id` int unsigned NOT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `bank_id` int unsigned DEFAULT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `payment_type_id` int unsigned DEFAULT NULL,
  `recurring_expense_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '1',
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `should_be_invoiced` tinyint(1) NOT NULL DEFAULT '0',
  `invoice_documents` tinyint(1) NOT NULL DEFAULT '0',
  `transaction_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `category_id` int unsigned DEFAULT NULL,
  `calculate_tax_by_amount` tinyint(1) NOT NULL DEFAULT '0',
  `tax_amount1` decimal(20,6) DEFAULT NULL,
  `tax_amount2` decimal(20,6) DEFAULT NULL,
  `tax_amount3` decimal(20,6) DEFAULT NULL,
  `tax_rate1` decimal(20,6) DEFAULT NULL,
  `tax_rate2` decimal(20,6) DEFAULT NULL,
  `tax_rate3` decimal(20,6) DEFAULT NULL,
  `amount` decimal(20,6) DEFAULT NULL,
  `foreign_amount` decimal(20,6) DEFAULT NULL,
  `exchange_rate` decimal(20,6) NOT NULL DEFAULT '1.000000',
  `assigned_user_id` int unsigned DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoice_currency_id` int unsigned DEFAULT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `transaction_reference` text COLLATE utf8mb4_unicode_ci,
  `frequency_id` int unsigned NOT NULL,
  `last_sent_date` datetime DEFAULT NULL,
  `next_send_date` datetime DEFAULT NULL,
  `remaining_cycles` int DEFAULT NULL,
  `next_send_date_client` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `recurring_expenses_company_id_number_unique` (`company_id`,`number`),
  KEY `recurring_expenses_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `recurring_expenses_user_id_foreign` (`user_id`),
  KEY `recurring_expenses_company_id_index` (`company_id`),
  CONSTRAINT `recurring_expenses_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_expenses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_expenses`
--

LOCK TABLES `recurring_expenses` WRITE;
/*!40000 ALTER TABLE `recurring_expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_invoice_invitations`
--

DROP TABLE IF EXISTS `recurring_invoice_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_invoice_invitations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `client_contact_id` int unsigned NOT NULL,
  `recurring_invoice_id` int unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cli_rec` (`client_contact_id`,`recurring_invoice_id`),
  KEY `recurring_invoice_invitations_user_id_foreign` (`user_id`),
  KEY `recurring_invoice_invitations_company_id_foreign` (`company_id`),
  KEY `rec_co_del` (`deleted_at`,`recurring_invoice_id`,`company_id`),
  KEY `recurring_invoice_invitations_recurring_invoice_id_index` (`recurring_invoice_id`),
  KEY `recurring_invoice_invitations_key_index` (`key`),
  CONSTRAINT `recurring_invoice_invitations_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_invoice_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_invoice_invitations_recurring_invoice_id_foreign` FOREIGN KEY (`recurring_invoice_id`) REFERENCES `recurring_invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_invoice_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_invoice_invitations`
--

LOCK TABLES `recurring_invoice_invitations` WRITE;
/*!40000 ALTER TABLE `recurring_invoice_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_invoice_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_invoices`
--

DROP TABLE IF EXISTS `recurring_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_invoices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `status_id` int unsigned NOT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `amount` decimal(20,6) NOT NULL,
  `balance` decimal(20,6) NOT NULL,
  `partial` decimal(16,4) DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `frequency_id` int unsigned NOT NULL,
  `last_sent_date` datetime DEFAULT NULL,
  `next_send_date` datetime DEFAULT NULL,
  `remaining_cycles` int DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `auto_bill` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'off',
  `auto_bill_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `design_id` int unsigned DEFAULT NULL,
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `due_date_days` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `partial_due_date` date DEFAULT NULL,
  `exchange_rate` decimal(13,6) NOT NULL DEFAULT '1.000000',
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `subscription_id` int unsigned DEFAULT NULL,
  `next_send_date_client` datetime DEFAULT NULL,
  `is_proforma` tinyint(1) NOT NULL DEFAULT '0',
  `e_invoice` mediumtext COLLATE utf8mb4_unicode_ci,
  `location_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `recurring_invoices_company_id_number_unique` (`company_id`,`number`),
  KEY `recurring_invoices_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `recurring_invoices_user_id_foreign` (`user_id`),
  KEY `recurring_invoices_client_id_index` (`client_id`),
  KEY `recurring_invoices_company_id_index` (`company_id`),
  KEY `recurring_invoices_status_id_index` (`status_id`),
  KEY `recurring_invoices_location_id_foreign` (`location_id`),
  CONSTRAINT `recurring_invoices_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_invoices_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_invoices_location_id_foreign` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `recurring_invoices_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_invoices`
--

LOCK TABLES `recurring_invoices` WRITE;
/*!40000 ALTER TABLE `recurring_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_quote_invitations`
--

DROP TABLE IF EXISTS `recurring_quote_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_quote_invitations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `client_contact_id` int unsigned NOT NULL,
  `recurring_quote_id` int unsigned NOT NULL,
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_reference` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `signature_base64` text COLLATE utf8mb4_unicode_ci,
  `signature_date` datetime DEFAULT NULL,
  `sent_date` datetime DEFAULT NULL,
  `viewed_date` datetime DEFAULT NULL,
  `opened_date` datetime DEFAULT NULL,
  `email_status` enum('delivered','bounced','spam') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cli_rec_q` (`client_contact_id`,`recurring_quote_id`),
  KEY `recurring_quote_invitations_user_id_foreign` (`user_id`),
  KEY `recurring_quote_invitations_company_id_foreign` (`company_id`),
  KEY `rec_co_del_q` (`deleted_at`,`recurring_quote_id`,`company_id`),
  KEY `recurring_quote_invitations_recurring_quote_id_index` (`recurring_quote_id`),
  KEY `recurring_quote_invitations_key_index` (`key`),
  CONSTRAINT `recurring_quote_invitations_client_contact_id_foreign` FOREIGN KEY (`client_contact_id`) REFERENCES `client_contacts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_quote_invitations_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_quote_invitations_recurring_quote_id_foreign` FOREIGN KEY (`recurring_quote_id`) REFERENCES `recurring_invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_quote_invitations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_quote_invitations`
--

LOCK TABLES `recurring_quote_invitations` WRITE;
/*!40000 ALTER TABLE `recurring_quote_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_quote_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_quotes`
--

DROP TABLE IF EXISTS `recurring_quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_quotes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `vendor_id` int unsigned DEFAULT NULL,
  `status_id` int unsigned NOT NULL,
  `discount` double(8,2) NOT NULL DEFAULT '0.00',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `po_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `line_items` mediumtext COLLATE utf8mb4_unicode_ci,
  `backup` mediumtext COLLATE utf8mb4_unicode_ci,
  `footer` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `tax_name1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate1` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate2` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `tax_name3` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_rate3` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_taxes` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `amount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `balance` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `last_viewed` datetime DEFAULT NULL,
  `frequency_id` int unsigned NOT NULL,
  `last_sent_date` datetime DEFAULT NULL,
  `next_send_date` datetime DEFAULT NULL,
  `remaining_cycles` int unsigned DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `auto_bill` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'off',
  `auto_bill_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `paid_to_date` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `custom_surcharge1` decimal(20,6) DEFAULT NULL,
  `custom_surcharge2` decimal(20,6) DEFAULT NULL,
  `custom_surcharge3` decimal(20,6) DEFAULT NULL,
  `custom_surcharge4` decimal(20,6) DEFAULT NULL,
  `custom_surcharge_tax1` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax2` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax3` tinyint(1) NOT NULL DEFAULT '0',
  `custom_surcharge_tax4` tinyint(1) NOT NULL DEFAULT '0',
  `due_date_days` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exchange_rate` decimal(13,6) NOT NULL DEFAULT '1.000000',
  `partial` decimal(16,4) DEFAULT NULL,
  `partial_due_date` date DEFAULT NULL,
  `subscription_id` int unsigned DEFAULT NULL,
  `uses_inclusive_taxes` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `recurring_quotes_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `recurring_quotes_user_id_foreign` (`user_id`),
  KEY `recurring_quotes_client_id_index` (`client_id`),
  KEY `recurring_quotes_company_id_index` (`company_id`),
  KEY `recurring_quotes_status_id_index` (`status_id`),
  CONSTRAINT `recurring_quotes_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_quotes_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recurring_quotes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_quotes`
--

LOCK TABLES `recurring_quotes` WRITE;
/*!40000 ALTER TABLE `recurring_quotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_quotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedulers`
--

DROP TABLE IF EXISTS `schedulers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedulers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `parameters` mediumtext COLLATE utf8mb4_unicode_ci,
  `company_id` int unsigned NOT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `frequency_id` int unsigned DEFAULT NULL,
  `next_run` datetime DEFAULT NULL,
  `next_run_client` datetime DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `template` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remaining_cycles` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `schedulers_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  CONSTRAINT `schedulers_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedulers`
--

LOCK TABLES `schedulers` WRITE;
/*!40000 ALTER TABLE `schedulers` DISABLE KEYS */;
/*!40000 ALTER TABLE `schedulers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sizes`
--

DROP TABLE IF EXISTS `sizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sizes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sizes`
--

LOCK TABLES `sizes` WRITE;
/*!40000 ALTER TABLE `sizes` DISABLE KEYS */;
INSERT INTO `sizes` VALUES (1,'1 - 3'),(2,'4 - 10'),(3,'11 - 50'),(4,'51 - 100'),(5,'101 - 500'),(6,'500+');
/*!40000 ALTER TABLE `sizes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `product_ids` text COLLATE utf8mb4_unicode_ci,
  `frequency_id` int unsigned DEFAULT NULL,
  `auto_bill` text COLLATE utf8mb4_unicode_ci,
  `promo_code` text COLLATE utf8mb4_unicode_ci,
  `promo_discount` double(8,2) NOT NULL DEFAULT '0.00',
  `is_amount_discount` tinyint(1) NOT NULL DEFAULT '0',
  `allow_cancellation` tinyint(1) NOT NULL DEFAULT '1',
  `per_seat_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `min_seats_limit` int unsigned NOT NULL,
  `max_seats_limit` int unsigned NOT NULL,
  `trial_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `trial_duration` int unsigned NOT NULL,
  `allow_query_overrides` tinyint(1) NOT NULL DEFAULT '0',
  `allow_plan_changes` tinyint(1) NOT NULL DEFAULT '0',
  `plan_map` text COLLATE utf8mb4_unicode_ci,
  `refund_period` int unsigned DEFAULT NULL,
  `webhook_configuration` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `recurring_product_ids` text COLLATE utf8mb4_unicode_ci,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_id` int unsigned DEFAULT NULL,
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `promo_price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `registration_required` tinyint(1) NOT NULL DEFAULT '0',
  `use_inventory_management` tinyint(1) NOT NULL DEFAULT '0',
  `optional_product_ids` text COLLATE utf8mb4_unicode_ci,
  `optional_recurring_product_ids` text COLLATE utf8mb4_unicode_ci,
  `steps` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remaining_cycles` int DEFAULT '-1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `subscriptions_company_id_name_unique` (`company_id`,`name`),
  KEY `billing_subscriptions_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  CONSTRAINT `billing_subscriptions_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `event_id` int unsigned DEFAULT NULL,
  `type_id` int unsigned DEFAULT NULL,
  `log` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `system_logs_company_id_foreign` (`company_id`),
  KEY `system_logs_client_id_foreign` (`client_id`),
  CONSTRAINT `system_logs_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `system_logs_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_statuses`
--

DROP TABLE IF EXISTS `task_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_statuses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `status_sort_order` int DEFAULT NULL,
  `color` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#fff',
  `status_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_statuses_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `task_statuses_user_id_foreign` (`user_id`),
  CONSTRAINT `task_statuses_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `task_statuses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_statuses`
--

LOCK TABLES `task_statuses` WRITE;
/*!40000 ALTER TABLE `task_statuses` DISABLE KEYS */;
INSERT INTO `task_statuses` VALUES (1,'Backlog',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL,NULL,'#fff',1),(2,'Ready to do',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL,NULL,'#fff',2),(3,'In progress',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL,NULL,'#fff',3),(4,'Done',1,1,0,'2026-09-16 07:56:54.000000','2026-09-16 07:56:54.000000',NULL,NULL,'#fff',4);
/*!40000 ALTER TABLE `task_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `client_id` int unsigned DEFAULT NULL,
  `invoice_id` int unsigned DEFAULT NULL,
  `project_id` int unsigned DEFAULT NULL,
  `status_id` int unsigned DEFAULT NULL,
  `status_sort_order` int DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `duration` int unsigned DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_running` tinyint(1) NOT NULL DEFAULT '0',
  `time_log` text COLLATE utf8mb4_unicode_ci,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rate` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `invoice_documents` tinyint(1) NOT NULL DEFAULT '0',
  `is_date_based` tinyint(1) NOT NULL DEFAULT '0',
  `status_order` int DEFAULT NULL,
  `calculated_start_date` date DEFAULT NULL,
  `hash` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tasks_company_id_number_unique` (`company_id`,`number`),
  KEY `tasks_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `tasks_user_id_foreign` (`user_id`),
  KEY `tasks_invoice_id_foreign` (`invoice_id`),
  KEY `tasks_client_id_foreign` (`client_id`),
  KEY `tasks_company_id_index` (`company_id`),
  KEY `tasks_hash_index` (`hash`),
  CONSTRAINT `tasks_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tasks_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tasks_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tasks_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tax_rates`
--

DROP TABLE IF EXISTS `tax_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tax_rates` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `tax_rates_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `tax_rates_user_id_foreign` (`user_id`),
  KEY `tax_rates_company_id_index` (`company_id`),
  CONSTRAINT `tax_rates_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tax_rates_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tax_rates`
--

LOCK TABLES `tax_rates` WRITE;
/*!40000 ALTER TABLE `tax_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `tax_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timezones`
--

DROP TABLE IF EXISTS `timezones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timezones` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `utc_offset` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timezones`
--

LOCK TABLES `timezones` WRITE;
/*!40000 ALTER TABLE `timezones` DISABLE KEYS */;
INSERT INTO `timezones` VALUES (1,'Pacific/Midway','(GMT-11:00) Midway Island',-39600),(2,'Pacific/Pago_Pago','(GMT-11:00) Samoa',-39600),(3,'Pacific/Honolulu','(GMT-10:00) Hawaii',-36000),(4,'America/Anchorage','(GMT-09:00) Alaska',-32400),(5,'America/Los_Angeles','(GMT-08:00) Pacific Time (US & Canada)',-28800),(6,'America/Tijuana','(GMT-08:00) Tijuana',-28800),(7,'America/Phoenix','(GMT-07:00) Arizona',-25200),(8,'America/Denver','(GMT-07:00) Mountain Time (US & Canada)',-25200),(9,'America/Chihuahua','(GMT-07:00) Chihuahua',-25200),(10,'America/Mazatlan','(GMT-07:00) Mazatlan',-25200),(11,'America/Mexico_City','(GMT-06:00) Mexico City',-21600),(12,'America/Monterrey','(GMT-06:00) Monterrey',-21600),(13,'America/Regina','(GMT-06:00) Saskatchewan',-21600),(14,'America/Chicago','(GMT-06:00) Central Time (US & Canada)',-21600),(15,'America/New_York','(GMT-05:00) Eastern Time (US & Canada)',-18000),(16,'America/Indiana/Indianapolis','(GMT-05:00) Indiana (East)',-18000),(17,'America/Bogota','(GMT-05:00) Bogota',-18000),(18,'America/Lima','(GMT-05:00) Lima',-18000),(19,'America/Caracas','(GMT-04:00) Caracas',-14400),(20,'America/Halifax','(GMT-04:00) Atlantic Time (Canada)',-14400),(21,'America/La_Paz','(GMT-04:00) La Paz',-14400),(22,'America/Santiago','(GMT-04:00) Santiago',-14400),(23,'America/St_Johns','(GMT-03:30) Newfoundland',-12600),(24,'America/Argentina/Buenos_Aires','(GMT-03:00) Buenos Aires',-10800),(25,'America/Godthab','(GMT-03:00) Greenland',-10800),(26,'America/Sao_Paulo','(GMT-03:00) Sao Paulo',-10800),(27,'Atlantic/Stanley','(GMT-02:00) Stanley',-7200),(28,'Atlantic/Azores','(GMT-01:00) Azores',-3600),(29,'Atlantic/Cape_Verde','(GMT-01:00) Cape Verde Is.',-3600),(30,'Africa/Casablanca','(GMT) Casablanca',0),(31,'Europe/Dublin','(GMT) Dublin',0),(32,'Europe/Lisbon','(GMT) Lisbon',0),(33,'Europe/London','(GMT) London',0),(34,'Africa/Monrovia','(GMT) Monrovia',0),(35,'Europe/Amsterdam','(GMT+01:00) Amsterdam',3600),(36,'Europe/Belgrade','(GMT+01:00) Belgrade',3600),(37,'Europe/Berlin','(GMT+01:00) Berlin',3600),(38,'Europe/Bratislava','(GMT+01:00) Bratislava',3600),(39,'Europe/Brussels','(GMT+01:00) Brussels',3600),(40,'Europe/Budapest','(GMT+01:00) Budapest',3600),(41,'Europe/Copenhagen','(GMT+01:00) Copenhagen',3600),(42,'Europe/Ljubljana','(GMT+01:00) Ljubljana',3600),(43,'Europe/Madrid','(GMT+01:00) Madrid',3600),(44,'Europe/Paris','(GMT+01:00) Paris',3600),(45,'Europe/Prague','(GMT+01:00) Prague',3600),(46,'Europe/Rome','(GMT+01:00) Rome',3600),(47,'Europe/Sarajevo','(GMT+01:00) Sarajevo',3600),(48,'Europe/Skopje','(GMT+01:00) Skopje',3600),(49,'Europe/Stockholm','(GMT+01:00) Stockholm',3600),(50,'Europe/Vienna','(GMT+01:00) Vienna',3600),(51,'Europe/Warsaw','(GMT+01:00) Warsaw',3600),(52,'Europe/Zagreb','(GMT+01:00) Zagreb',3600),(53,'Europe/Athens','(GMT+02:00) Athens',7200),(54,'Europe/Bucharest','(GMT+02:00) Bucharest',7200),(55,'Africa/Cairo','(GMT+02:00) Cairo',7200),(56,'Africa/Harare','(GMT+02:00) Harare',7200),(57,'Europe/Helsinki','(GMT+02:00) Helsinki',7200),(58,'Asia/Jerusalem','(GMT+02:00) Jerusalem',7200),(59,'Europe/Kiev','(GMT+02:00) Kyiv',7200),(60,'Europe/Minsk','(GMT+02:00) Minsk',7200),(61,'Europe/Riga','(GMT+02:00) Riga',7200),(62,'Europe/Sofia','(GMT+02:00) Sofia',7200),(63,'Europe/Tallinn','(GMT+02:00) Tallinn',7200),(64,'Europe/Vilnius','(GMT+02:00) Vilnius',7200),(65,'Europe/Istanbul','(GMT+03:00) Istanbul',10800),(66,'Asia/Baghdad','(GMT+03:00) Baghdad',10800),(67,'Asia/Kuwait','(GMT+03:00) Kuwait',10800),(68,'Africa/Nairobi','(GMT+03:00) Nairobi',10800),(69,'Asia/Riyadh','(GMT+03:00) Riyadh',10800),(70,'Asia/Tehran','(GMT+03:30) Tehran',12600),(71,'Europe/Moscow','(GMT+04:00) Moscow',14400),(72,'Asia/Baku','(GMT+04:00) Baku',14400),(73,'Europe/Volgograd','(GMT+04:00) Volgograd',14400),(74,'Asia/Muscat','(GMT+04:00) Muscat',14400),(75,'Asia/Tbilisi','(GMT+04:00) Tbilisi',14400),(76,'Asia/Yerevan','(GMT+04:00) Yerevan',14400),(77,'Asia/Kabul','(GMT+04:30) Kabul',16200),(78,'Asia/Karachi','(GMT+05:00) Karachi',18000),(79,'Asia/Tashkent','(GMT+05:00) Tashkent',18000),(80,'Asia/Kolkata','(GMT+05:30) Kolkata',19800),(81,'Asia/Kathmandu','(GMT+05:45) Kathmandu',20700),(82,'Asia/Yekaterinburg','(GMT+06:00) Ekaterinburg',21600),(83,'Asia/Almaty','(GMT+06:00) Almaty',21600),(84,'Asia/Dhaka','(GMT+06:00) Dhaka',21600),(85,'Asia/Novosibirsk','(GMT+07:00) Novosibirsk',25200),(86,'Asia/Bangkok','(GMT+07:00) Bangkok',25200),(87,'Asia/Ho_Chi_Minh','(GMT+07.00) Ho Chi Minh',25200),(88,'Asia/Jakarta','(GMT+07:00) Jakarta',25200),(89,'Asia/Krasnoyarsk','(GMT+08:00) Krasnoyarsk',28800),(90,'Asia/Chongqing','(GMT+08:00) Chongqing',28800),(91,'Asia/Hong_Kong','(GMT+08:00) Hong Kong',28800),(92,'Asia/Kuala_Lumpur','(GMT+08:00) Kuala Lumpur',28800),(93,'Australia/Perth','(GMT+08:00) Perth',28800),(94,'Asia/Singapore','(GMT+08:00) Singapore',28800),(95,'Asia/Taipei','(GMT+08:00) Taipei',28800),(96,'Asia/Ulaanbaatar','(GMT+08:00) Ulaan Bataar',28800),(97,'Asia/Urumqi','(GMT+08:00) Urumqi',28800),(98,'Asia/Irkutsk','(GMT+09:00) Irkutsk',32400),(99,'Asia/Seoul','(GMT+09:00) Seoul',32400),(100,'Asia/Tokyo','(GMT+09:00) Tokyo',32400),(101,'Australia/Adelaide','(GMT+09:30) Adelaide',34200),(102,'Australia/Darwin','(GMT+09:30) Darwin',34200),(103,'Asia/Yakutsk','(GMT+10:00) Yakutsk',36000),(104,'Australia/Brisbane','(GMT+10:00) Brisbane',36000),(105,'Australia/Sydney','(GMT+10:00) Canberra',36000),(106,'Pacific/Guam','(GMT+10:00) Guam',36000),(107,'Australia/Hobart','(GMT+10:00) Hobart',36000),(108,'Australia/Melbourne','(GMT+10:00) Melbourne',36000),(109,'Pacific/Port_Moresby','(GMT+10:00) Port Moresby',36000),(110,'Australia/Sydney','(GMT+10:00) Sydney',36000),(111,'Asia/Vladivostok','(GMT+11:00) Vladivostok',39600),(112,'Asia/Magadan','(GMT+12:00) Magadan',43200),(113,'Pacific/Auckland','(GMT+12:00) Auckland',43200),(114,'Pacific/Fiji','(GMT+12:00) Fiji',43200),(115,'Asia/Dubai','(GMT+04:00) Dubai',14400);
/*!40000 ALTER TABLE `timezones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_events`
--

DROP TABLE IF EXISTS `transaction_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_events` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int unsigned NOT NULL,
  `invoice_id` int unsigned NOT NULL,
  `payment_id` int unsigned NOT NULL,
  `credit_id` int unsigned NOT NULL,
  `client_balance` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `client_paid_to_date` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `client_credit_balance` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `invoice_balance` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `invoice_amount` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `invoice_partial` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `invoice_paid_to_date` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `invoice_status` int unsigned DEFAULT NULL,
  `payment_amount` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `payment_applied` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `payment_refunded` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `payment_status` int unsigned DEFAULT NULL,
  `paymentables` mediumtext COLLATE utf8mb4_unicode_ci,
  `event_id` int unsigned NOT NULL,
  `timestamp` int unsigned NOT NULL,
  `payment_request` mediumtext COLLATE utf8mb4_unicode_ci,
  `metadata` mediumtext COLLATE utf8mb4_unicode_ci,
  `credit_balance` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `credit_amount` decimal(16,4) NOT NULL DEFAULT '0.0000',
  `credit_status` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_events_client_id_index` (`client_id`),
  CONSTRAINT `transaction_events_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_events`
--

LOCK TABLES `transaction_events` WRITE;
/*!40000 ALTER TABLE `transaction_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int unsigned NOT NULL,
  `first_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `confirmation_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `theme_id` int DEFAULT NULL,
  `failed_logins` smallint DEFAULT NULL,
  `referral_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oauth_user_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oauth_user_token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oauth_provider_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `google_2fa_secret` text COLLATE utf8mb4_unicode_ci,
  `accepted_terms_version` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_width` int unsigned DEFAULT NULL,
  `avatar_height` int unsigned DEFAULT NULL,
  `avatar_size` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_login` datetime DEFAULT NULL,
  `signature` mediumtext COLLATE utf8mb4_unicode_ci,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `oauth_user_refresh_token` text COLLATE utf8mb4_unicode_ci,
  `last_confirmed_email_address` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `has_password` tinyint(1) NOT NULL DEFAULT '0',
  `oauth_user_token_expiry` datetime DEFAULT NULL,
  `sms_verification_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verified_phone_number` tinyint(1) NOT NULL DEFAULT '0',
  `shopify_user_id` bigint unsigned DEFAULT NULL,
  `language_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_logged_in_notification` tinyint(1) NOT NULL DEFAULT '1',
  `referral_meta` mediumtext COLLATE utf8mb4_unicode_ci,
  `referral_earnings` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_oauth_user_id_oauth_provider_id_unique` (`oauth_user_id`,`oauth_provider_id`),
  KEY `users_account_id_index` (`account_id`),
  KEY `users_shopify_user_id_index` (`shopify_user_id`),
  CONSTRAINT `users_account_id_foreign` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'New','User','',NULL,NULL,'admin@admin.com','2026-09-16 07:56:54','iUpkmWWqhfGqq9wqFSXBB9d0mpyaSjji',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'$2y$10$sDdm0QF4kCWH248xJtfwXOYVMoDn1VVt.3gwQY1FPB70Pfp5.sY7m','53MkoTD4jJ',NULL,NULL,NULL,NULL,'2026-09-16 07:56:54.074671','2026-09-16 07:56:54.082782',NULL,NULL,NULL,0,NULL,NULL,0,NULL,NULL,1,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_contacts`
--

DROP TABLE IF EXISTS `vendor_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `vendor_id` int unsigned NOT NULL,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `first_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `send_email` tinyint(1) NOT NULL DEFAULT '0',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `confirmation_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `last_login` timestamp NULL DEFAULT NULL,
  `failed_logins` smallint DEFAULT NULL,
  `oauth_user_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oauth_provider_id` int unsigned DEFAULT NULL,
  `google_2fa_secret` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `accepted_terms_version` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `contact_key` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_contacts_oauth_user_id_unique` (`oauth_user_id`),
  UNIQUE KEY `vendor_contacts_oauth_provider_id_unique` (`oauth_provider_id`),
  KEY `vendor_contacts_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `vendor_contacts_user_id_foreign` (`user_id`),
  KEY `vendor_contacts_vendor_id_index` (`vendor_id`),
  KEY `vendor_contacts_company_id_email_deleted_at_index` (`company_id`,`email`,`deleted_at`),
  KEY `vendor_contacts_contact_key(20)_index` (`contact_key`(20)),
  KEY `vendor_contacts_email_index` (`email`),
  CONSTRAINT `vendor_contacts_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `vendor_contacts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `vendor_contacts_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_contacts`
--

LOCK TABLES `vendor_contacts` WRITE;
/*!40000 ALTER TABLE `vendor_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendor_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendors`
--

DROP TABLE IF EXISTS `vendors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `assigned_user_id` int unsigned DEFAULT NULL,
  `company_id` int unsigned NOT NULL,
  `currency_id` int unsigned DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` int unsigned DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `private_notes` text COLLATE utf8mb4_unicode_ci,
  `website` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT '0',
  `vat_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_value1` text COLLATE utf8mb4_unicode_ci,
  `custom_value2` text COLLATE utf8mb4_unicode_ci,
  `custom_value3` text COLLATE utf8mb4_unicode_ci,
  `custom_value4` text COLLATE utf8mb4_unicode_ci,
  `vendor_hash` text COLLATE utf8mb4_unicode_ci,
  `public_notes` text COLLATE utf8mb4_unicode_ci,
  `id_number` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language_id` int unsigned DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `classification` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_tax_exempt` tinyint(1) NOT NULL DEFAULT '0',
  `routing_id` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendors_company_id_number_unique` (`company_id`,`number`),
  KEY `vendors_company_id_deleted_at_index` (`company_id`,`deleted_at`),
  KEY `vendors_user_id_foreign` (`user_id`),
  KEY `vendors_country_id_foreign` (`country_id`),
  KEY `vendors_currency_id_foreign` (`currency_id`),
  CONSTRAINT `vendors_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `vendors_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `vendors_currency_id_foreign` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`),
  CONSTRAINT `vendors_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendors`
--

LOCK TABLES `vendors` WRITE;
/*!40000 ALTER TABLE `vendors` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhooks`
--

DROP TABLE IF EXISTS `webhooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhooks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `event_id` int unsigned DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `target_url` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `format` enum('JSON','UBL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'JSON',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `deleted_at` timestamp(6) NULL DEFAULT NULL,
  `rest_method` text COLLATE utf8mb4_unicode_ci,
  `headers` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `subscriptions_company_id_foreign` (`company_id`),
  KEY `subscriptions_event_id_company_id_index` (`event_id`,`company_id`),
  CONSTRAINT `subscriptions_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhooks`
--

LOCK TABLES `webhooks` WRITE;
/*!40000 ALTER TABLE `webhooks` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhooks` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-16  7:56:55
