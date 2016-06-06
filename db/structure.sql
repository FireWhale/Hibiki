-- MySQL dump 10.13  Distrib 5.6.17, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: hibiki_development
-- ------------------------------------------------------
-- Server version	5.6.17-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `album_events`
--

DROP TABLE IF EXISTS `album_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `album_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_album_events_on_album_id` (`album_id`),
  KEY `index_album_events_on_event_id` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8474 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `album_organizations`
--

DROP TABLE IF EXISTS `album_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `album_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_album_organizations_on_album_id` (`album_id`),
  KEY `index_album_organizations_on_category` (`category`),
  KEY `index_album_organizations_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47774 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `album_sources`
--

DROP TABLE IF EXISTS `album_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `album_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_album_sources_on_album_id` (`album_id`),
  KEY `index_album_sources_on_source_id` (`source_id`)
) ENGINE=InnoDB AUTO_INCREMENT=78619 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `album_translations`
--

DROP TABLE IF EXISTS `album_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `album_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_album_translations_on_album_id` (`album_id`),
  KEY `index_album_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=16413 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `albums`
--

DROP TABLE IF EXISTS `albums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `albums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `synonyms` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `classification` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `catalog_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `popularity` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `namehash` text COLLATE utf8_unicode_ci,
  `release_date_bitmask` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_albums_on_catalognumber` (`catalog_number`),
  KEY `index_albums_on_classification` (`classification`),
  KEY `index_albums_on_popularity` (`popularity`),
  KEY `index_albums_on_releasedate` (`release_date`),
  KEY `index_albums_on_status` (`status`),
  KEY `index_albums_on_internal_name` (`internal_name`),
  KEY `index_albums_on_synonyms` (`synonyms`)
) ENGINE=InnoDB AUTO_INCREMENT=40443 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_album_translations`
--

DROP TABLE IF EXISTS `artist_album_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_album_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_album_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artist_album_translations_on_artist_album_id` (`artist_album_id`),
  KEY `index_artist_album_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_albums`
--

DROP TABLE IF EXISTS `artist_albums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_albums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) DEFAULT NULL,
  `album_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artist_albums_on_album_id` (`album_id`),
  KEY `index_artist_albums_on_artist_id` (`artist_id`),
  KEY `index_artist_albums_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=315511 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_organizations`
--

DROP TABLE IF EXISTS `artist_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artist_organizations_on_artist_id` (`artist_id`),
  KEY `index_artist_organizations_on_category` (`category`),
  KEY `index_artist_organizations_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_song_translations`
--

DROP TABLE IF EXISTS `artist_song_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_song_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_song_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artist_song_translations_on_artist_song_id` (`artist_song_id`),
  KEY `index_artist_song_translations_on_locale` (`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_songs`
--

DROP TABLE IF EXISTS `artist_songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_songs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) DEFAULT NULL,
  `song_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artist_songs_on_artist_id` (`artist_id`),
  KEY `index_artist_songs_on_category` (`category`),
  KEY `index_artist_songs_on_song_id` (`song_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2030 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artist_translations`
--

DROP TABLE IF EXISTS `artist_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artist_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_artist_translations_on_artist_id` (`artist_id`),
  KEY `index_artist_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artists`
--

DROP TABLE IF EXISTS `artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `synonyms` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activity` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `synopsis` text COLLATE utf8_unicode_ci,
  `popularity` int(11) DEFAULT NULL,
  `debut_date` date DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `namehash` text COLLATE utf8_unicode_ci,
  `birth_date_bitmask` int(11) DEFAULT NULL,
  `gender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `blood_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birth_place` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `debut_date_bitmask` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_artists_on_activity` (`activity`),
  KEY `index_artists_on_birthdate` (`birth_date`),
  KEY `index_artists_on_category` (`category`),
  KEY `index_artists_on_dbcomplete` (`db_status`),
  KEY `index_artists_on_debutdate` (`debut_date`),
  KEY `index_artists_on_popularity` (`popularity`),
  KEY `index_artists_on_status` (`status`),
  KEY `index_artists_on_internal_name` (`internal_name`),
  KEY `index_artists_on_synonyms` (`synonyms`)
) ENGINE=InnoDB AUTO_INCREMENT=52101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collections`
--

DROP TABLE IF EXISTS `collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `collected_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `relationship` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `collected_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_obtained` date DEFAULT NULL,
  `date_obtained_bitmask` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_collections_on_rating` (`rating`),
  KEY `index_collections_on_user_id` (`user_id`),
  KEY `index_collections_on_relationship` (`relationship`),
  KEY `index_collections_on_collected_id` (`collected_id`),
  KEY `index_collections_on_collected_type` (`collected_type`)
) ENGINE=InnoDB AUTO_INCREMENT=402 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_translations`
--

DROP TABLE IF EXISTS `event_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_event_translations_on_event_id` (`event_id`),
  KEY `index_event_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=519 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `db_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shorthand` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `internal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_events_on_start_date` (`start_date`),
  KEY `index_events_on_end_date` (`end_date`),
  KEY `index_events_on_db_status` (`db_status`),
  KEY `index_events_on_shorthand` (`shorthand`),
  KEY `index_events_on_internal_name` (`internal_name`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `imagelists`
--

DROP TABLE IF EXISTS `imagelists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imagelists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `model_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_imagelists_on_image_id` (`image_id`),
  KEY `index_imagelists_on_model_id` (`model_id`),
  KEY `index_imagelists_on_model_type` (`model_type`)
) ENGINE=InnoDB AUTO_INCREMENT=142081 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `primary_flag` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rating` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `llimagelink` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `thumb_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `medium_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `medium_width` int(11) DEFAULT NULL,
  `medium_height` int(11) DEFAULT NULL,
  `thumb_width` int(11) DEFAULT NULL,
  `thumb_height` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_on_category` (`primary_flag`),
  KEY `index_images_on_rating` (`rating`)
) ENGINE=InnoDB AUTO_INCREMENT=142085 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `resolution` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `difficulty` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_issues_on_category` (`category`),
  KEY `index_issues_on_status` (`status`),
  KEY `index_issues_on_priority` (`priority`),
  KEY `index_issues_on_visibility` (`visibility`),
  KEY `index_issues_on_resolution` (`resolution`),
  KEY `index_issues_on_difficulty` (`difficulty`),
  KEY `index_issues_on_created_at` (`created_at`),
  KEY `index_issues_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loglists`
--

DROP TABLE IF EXISTS `loglists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loglists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `model_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_loglists_on_log_id` (`log_id`),
  KEY `index_loglists_on_model_id` (`model_id`),
  KEY `index_loglists_on_model_type` (`model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` mediumtext COLLATE utf8_unicode_ci,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lyrics`
--

DROP TABLE IF EXISTS `lyrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lyrics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `song_id` int(11) DEFAULT NULL,
  `lyrics` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_lyrics_on_song_id` (`song_id`),
  KEY `index_lyrics_on_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization_translations`
--

DROP TABLE IF EXISTS `organization_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_organization_translations_on_organization_id` (`organization_id`),
  KEY `index_organization_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizations`
--

DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `synonyms` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activity` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `synopsis` text COLLATE utf8_unicode_ci,
  `established` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `namehash` text COLLATE utf8_unicode_ci,
  `established_bitmask` int(11) DEFAULT NULL,
  `popularity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_organizations_on_activity` (`activity`),
  KEY `index_organizations_on_category` (`category`),
  KEY `index_organizations_on_dbcomplete` (`db_status`),
  KEY `index_organizations_on_established` (`established`),
  KEY `index_organizations_on_status` (`status`),
  KEY `index_organizations_on_popularity` (`popularity`),
  KEY `index_organizations_on_internal_name` (`internal_name`),
  KEY `index_organizations_on_synonyms` (`synonyms`)
) ENGINE=InnoDB AUTO_INCREMENT=5113 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `postlists`
--

DROP TABLE IF EXISTS `postlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `postlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `model_id` int(11) DEFAULT NULL,
  `model_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_postlists_on_post_id` (`post_id`),
  KEY `index_postlists_on_model_id` (`model_id`),
  KEY `index_postlists_on_model_type` (`model_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4946 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` mediumblob,
  `visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_posts_on_category` (`category`),
  KEY `index_posts_on_visibility` (`visibility`),
  KEY `index_posts_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=850 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `references`
--

DROP TABLE IF EXISTS `references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_id` int(11) DEFAULT NULL,
  `model_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_references_on_model_id` (`model_id`),
  KEY `index_references_on_model_type` (`model_type`),
  KEY `index_references_on_site_name` (`site_name`)
) ENGINE=InnoDB AUTO_INCREMENT=42395 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_albums`
--

DROP TABLE IF EXISTS `related_albums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_albums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album1_id` int(11) DEFAULT NULL,
  `album2_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_related_albums_on_album1_id` (`album1_id`),
  KEY `index_related_albums_on_album2_id` (`album2_id`),
  KEY `index_related_albums_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=736 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_artists`
--

DROP TABLE IF EXISTS `related_artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_artists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist1_id` int(11) DEFAULT NULL,
  `artist2_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_related_artists_on_artist1_id` (`artist1_id`),
  KEY `index_related_artists_on_artist2_id` (`artist2_id`),
  KEY `index_related_artists_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_organizations`
--

DROP TABLE IF EXISTS `related_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization1_id` int(11) DEFAULT NULL,
  `organization2_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_related_organizations_on_organization1_id` (`organization1_id`),
  KEY `index_related_organizations_on_organization2_id` (`organization2_id`),
  KEY `index_related_organizations_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_songs`
--

DROP TABLE IF EXISTS `related_songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_songs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `song1_id` int(11) DEFAULT NULL,
  `song2_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_related_songs_on_song1_id` (`song1_id`),
  KEY `index_related_songs_on_song2_id` (`song2_id`),
  KEY `index_related_songs_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_sources`
--

DROP TABLE IF EXISTS `related_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source1_id` int(11) DEFAULT NULL,
  `source2_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_related_sources_on_source1_id` (`source1_id`),
  KEY `index_related_sources_on_source2_id` (`source2_id`),
  KEY `index_related_sources_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=361 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `seasons`
--

DROP TABLE IF EXISTS `seasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_seasons_on_start_date` (`start_date`),
  KEY `index_seasons_on_end_date` (`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `song_sources`
--

DROP TABLE IF EXISTS `song_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `song_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `song_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `classification` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `op_ed_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ep_numbers` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_song_sources_on_song_id` (`song_id`),
  KEY `index_song_sources_on_source_id` (`source_id`),
  KEY `index_song_sources_on_classification` (`classification`)
) ENGINE=InnoDB AUTO_INCREMENT=577 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `song_translations`
--

DROP TABLE IF EXISTS `song_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `song_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `song_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `lyrics` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_song_translations_on_song_id` (`song_id`),
  KEY `index_song_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=87852 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `songs`
--

DROP TABLE IF EXISTS `songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `songs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `namehash` text COLLATE utf8_unicode_ci,
  `album_id` int(11) DEFAULT NULL,
  `track_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `length` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `release_date` date DEFAULT NULL,
  `release_date_bitmask` int(11) DEFAULT NULL,
  `synonyms` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `disc_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_songs_on_album_id` (`album_id`),
  KEY `index_songs_on_status` (`status`),
  KEY `index_songs_on_track_number` (`track_number`),
  KEY `index_songs_on_disc_number` (`disc_number`),
  KEY `index_songs_on_release_date` (`release_date`),
  KEY `index_songs_on_internal_name` (`internal_name`),
  KEY `index_songs_on_synonyms` (`synonyms`)
) ENGINE=InnoDB AUTO_INCREMENT=554345 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `source_organizations`
--

DROP TABLE IF EXISTS `source_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `source_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_source_organizations_on_source_id` (`source_id`),
  KEY `index_source_organizations_on_organization_id` (`organization_id`),
  KEY `index_source_organizations_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `source_seasons`
--

DROP TABLE IF EXISTS `source_seasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `source_seasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_source_seasons_on_source_id` (`source_id`),
  KEY `index_source_seasons_on_season_id` (`season_id`),
  KEY `index_source_seasons_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=168 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `source_translations`
--

DROP TABLE IF EXISTS `source_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `source_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_source_translations_on_source_id` (`source_id`),
  KEY `index_source_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `synonyms` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activity` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  `private_info` text COLLATE utf8_unicode_ci,
  `synopsis` text COLLATE utf8_unicode_ci,
  `popularity` int(11) DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `namehash` text COLLATE utf8_unicode_ci,
  `end_date` date DEFAULT NULL,
  `release_date_bitmask` int(11) DEFAULT NULL,
  `end_date_bitmask` int(11) DEFAULT NULL,
  `plot_summary` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_sources_on_activity` (`activity`),
  KEY `index_sources_on_category` (`category`),
  KEY `index_sources_on_dbcomplete` (`db_status`),
  KEY `index_sources_on_popularity` (`popularity`),
  KEY `index_sources_on_releasedate` (`release_date`),
  KEY `index_sources_on_status` (`status`),
  KEY `index_sources_on_end_date` (`end_date`),
  KEY `index_sources_on_internal_name` (`internal_name`(255)),
  KEY `index_sources_on_synonyms` (`synonyms`)
) ENGINE=InnoDB AUTO_INCREMENT=17519 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag_translations`
--

DROP TABLE IF EXISTS `tag_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `info` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_tag_translations_on_tag_id` (`tag_id`),
  KEY `index_tag_translations_on_locale` (`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taglists`
--

DROP TABLE IF EXISTS `taglists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taglists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `subject_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taglists_on_subject_id` (`subject_id`),
  KEY `index_taglists_on_subject_type` (`subject_type`),
  KEY `index_taglists_on_tag_id` (`tag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20144 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `classification` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `model_bitmask` int(11) DEFAULT NULL,
  `visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tags_on_visibility` (`visibility`),
  KEY `index_tags_on_internal_name` (`internal_name`),
  KEY `index_tags_on_classification` (`classification`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile` text COLLATE utf8_unicode_ci,
  `birth_date` date DEFAULT NULL,
  `sex` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `privacy` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `security` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stylesheet` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `usernames` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `display_bitmask` int(11) DEFAULT NULL,
  `language_settings` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `artist_language_settings` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tracklist_export_bitmask` int(11) DEFAULT NULL,
  `perishable_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `birth_date_bitmask` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_created_at` (`created_at`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_location` (`location`),
  KEY `index_users_on_name` (`name`),
  KEY `index_users_on_stylesheet` (`stylesheet`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `watchlists`
--

DROP TABLE IF EXISTS `watchlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watchlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `watched_id` int(11) DEFAULT NULL,
  `watched_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `position` int(11) DEFAULT NULL,
  `grouping_category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_watchlists_on_user_id` (`user_id`),
  KEY `index_watchlists_on_watched_id` (`watched_id`),
  KEY `index_watchlists_on_watched_type` (`watched_type`),
  KEY `index_watchlists_on_grouping_category` (`grouping_category`),
  KEY `index_watchlists_on_position` (`position`)
) ENGINE=InnoDB AUTO_INCREMENT=248 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-05-31 21:49:50
INSERT INTO schema_migrations (version) VALUES ('20130813222030');

INSERT INTO schema_migrations (version) VALUES ('20130813222036');

INSERT INTO schema_migrations (version) VALUES ('20130813222042');

INSERT INTO schema_migrations (version) VALUES ('20130813222048');

INSERT INTO schema_migrations (version) VALUES ('20130813222055');

INSERT INTO schema_migrations (version) VALUES ('20130813222101');

INSERT INTO schema_migrations (version) VALUES ('20130813222107');

INSERT INTO schema_migrations (version) VALUES ('20130813222113');

INSERT INTO schema_migrations (version) VALUES ('20130813222120');

INSERT INTO schema_migrations (version) VALUES ('20130813222126');

INSERT INTO schema_migrations (version) VALUES ('20130813222132');

INSERT INTO schema_migrations (version) VALUES ('20130813222138');

INSERT INTO schema_migrations (version) VALUES ('20130813222144');

INSERT INTO schema_migrations (version) VALUES ('20130813222150');

INSERT INTO schema_migrations (version) VALUES ('20130813222156');

INSERT INTO schema_migrations (version) VALUES ('20130813222202');

INSERT INTO schema_migrations (version) VALUES ('20130813222208');

INSERT INTO schema_migrations (version) VALUES ('20130813222214');

INSERT INTO schema_migrations (version) VALUES ('20130813222220');

INSERT INTO schema_migrations (version) VALUES ('20130813222227');

INSERT INTO schema_migrations (version) VALUES ('20130830071407');

INSERT INTO schema_migrations (version) VALUES ('20130910163327');

INSERT INTO schema_migrations (version) VALUES ('20130920001007');

INSERT INTO schema_migrations (version) VALUES ('20130920001341');

INSERT INTO schema_migrations (version) VALUES ('20130920002914');

INSERT INTO schema_migrations (version) VALUES ('20130920050025');

INSERT INTO schema_migrations (version) VALUES ('20130920052340');

INSERT INTO schema_migrations (version) VALUES ('20130920204815');

INSERT INTO schema_migrations (version) VALUES ('20130920204929');

INSERT INTO schema_migrations (version) VALUES ('20130920220605');

INSERT INTO schema_migrations (version) VALUES ('20130920220908');

INSERT INTO schema_migrations (version) VALUES ('20130922012830');

INSERT INTO schema_migrations (version) VALUES ('20130922163441');

INSERT INTO schema_migrations (version) VALUES ('20130924104710');

INSERT INTO schema_migrations (version) VALUES ('20131010003533');

INSERT INTO schema_migrations (version) VALUES ('20131011215609');

INSERT INTO schema_migrations (version) VALUES ('20131012232258');

INSERT INTO schema_migrations (version) VALUES ('20131015002932');

INSERT INTO schema_migrations (version) VALUES ('20131015005857');

INSERT INTO schema_migrations (version) VALUES ('20131015070358');

INSERT INTO schema_migrations (version) VALUES ('20131016015829');

INSERT INTO schema_migrations (version) VALUES ('20131019191947');

INSERT INTO schema_migrations (version) VALUES ('20131019202333');

INSERT INTO schema_migrations (version) VALUES ('20131019212029');

INSERT INTO schema_migrations (version) VALUES ('20131020051640');

INSERT INTO schema_migrations (version) VALUES ('20131020082603');

INSERT INTO schema_migrations (version) VALUES ('20131106205646');

INSERT INTO schema_migrations (version) VALUES ('20131106210938');

INSERT INTO schema_migrations (version) VALUES ('20131118144632');

INSERT INTO schema_migrations (version) VALUES ('20131118165232');

INSERT INTO schema_migrations (version) VALUES ('20131118165338');

INSERT INTO schema_migrations (version) VALUES ('20131119170505');

INSERT INTO schema_migrations (version) VALUES ('20131216195728');

INSERT INTO schema_migrations (version) VALUES ('20131216215419');

INSERT INTO schema_migrations (version) VALUES ('20131226222925');

INSERT INTO schema_migrations (version) VALUES ('20131226223615');

INSERT INTO schema_migrations (version) VALUES ('20131226223642');

INSERT INTO schema_migrations (version) VALUES ('20131227173753');

INSERT INTO schema_migrations (version) VALUES ('20131228062120');

INSERT INTO schema_migrations (version) VALUES ('20131229043714');

INSERT INTO schema_migrations (version) VALUES ('20131231211359');

INSERT INTO schema_migrations (version) VALUES ('20140101075014');

INSERT INTO schema_migrations (version) VALUES ('20140304203625');

INSERT INTO schema_migrations (version) VALUES ('20140304210203');

INSERT INTO schema_migrations (version) VALUES ('20140306052630');

INSERT INTO schema_migrations (version) VALUES ('20140308211038');

INSERT INTO schema_migrations (version) VALUES ('20140411175204');

INSERT INTO schema_migrations (version) VALUES ('20140417020323');

INSERT INTO schema_migrations (version) VALUES ('20140417033215');

INSERT INTO schema_migrations (version) VALUES ('20140417060309');

INSERT INTO schema_migrations (version) VALUES ('20140417061433');

INSERT INTO schema_migrations (version) VALUES ('20140417061907');

INSERT INTO schema_migrations (version) VALUES ('20140417062919');

INSERT INTO schema_migrations (version) VALUES ('20140417063448');

INSERT INTO schema_migrations (version) VALUES ('20140428201815');

INSERT INTO schema_migrations (version) VALUES ('20140428204842');

INSERT INTO schema_migrations (version) VALUES ('20140723211024');

INSERT INTO schema_migrations (version) VALUES ('20140806183421');

INSERT INTO schema_migrations (version) VALUES ('20141014135652');

INSERT INTO schema_migrations (version) VALUES ('20141014183714');

INSERT INTO schema_migrations (version) VALUES ('20141014200504');

INSERT INTO schema_migrations (version) VALUES ('20141021194140');

INSERT INTO schema_migrations (version) VALUES ('20141022180319');

INSERT INTO schema_migrations (version) VALUES ('20141023082146');

INSERT INTO schema_migrations (version) VALUES ('20141023174859');

INSERT INTO schema_migrations (version) VALUES ('20141031014136');

INSERT INTO schema_migrations (version) VALUES ('20141102032539');

INSERT INTO schema_migrations (version) VALUES ('20141102082621');

INSERT INTO schema_migrations (version) VALUES ('20141103032958');

INSERT INTO schema_migrations (version) VALUES ('20141127074938');

INSERT INTO schema_migrations (version) VALUES ('20150201070132');

INSERT INTO schema_migrations (version) VALUES ('20150204031448');

INSERT INTO schema_migrations (version) VALUES ('20150308190829');

INSERT INTO schema_migrations (version) VALUES ('20150319211947');

INSERT INTO schema_migrations (version) VALUES ('20150330222346');

INSERT INTO schema_migrations (version) VALUES ('20150430192742');

INSERT INTO schema_migrations (version) VALUES ('20150430215821');

INSERT INTO schema_migrations (version) VALUES ('20150430221155');

INSERT INTO schema_migrations (version) VALUES ('20150430222346');

INSERT INTO schema_migrations (version) VALUES ('20150512224020');

INSERT INTO schema_migrations (version) VALUES ('20150512225910');

INSERT INTO schema_migrations (version) VALUES ('20150525035414');

INSERT INTO schema_migrations (version) VALUES ('20150527040625');

INSERT INTO schema_migrations (version) VALUES ('20150527055702');

INSERT INTO schema_migrations (version) VALUES ('20150529022014');

INSERT INTO schema_migrations (version) VALUES ('20150531002504');

INSERT INTO schema_migrations (version) VALUES ('20150531022203');

INSERT INTO schema_migrations (version) VALUES ('20150531024531');

INSERT INTO schema_migrations (version) VALUES ('20150619072238');

INSERT INTO schema_migrations (version) VALUES ('20150624112027');

INSERT INTO schema_migrations (version) VALUES ('20160530204406');

INSERT INTO schema_migrations (version) VALUES ('20160601004630');

