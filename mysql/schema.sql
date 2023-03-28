-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 28, 2023 at 05:17 PM
-- Server version: 5.7.41-cll-lve
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `oskarasv_krya`
--
CREATE DATABASE IF NOT EXISTS `oskarasv_krya` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `oskarasv_krya`;


-- --------------------------------------------------------

--
-- Table structure for table `auth`
--

CREATE TABLE `auth` (
  `auth_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('WEB','BOT','TGAUTH','DA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `refresh_token` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_state`
--

CREATE TABLE `auth_state` (
  `auth_state_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `state_key` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel`
--

CREATE TABLE `channel` (
  `channel_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `channel_name` varchar(300) COLLATE utf8mb4_unicode_ci NOT NULL,
  `command_symbol` char(5) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '!',
  `auto_join` tinyint(1) NOT NULL DEFAULT '0',
  `allow_web_access` tinyint(1) NOT NULL DEFAULT '0',
  `trigger_period` int(11) NOT NULL DEFAULT '30',
  `default_notification` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '#user# PogChamp <3',
  `scan_messages` tinyint(1) DEFAULT '1',
  `on_spam_detect` int(1) DEFAULT '0',
  `priority` int(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel_command`
--

CREATE TABLE `channel_command` (
  `channel_command_id` int(10) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `command` char(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` char(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `check_type` int(11) DEFAULT '0',
  `level` int(2) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `cooldown` int(11) DEFAULT '30',
  `repeat_amount` int(11) NOT NULL DEFAULT '0',
  `reply_message` text COLLATE utf8mb4_unicode_ci,
  `additional_text` text COLLATE utf8mb4_unicode_ci,
  `used` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel_command_option`
--

CREATE TABLE `channel_command_option` (
  `channel_command_option_id` int(11) NOT NULL,
  `channel_command_id` int(11) DEFAULT NULL,
  `response` text COLLATE utf8mb4_unicode_ci,
  `ratio` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel_notice`
--

CREATE TABLE `channel_notice` (
  `channel_notice_id` int(10) NOT NULL,
  `channel_id` int(10) NOT NULL,
  `notice_type_id` int(10) NOT NULL,
  `count_from` int(10) NOT NULL,
  `count_to` int(10) NOT NULL,
  `reply` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel_point_action`
--

CREATE TABLE `channel_point_action` (
  `channel_point_action_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `action` enum('TWITCH_SUBMOD_ON','TWITCH_SUBMOD_OFF','TWITCH_MESSAGE','TWITCH_MUTE_SELF','TWITCH_MUTE_OTHER','TG_MUTE_SELF','TG_MUTE_OTHER','TG_MESSAGE','TG_AWARD') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci,
  `amount` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT '0',
  `enabled` int(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `channel_subchat`
--

CREATE TABLE `channel_subchat` (
  `channel_subchat_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `tg_chat_id` bigint(20) DEFAULT '0',
  `tg_chat_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `join_link` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled_join` tinyint(1) NOT NULL DEFAULT '1',
  `join_follower_only` tinyint(1) DEFAULT '0',
  `join_sub_only` tinyint(1) NOT NULL DEFAULT '1',
  `ban_time` int(11) NOT NULL DEFAULT '60',
  `bot_lang` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `last_member_refresh` timestamp NULL DEFAULT NULL,
  `refresh_status` enum('DONE','ERR','WAIT') COLLATE utf8mb4_unicode_ci DEFAULT 'DONE',
  `auto_kick` tinyint(1) DEFAULT '1',
  `kick_mode` enum('PERIOD','ONLINE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PERIOD',
  `notify_stream_status` tinyint(1) DEFAULT '0',
  `auto_mass_kick` int(11) DEFAULT '0',
  `last_auto_kick` timestamp NULL DEFAULT NULL,
  `getter_cooldown` int(11) DEFAULT '30',
  `reminder_cooldown` int(11) DEFAULT '0',
  `last_reminder` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `warn_mute_h` int(11) DEFAULT '72',
  `warn_expires_in` int(11) DEFAULT '168',
  `max_warns` int(11) DEFAULT '5',
  `on_refund` int(11) NOT NULL DEFAULT '1',
  `on_stream` int(1) NOT NULL DEFAULT '1',
  `welcome_message_id` int(11) NOT NULL DEFAULT '0',
  `welcome_message` text COLLATE utf8mb4_unicode_ci,
  `min_sub_months` int(11) DEFAULT '0',
  `show_report` int(1) NOT NULL DEFAULT '1',
  `global_events` int(1) DEFAULT '1',
  `force_pause` tinyint(1) DEFAULT '0',
  `auth_status` int(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `currency_type`
--

CREATE TABLE `currency_type` (
  `currency_type_id` int(11) NOT NULL,
  `currency_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` int(1) DEFAULT '1',
  `public` int(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_event`
--

CREATE TABLE `global_event` (
  `global_event_id` int(11) NOT NULL,
  `event_key` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active_from` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `active_to` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `label` varchar(225) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cd` int(11) DEFAULT '10',
  `public` int(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_event_reward`
--

CREATE TABLE `global_event_reward` (
  `global_event_reward_id` int(11) NOT NULL,
  `global_event_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT '0',
  `val` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `history_boosty`
--

CREATE TABLE `history_boosty` (
  `history_boosty_id` int(11) NOT NULL,
  `profile_boosty_id` int(11) DEFAULT NULL,
  `publish_ts` timestamp NULL DEFAULT NULL,
  `post_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `history_instagram`
--

CREATE TABLE `history_instagram` (
  `history_instagram_id` int(11) NOT NULL,
  `profile_instagram_id` int(11) DEFAULT NULL,
  `data_type` enum('STORY','POST') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `media_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `object_date` timestamp NULL DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `history_twitch`
--

CREATE TABLE `history_twitch` (
  `history_twitch_id` int(11) NOT NULL,
  `profile_twitch_id` int(11) NOT NULL,
  `sta` enum('ON','OFF') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `raw_data` text COLLATE utf8mb4_unicode_ci,
  `recovery` tinyint(1) DEFAULT '0',
  `create_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `infobot`
--

CREATE TABLE `infobot` (
  `infobot_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `target_type` enum('TG') COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_name` text COLLATE utf8mb4_unicode_ci,
  `target_id` bigint(20) DEFAULT NULL,
  `join_data` text COLLATE utf8mb4_unicode_ci,
  `status_message` text COLLATE utf8mb4_unicode_ci,
  `enabled` tinyint(1) DEFAULT '1',
  `auth_key` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lang` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT 'EN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `infobot_link`
--

CREATE TABLE `infobot_link` (
  `infobot_link_id` int(11) NOT NULL,
  `infobot_id` int(11) DEFAULT NULL,
  `link_table` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_id` int(11) DEFAULT NULL,
  `config` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `list`
--

CREATE TABLE `list` (
  `list_id` int(11) NOT NULL,
  `list_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `list_value`
--

CREATE TABLE `list_value` (
  `list_value_id` int(11) NOT NULL,
  `list_id` int(11) DEFAULT NULL,
  `value_str` text COLLATE utf8mb4_unicode_ci,
  `value_int` int(11) DEFAULT NULL,
  `value_dec` float DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notice_type`
--

CREATE TABLE `notice_type` (
  `notice_type_id` int(10) NOT NULL,
  `notice_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profile_boosty`
--

CREATE TABLE `profile_boosty` (
  `profile_boosty_id` int(11) NOT NULL,
  `username` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profile_instagram`
--

CREATE TABLE `profile_instagram` (
  `profile_instagram_id` int(11) NOT NULL,
  `instagram_name` text COLLATE utf8mb4_unicode_ci,
  `instagram_id` bigint(20) DEFAULT NULL,
  `stories` tinyint(1) DEFAULT '1',
  `posts` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profile_twitch`
--

CREATE TABLE `profile_twitch` (
  `profile_twitch_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reminder`
--

CREATE TABLE `reminder` (
  `reminder_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `reminder_key` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reminder_text` text COLLATE utf8mb4_unicode_ci,
  `completed` tinyint(1) DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `request`
--

CREATE TABLE `request` (
  `request_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `code` mediumtext COLLATE utf8mb4_unicode_ci,
  `request_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `response`
--

CREATE TABLE `response` (
  `response_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `tg_id` text COLLATE utf8mb4_unicode_ci,
  `tg_name` text COLLATE utf8mb4_unicode_ci,
  `tg_second_name` text COLLATE utf8mb4_unicode_ci,
  `tg_tag` text COLLATE utf8mb4_unicode_ci,
  `response_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lang` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `right_type`
--

CREATE TABLE `right_type` (
  `right_type_id` int(11) NOT NULL,
  `right_key` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `right_desc` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scheduler`
--

CREATE TABLE `scheduler` (
  `scheduler_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `task_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `exec_ts` timestamp NULL DEFAULT NULL,
  `delay_ts` timestamp NULL DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `delay_seconds` int(11) DEFAULT '0',
  `fixed_hour` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `setting`
--

CREATE TABLE `setting` (
  `setting_id` int(10) NOT NULL,
  `setting_key` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('BOT','WEB') COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `song_source`
--

CREATE TABLE `song_source` (
  `song_source_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `source` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `key` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stats_tg`
--

CREATE TABLE `stats_tg` (
  `stats_tg_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `type` enum('message','join','kick','sub','nonsub','total','nonverified','wls','bls','bots') COLLATE utf8mb4_unicode_ci NOT NULL,
  `counter` int(11) DEFAULT '0',
  `when_dt` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_award`
--

CREATE TABLE `tg_award` (
  `tg_award_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL DEFAULT '0',
  `award_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `award_template` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint(4) DEFAULT '0',
  `deleted_by` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_award_user`
--

CREATE TABLE `tg_award_user` (
  `tg_award_user_id` int(11) NOT NULL,
  `tg_award_id` int(11) NOT NULL,
  `tg_user_id` int(11) NOT NULL,
  `counter` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_banned_forward`
--

CREATE TABLE `tg_banned_forward` (
  `tg_banned_forward_id` int(11) NOT NULL,
  `channel_subchat_id` int(11) NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `from_id` int(11) DEFAULT '0',
  `channel_id` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_banned_media`
--

CREATE TABLE `tg_banned_media` (
  `tg_banned_media_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `media_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `media_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `about` text COLLATE utf8mb4_unicode_ci,
  `ban_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_get`
--

CREATE TABLE `tg_get` (
  `tg_get_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `keyword` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `text` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_user_id` int(11) DEFAULT '0',
  `original_msg_id` text COLLATE utf8mb4_unicode_ci,
  `original_chat_id` int(11) DEFAULT '0',
  `cache_message_id` text COLLATE utf8mb4_unicode_ci,
  `deleted` int(1) DEFAULT '0',
  `deleted_by` int(11) DEFAULT NULL,
  `broken` int(1) DEFAULT '0',
  `access` int(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_group_inventory`
--

CREATE TABLE `tg_group_inventory` (
  `tg_group_inventory_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `currency_id` int(11) NOT NULL,
  `amt` decimal(10,0) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_group_member`
--

CREATE TABLE `tg_group_member` (
  `tg_chat_id` int(11) NOT NULL,
  `tg_user_id` int(11) NOT NULL,
  `tg_first_name` text COLLATE utf8mb4_unicode_ci,
  `tg_second_name` text COLLATE utf8mb4_unicode_ci,
  `tg_username` text COLLATE utf8mb4_unicode_ci,
  `sub_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_invite`
--

CREATE TABLE `tg_invite` (
  `tg_invite_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `by_user_id` int(11) DEFAULT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_special_right`
--

CREATE TABLE `tg_special_right` (
  `tg_special_right_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `right_type` enum('BLACKLIST','WHITELIST','SUDO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `tg_user_id` bigint(20) NOT NULL,
  `user_first_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_last_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `by_tg_user_id` int(11) NOT NULL,
  `deleted` int(1) DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `auto_sync` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_vote`
--

CREATE TABLE `tg_vote` (
  `tg_vote_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `open_nominations` int(1) DEFAULT '0',
  `sta` int(1) DEFAULT '1',
  `created_by` int(11) NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_vote_nominee`
--

CREATE TABLE `tg_vote_nominee` (
  `tg_vote_nominee_id` int(11) NOT NULL,
  `tg_vote_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `type` enum('NOMINATE','IGNORE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NOMINATE',
  `created_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `added_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_vote_points`
--

CREATE TABLE `tg_vote_points` (
  `tg_vote_points_id` int(11) NOT NULL,
  `tg_vote_id` int(11) NOT NULL,
  `tg_vote_nominee_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tg_word`
--

CREATE TABLE `tg_word` (
  `tg_word_id` int(11) NOT NULL,
  `channel_subchat_id` int(11) NOT NULL,
  `restrict_type_id` int(11) DEFAULT NULL,
  `word` text COLLATE utf8mb4_unicode_ci,
  `user_id` int(11) NOT NULL,
  `created_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `translation`
--

CREATE TABLE `translation` (
  `translation_id` int(11) NOT NULL,
  `lang` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keyword` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_chat_notice`
--

CREATE TABLE `twitch_chat_notice` (
  `twitch_chat_notice_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notice_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tier` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `count1` int(11) NOT NULL,
  `count2` int(11) NOT NULL,
  `target_user_id` int(11) NOT NULL DEFAULT '0',
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_mass_ban`
--

CREATE TABLE `twitch_mass_ban` (
  `twitch_mass_ban_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `by_user_id` int(11) NOT NULL,
  `ban_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ban_time` int(11) DEFAULT NULL,
  `banned_count` int(11) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_message`
--

CREATE TABLE `twitch_message` (
  `twitch_message_id` int(11) NOT NULL,
  `channel_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_spam_log`
--

CREATE TABLE `twitch_spam_log` (
  `twitch_spam_log_id` int(11) NOT NULL,
  `channel_name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ts` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_subdata`
--

CREATE TABLE `twitch_subdata` (
  `twitch_subdata_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_gift` tinyint(1) NOT NULL DEFAULT '0',
  `tier` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `record_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `twitch_timeout`
--

CREATE TABLE `twitch_timeout` (
  `twitch_timeout_id` int(11) NOT NULL,
  `channel_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `reason` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `active_until` timestamp NOT NULL,
  `created_by_user` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(10) NOT NULL,
  `tw_id` int(20) NOT NULL DEFAULT '0',
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dname` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `supporter` tinyint(1) DEFAULT '0',
  `tg_about` text COLLATE utf8mb4_unicode_ci,
  `allow_soc` tinyint(1) DEFAULT '1',
  `soc_vk` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `soc_inst` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `soc_ut` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `user_avoid_duplicate_tw_id` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
    DECLARE existingUserId INT DEFAULT 0;

    SELECT u.user_id into existingUserId from user u where u.tw_id = new.tw_id;
    if existingUserId > 0 THEN
      signal sqlstate '45000';
    END IF;
  END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_currency`
--

CREATE TABLE `user_currency` (
  `user_currency_id` int(11) NOT NULL,
  `currency_type_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_right`
--

CREATE TABLE `user_right` (
  `user_right_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `channel_id` int(10) NOT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `blacklisted` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_web_right`
--

CREATE TABLE `user_web_right` (
  `user_web_right_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `right_type_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `web_log`
--

CREATE TABLE `web_log` (
  `web_log_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `target_user_id` int(11) NOT NULL,
  `method` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uri` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `result_code` int(11) DEFAULT NULL,
  `ip` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auth`
--
ALTER TABLE `auth`
  ADD PRIMARY KEY (`auth_id`),
  ADD KEY `FK_auth_user_id` (`user_id`);

--
-- Indexes for table `auth_state`
--
ALTER TABLE `auth_state`
  ADD PRIMARY KEY (`auth_state_id`),
  ADD UNIQUE KEY `auth_state_auth_state_id_uindex` (`auth_state_id`),
  ADD KEY `auth_state_user_user_id_fk` (`user_id`);

--
-- Indexes for table `channel`
--
ALTER TABLE `channel`
  ADD PRIMARY KEY (`channel_id`),
  ADD UNIQUE KEY `channel_id` (`channel_id`),
  ADD UNIQUE KEY `channel_name` (`channel_name`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `channel_command`
--
ALTER TABLE `channel_command`
  ADD PRIMARY KEY (`channel_command_id`,`channel_id`),
  ADD UNIQUE KEY `channel_command_channel_id_command_uindex` (`channel_id`,`command`),
  ADD KEY `FK_command_channel_id` (`channel_id`);

--
-- Indexes for table `channel_command_option`
--
ALTER TABLE `channel_command_option`
  ADD PRIMARY KEY (`channel_command_option_id`),
  ADD UNIQUE KEY `channel_command_option_channel_command_option_id_uindex` (`channel_command_option_id`),
  ADD KEY `channel_command_option_channel_command_channel_command_id_fk` (`channel_command_id`);

--
-- Indexes for table `channel_notice`
--
ALTER TABLE `channel_notice`
  ADD PRIMARY KEY (`channel_notice_id`),
  ADD KEY `channel_id` (`channel_id`),
  ADD KEY `notice_type_id` (`notice_type_id`);

--
-- Indexes for table `channel_point_action`
--
ALTER TABLE `channel_point_action`
  ADD PRIMARY KEY (`channel_point_action_id`),
  ADD UNIQUE KEY `channel_point_action_channel_point_action_id_uindex` (`channel_point_action_id`),
  ADD KEY `channel_point_action_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `channel_subchat`
--
ALTER TABLE `channel_subchat`
  ADD PRIMARY KEY (`channel_subchat_id`),
  ADD KEY `channel_id` (`channel_id`),
  ADD KEY `channel_id_2` (`channel_id`);

--
-- Indexes for table `currency_type`
--
ALTER TABLE `currency_type`
  ADD PRIMARY KEY (`currency_type_id`);

--
-- Indexes for table `global_event`
--
ALTER TABLE `global_event`
  ADD PRIMARY KEY (`global_event_id`),
  ADD UNIQUE KEY `global_event_global_event_id_uindex` (`global_event_id`);

--
-- Indexes for table `global_event_reward`
--
ALTER TABLE `global_event_reward`
  ADD PRIMARY KEY (`global_event_reward_id`),
  ADD UNIQUE KEY `global_event_reward_global_event_reward_id_uindex` (`global_event_reward_id`),
  ADD KEY `global_event_reward_user_user_id_fk` (`user_id`),
  ADD KEY `global_event_reward_global_event_global_event_id_fk` (`global_event_id`);

--
-- Indexes for table `history_boosty`
--
ALTER TABLE `history_boosty`
  ADD PRIMARY KEY (`history_boosty_id`),
  ADD KEY `history_boosty_profile_boosty_id_index` (`profile_boosty_id`);

--
-- Indexes for table `history_instagram`
--
ALTER TABLE `history_instagram`
  ADD PRIMARY KEY (`history_instagram_id`),
  ADD UNIQUE KEY `instagram_history_instagram_history_id_uindex` (`history_instagram_id`),
  ADD KEY `instagram_history_profile_instagram_profile_instagram_id_fk` (`profile_instagram_id`);

--
-- Indexes for table `history_twitch`
--
ALTER TABLE `history_twitch`
  ADD PRIMARY KEY (`history_twitch_id`),
  ADD UNIQUE KEY `twitch_stream_history_profile_twitch_id_pk` (`profile_twitch_id`);

--
-- Indexes for table `infobot`
--
ALTER TABLE `infobot`
  ADD PRIMARY KEY (`infobot_id`),
  ADD UNIQUE KEY `infobot_infobot_id_uindex` (`infobot_id`),
  ADD UNIQUE KEY `infobot_target_id_uindex` (`target_id`),
  ADD KEY `infobot_user_user_id_fk` (`user_id`);

--
-- Indexes for table `infobot_link`
--
ALTER TABLE `infobot_link`
  ADD PRIMARY KEY (`infobot_link_id`),
  ADD UNIQUE KEY `infobot_link_infobot_id_link_table_link_id_uindex` (`infobot_id`,`link_table`,`link_id`);

--
-- Indexes for table `list`
--
ALTER TABLE `list`
  ADD PRIMARY KEY (`list_id`);

--
-- Indexes for table `list_value`
--
ALTER TABLE `list_value`
  ADD PRIMARY KEY (`list_value_id`),
  ADD KEY `list_value_list_list_id_fk` (`list_id`);

--
-- Indexes for table `notice_type`
--
ALTER TABLE `notice_type`
  ADD PRIMARY KEY (`notice_type_id`);

--
-- Indexes for table `profile_boosty`
--
ALTER TABLE `profile_boosty`
  ADD PRIMARY KEY (`profile_boosty_id`);

--
-- Indexes for table `profile_instagram`
--
ALTER TABLE `profile_instagram`
  ADD PRIMARY KEY (`profile_instagram_id`),
  ADD UNIQUE KEY `profile_instagram_profile_instagram_id_uindex` (`profile_instagram_id`);

--
-- Indexes for table `profile_twitch`
--
ALTER TABLE `profile_twitch`
  ADD PRIMARY KEY (`profile_twitch_id`),
  ADD UNIQUE KEY `profile_twitch_user_id_pk` (`user_id`);

--
-- Indexes for table `reminder`
--
ALTER TABLE `reminder`
  ADD PRIMARY KEY (`reminder_id`),
  ADD UNIQUE KEY `reminder_reminder_id_uindex` (`reminder_id`),
  ADD KEY `reminder_channel_id_index` (`channel_id`);

--
-- Indexes for table `request`
--
ALTER TABLE `request`
  ADD PRIMARY KEY (`request_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `response`
--
ALTER TABLE `response`
  ADD PRIMARY KEY (`response_id`),
  ADD UNIQUE KEY `response_id` (`response_id`),
  ADD KEY `request_id` (`request_id`);

--
-- Indexes for table `right_type`
--
ALTER TABLE `right_type`
  ADD PRIMARY KEY (`right_type_id`);

--
-- Indexes for table `scheduler`
--
ALTER TABLE `scheduler`
  ADD PRIMARY KEY (`scheduler_id`),
  ADD UNIQUE KEY `scheduler_scheduler_id_uindex` (`scheduler_id`);

--
-- Indexes for table `setting`
--
ALTER TABLE `setting`
  ADD PRIMARY KEY (`setting_id`);

--
-- Indexes for table `song_source`
--
ALTER TABLE `song_source`
  ADD PRIMARY KEY (`song_source_id`),
  ADD UNIQUE KEY `song_source_song_source_id_uindex` (`song_source_id`),
  ADD KEY `song_source_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `stats_tg`
--
ALTER TABLE `stats_tg`
  ADD PRIMARY KEY (`stats_tg_id`),
  ADD UNIQUE KEY `stats_tg_action_stats_tg_action_id_uindex` (`stats_tg_id`),
  ADD UNIQUE KEY `stats_tg_channel_id_type_when_dt_uindex` (`channel_id`,`type`,`when_dt`),
  ADD KEY `stats_tg_when_dt_index` (`when_dt`);

--
-- Indexes for table `tg_award`
--
ALTER TABLE `tg_award`
  ADD PRIMARY KEY (`tg_award_id`),
  ADD UNIQUE KEY `tg_award_tg_award_id_uindex` (`tg_award_id`),
  ADD KEY `tg_award_channel_id_index` (`channel_id`),
  ADD KEY `tg_award_user_user_id_fk` (`user_id`);

--
-- Indexes for table `tg_award_user`
--
ALTER TABLE `tg_award_user`
  ADD PRIMARY KEY (`tg_award_user_id`),
  ADD UNIQUE KEY `tg_award_user_tg_award_user_id_uindex` (`tg_award_user_id`),
  ADD KEY `tg_award_user_tg_award_id_index` (`tg_award_id`);

--
-- Indexes for table `tg_banned_forward`
--
ALTER TABLE `tg_banned_forward`
  ADD PRIMARY KEY (`tg_banned_forward_id`),
  ADD UNIQUE KEY `tg_banned_forward_tg_banned_forward_id_uindex` (`tg_banned_forward_id`),
  ADD UNIQUE KEY `tg_banned_forward_channel_subchat_id_pk` (`channel_subchat_id`);

--
-- Indexes for table `tg_banned_media`
--
ALTER TABLE `tg_banned_media`
  ADD PRIMARY KEY (`tg_banned_media_id`),
  ADD UNIQUE KEY `tg_banned_media_tg_banned_media_id_uindex` (`tg_banned_media_id`),
  ADD KEY `channel_id` (`channel_id`);

--
-- Indexes for table `tg_get`
--
ALTER TABLE `tg_get`
  ADD PRIMARY KEY (`tg_get_id`),
  ADD UNIQUE KEY `tg_get_tg_get_id_uindex` (`tg_get_id`),
  ADD KEY `tg_get_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `tg_group_inventory`
--
ALTER TABLE `tg_group_inventory`
  ADD PRIMARY KEY (`tg_group_inventory_id`),
  ADD KEY `tg_group_inventory_currency_type_currency_type_id_fk` (`currency_id`),
  ADD KEY `tg_group_inventory_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `tg_group_member`
--
ALTER TABLE `tg_group_member`
  ADD KEY `tg_group_member_tg_chat_id_index` (`tg_chat_id`);

--
-- Indexes for table `tg_invite`
--
ALTER TABLE `tg_invite`
  ADD PRIMARY KEY (`tg_invite_id`),
  ADD KEY `tg_invite_channel_channel_id_fk` (`channel_id`),
  ADD KEY `tg_invite_user_user_id_fk` (`user_id`),
  ADD KEY `tg_invite_user_by_user_id_fk` (`by_user_id`);

--
-- Indexes for table `tg_special_right`
--
ALTER TABLE `tg_special_right`
  ADD PRIMARY KEY (`tg_special_right_id`),
  ADD KEY `tg_special_right_channel_id_index` (`channel_id`),
  ADD KEY `tg_special_right_user_id_index` (`user_id`);

--
-- Indexes for table `tg_vote`
--
ALTER TABLE `tg_vote`
  ADD PRIMARY KEY (`tg_vote_id`),
  ADD UNIQUE KEY `tg_vote_tg_vote_id_uindex` (`tg_vote_id`),
  ADD KEY `tg_vote_channel_channel_id_fk` (`channel_id`),
  ADD KEY `tg_vote_user_user_id_fk` (`created_by`);

--
-- Indexes for table `tg_vote_nominee`
--
ALTER TABLE `tg_vote_nominee`
  ADD PRIMARY KEY (`tg_vote_nominee_id`),
  ADD KEY `tg_vote_nominee_tg_vote_tg_vote_id_fk` (`tg_vote_id`),
  ADD KEY `tg_vote_nominee_user_user_id_fk` (`user_id`),
  ADD KEY `tg_vote_nominee_added_user_id_fk` (`added_by`);

--
-- Indexes for table `tg_vote_points`
--
ALTER TABLE `tg_vote_points`
  ADD PRIMARY KEY (`tg_vote_points_id`),
  ADD UNIQUE KEY `tg_vote_nominee_points_tg_vote_nominee_points_id_uindex` (`tg_vote_points_id`),
  ADD KEY `_user_user_id_fk` (`user_id`),
  ADD KEY `tg_vote_nominee_points_tg_vote_nominee_tg_vote_nominee_id_fk` (`tg_vote_nominee_id`),
  ADD KEY `tg_vote_points_tg_vote_tg_vote_id_fk` (`tg_vote_id`);

--
-- Indexes for table `tg_word`
--
ALTER TABLE `tg_word`
  ADD PRIMARY KEY (`tg_word_id`),
  ADD UNIQUE KEY `tg_word_tg_word_id_uindex` (`tg_word_id`),
  ADD KEY `tg_word_channel_subchat_id_pk` (`channel_subchat_id`),
  ADD KEY `tg_word_user_user_id_fk` (`user_id`);

--
-- Indexes for table `translation`
--
ALTER TABLE `translation`
  ADD PRIMARY KEY (`translation_id`),
  ADD UNIQUE KEY `translation_translation_id_uindex` (`translation_id`),
  ADD UNIQUE KEY `translation_keyword_lang_uindex` (`keyword`,`lang`);

--
-- Indexes for table `twitch_chat_notice`
--
ALTER TABLE `twitch_chat_notice`
  ADD PRIMARY KEY (`twitch_chat_notice_id`),
  ADD UNIQUE KEY `twitch_chat_notice_twitch_chat_notice_id_uindex` (`twitch_chat_notice_id`),
  ADD KEY `channel_id` (`channel_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `twitch_mass_ban`
--
ALTER TABLE `twitch_mass_ban`
  ADD PRIMARY KEY (`twitch_mass_ban_id`),
  ADD KEY `twitch_mass_ban_user_user_id_fk` (`by_user_id`),
  ADD KEY `twitch_mass_ban_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `twitch_message`
--
ALTER TABLE `twitch_message`
  ADD PRIMARY KEY (`twitch_message_id`),
  ADD KEY `twitch_message_user_user_id_fk` (`user_id`),
  ADD KEY `twitch_message_channel_id_index` (`channel_id`);

--
-- Indexes for table `twitch_spam_log`
--
ALTER TABLE `twitch_spam_log`
  ADD PRIMARY KEY (`twitch_spam_log_id`);

--
-- Indexes for table `twitch_subdata`
--
ALTER TABLE `twitch_subdata`
  ADD PRIMARY KEY (`twitch_subdata_id`),
  ADD UNIQUE KEY `twitch_subdata_twitch_subdata_id_uindex` (`twitch_subdata_id`),
  ADD KEY `twitch_subdata_user_user_id_fk` (`user_id`),
  ADD KEY `twitch_subdata_channel_channel_id_fk` (`channel_id`);

--
-- Indexes for table `twitch_timeout`
--
ALTER TABLE `twitch_timeout`
  ADD PRIMARY KEY (`twitch_timeout_id`),
  ADD KEY `twitch_timeout_channel_id_index` (`channel_id`),
  ADD KEY `twitch_timeout_channel_id_user_id_index` (`channel_id`,`user_id`),
  ADD KEY `twitch_timeout_user_user_id_fk` (`user_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_tw_id_uindex` (`tw_id`);

--
-- Indexes for table `user_currency`
--
ALTER TABLE `user_currency`
  ADD PRIMARY KEY (`user_currency_id`),
  ADD UNIQUE KEY `user_currency_user_currency_id_uindex` (`user_currency_id`),
  ADD KEY `user_currency_currency_type_currency_type_id_fk` (`currency_type_id`),
  ADD KEY `user_currency_user_user_id_fk` (`user_id`);

--
-- Indexes for table `user_right`
--
ALTER TABLE `user_right`
  ADD PRIMARY KEY (`user_right_id`),
  ADD KEY `channel_id` (`channel_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `user_right_id` (`user_right_id`);

--
-- Indexes for table `user_web_right`
--
ALTER TABLE `user_web_right`
  ADD PRIMARY KEY (`user_web_right_id`),
  ADD KEY `user_web_right_user_user_id_fk` (`user_id`);

--
-- Indexes for table `web_log`
--
ALTER TABLE `web_log`
  ADD PRIMARY KEY (`web_log_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `auth`
--
ALTER TABLE `auth`
  MODIFY `auth_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_state`
--
ALTER TABLE `auth_state`
  MODIFY `auth_state_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel`
--
ALTER TABLE `channel`
  MODIFY `channel_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel_command`
--
ALTER TABLE `channel_command`
  MODIFY `channel_command_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel_command_option`
--
ALTER TABLE `channel_command_option`
  MODIFY `channel_command_option_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel_notice`
--
ALTER TABLE `channel_notice`
  MODIFY `channel_notice_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel_point_action`
--
ALTER TABLE `channel_point_action`
  MODIFY `channel_point_action_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `channel_subchat`
--
ALTER TABLE `channel_subchat`
  MODIFY `channel_subchat_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `currency_type`
--
ALTER TABLE `currency_type`
  MODIFY `currency_type_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_event`
--
ALTER TABLE `global_event`
  MODIFY `global_event_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_event_reward`
--
ALTER TABLE `global_event_reward`
  MODIFY `global_event_reward_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `history_boosty`
--
ALTER TABLE `history_boosty`
  MODIFY `history_boosty_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `history_instagram`
--
ALTER TABLE `history_instagram`
  MODIFY `history_instagram_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `history_twitch`
--
ALTER TABLE `history_twitch`
  MODIFY `history_twitch_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `infobot`
--
ALTER TABLE `infobot`
  MODIFY `infobot_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `infobot_link`
--
ALTER TABLE `infobot_link`
  MODIFY `infobot_link_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `list`
--
ALTER TABLE `list`
  MODIFY `list_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `list_value`
--
ALTER TABLE `list_value`
  MODIFY `list_value_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notice_type`
--
ALTER TABLE `notice_type`
  MODIFY `notice_type_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile_boosty`
--
ALTER TABLE `profile_boosty`
  MODIFY `profile_boosty_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile_instagram`
--
ALTER TABLE `profile_instagram`
  MODIFY `profile_instagram_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profile_twitch`
--
ALTER TABLE `profile_twitch`
  MODIFY `profile_twitch_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reminder`
--
ALTER TABLE `reminder`
  MODIFY `reminder_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request`
--
ALTER TABLE `request`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `response`
--
ALTER TABLE `response`
  MODIFY `response_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `right_type`
--
ALTER TABLE `right_type`
  MODIFY `right_type_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scheduler`
--
ALTER TABLE `scheduler`
  MODIFY `scheduler_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `setting`
--
ALTER TABLE `setting`
  MODIFY `setting_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `song_source`
--
ALTER TABLE `song_source`
  MODIFY `song_source_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stats_tg`
--
ALTER TABLE `stats_tg`
  MODIFY `stats_tg_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_award`
--
ALTER TABLE `tg_award`
  MODIFY `tg_award_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_award_user`
--
ALTER TABLE `tg_award_user`
  MODIFY `tg_award_user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_banned_forward`
--
ALTER TABLE `tg_banned_forward`
  MODIFY `tg_banned_forward_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_banned_media`
--
ALTER TABLE `tg_banned_media`
  MODIFY `tg_banned_media_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_get`
--
ALTER TABLE `tg_get`
  MODIFY `tg_get_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_group_inventory`
--
ALTER TABLE `tg_group_inventory`
  MODIFY `tg_group_inventory_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_invite`
--
ALTER TABLE `tg_invite`
  MODIFY `tg_invite_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_special_right`
--
ALTER TABLE `tg_special_right`
  MODIFY `tg_special_right_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_vote`
--
ALTER TABLE `tg_vote`
  MODIFY `tg_vote_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_vote_nominee`
--
ALTER TABLE `tg_vote_nominee`
  MODIFY `tg_vote_nominee_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_vote_points`
--
ALTER TABLE `tg_vote_points`
  MODIFY `tg_vote_points_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tg_word`
--
ALTER TABLE `tg_word`
  MODIFY `tg_word_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `translation`
--
ALTER TABLE `translation`
  MODIFY `translation_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_chat_notice`
--
ALTER TABLE `twitch_chat_notice`
  MODIFY `twitch_chat_notice_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_mass_ban`
--
ALTER TABLE `twitch_mass_ban`
  MODIFY `twitch_mass_ban_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_message`
--
ALTER TABLE `twitch_message`
  MODIFY `twitch_message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_spam_log`
--
ALTER TABLE `twitch_spam_log`
  MODIFY `twitch_spam_log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_subdata`
--
ALTER TABLE `twitch_subdata`
  MODIFY `twitch_subdata_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `twitch_timeout`
--
ALTER TABLE `twitch_timeout`
  MODIFY `twitch_timeout_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_currency`
--
ALTER TABLE `user_currency`
  MODIFY `user_currency_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_right`
--
ALTER TABLE `user_right`
  MODIFY `user_right_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_web_right`
--
ALTER TABLE `user_web_right`
  MODIFY `user_web_right_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `web_log`
--
ALTER TABLE `web_log`
  MODIFY `web_log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `auth`
--
ALTER TABLE `auth`
  ADD CONSTRAINT `auth_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `auth_state`
--
ALTER TABLE `auth_state`
  ADD CONSTRAINT `auth_state_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `channel`
--
ALTER TABLE `channel`
  ADD CONSTRAINT `channel_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `channel_command`
--
ALTER TABLE `channel_command`
  ADD CONSTRAINT `channel_command_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `channel_command_option`
--
ALTER TABLE `channel_command_option`
  ADD CONSTRAINT `channel_command_option_channel_command_channel_command_id_fk` FOREIGN KEY (`channel_command_id`) REFERENCES `channel_command` (`channel_command_id`);

--
-- Constraints for table `channel_notice`
--
ALTER TABLE `channel_notice`
  ADD CONSTRAINT `channel_notice_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `channel_notice_notice_type_notice_type_id_fk` FOREIGN KEY (`notice_type_id`) REFERENCES `notice_type` (`notice_type_id`);

--
-- Constraints for table `channel_point_action`
--
ALTER TABLE `channel_point_action`
  ADD CONSTRAINT `channel_point_action_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `channel_subchat`
--
ALTER TABLE `channel_subchat`
  ADD CONSTRAINT `channel_subchat_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`);

--
-- Constraints for table `global_event_reward`
--
ALTER TABLE `global_event_reward`
  ADD CONSTRAINT `global_event_reward_global_event_global_event_id_fk` FOREIGN KEY (`global_event_id`) REFERENCES `global_event` (`global_event_id`),
  ADD CONSTRAINT `global_event_reward_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `history_boosty`
--
ALTER TABLE `history_boosty`
  ADD CONSTRAINT `history_boosty_profile_boosty_profile_boosty_id_fk` FOREIGN KEY (`profile_boosty_id`) REFERENCES `profile_boosty` (`profile_boosty_id`);

--
-- Constraints for table `history_instagram`
--
ALTER TABLE `history_instagram`
  ADD CONSTRAINT `instagram_history_profile_instagram_profile_instagram_id_fk` FOREIGN KEY (`profile_instagram_id`) REFERENCES `profile_instagram` (`profile_instagram_id`);

--
-- Constraints for table `history_twitch`
--
ALTER TABLE `history_twitch`
  ADD CONSTRAINT `twitch_stream_history_profile_twitch_profile_twitch_id_fk` FOREIGN KEY (`profile_twitch_id`) REFERENCES `profile_twitch` (`profile_twitch_id`);

--
-- Constraints for table `infobot_link`
--
ALTER TABLE `infobot_link`
  ADD CONSTRAINT `infobot_link_infobot_infobot_id_fk` FOREIGN KEY (`infobot_id`) REFERENCES `infobot` (`infobot_id`) ON DELETE CASCADE;

--
-- Constraints for table `list_value`
--
ALTER TABLE `list_value`
  ADD CONSTRAINT `list_value_list_list_id_fk` FOREIGN KEY (`list_id`) REFERENCES `list` (`list_id`);

--
-- Constraints for table `profile_twitch`
--
ALTER TABLE `profile_twitch`
  ADD CONSTRAINT `profile_twitch_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `reminder`
--
ALTER TABLE `reminder`
  ADD CONSTRAINT `reminder_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `request`
--
ALTER TABLE `request`
  ADD CONSTRAINT `request_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `response`
--
ALTER TABLE `response`
  ADD CONSTRAINT `response_request_request_id_fk` FOREIGN KEY (`request_id`) REFERENCES `request` (`request_id`);

--
-- Constraints for table `song_source`
--
ALTER TABLE `song_source`
  ADD CONSTRAINT `song_source_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `tg_award`
--
ALTER TABLE `tg_award`
  ADD CONSTRAINT `tg_award_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tg_award_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `tg_award_user`
--
ALTER TABLE `tg_award_user`
  ADD CONSTRAINT `tg_award_user_tg_award_tg_award_id_fk` FOREIGN KEY (`tg_award_id`) REFERENCES `tg_award` (`tg_award_id`) ON DELETE CASCADE;

--
-- Constraints for table `tg_banned_media`
--
ALTER TABLE `tg_banned_media`
  ADD CONSTRAINT `tg_banned_media_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `tg_get`
--
ALTER TABLE `tg_get`
  ADD CONSTRAINT `tg_get_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE;

--
-- Constraints for table `tg_group_inventory`
--
ALTER TABLE `tg_group_inventory`
  ADD CONSTRAINT `tg_group_inventory_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tg_group_inventory_currency_type_currency_type_id_fk` FOREIGN KEY (`currency_id`) REFERENCES `currency_type` (`currency_type_id`);

--
-- Constraints for table `tg_invite`
--
ALTER TABLE `tg_invite`
  ADD CONSTRAINT `tg_invite_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`),
  ADD CONSTRAINT `tg_invite_user_by_user_id_fk` FOREIGN KEY (`by_user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `tg_invite_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `tg_special_right`
--
ALTER TABLE `tg_special_right`
  ADD CONSTRAINT `tg_special_right_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tg_special_right_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `tg_vote`
--
ALTER TABLE `tg_vote`
  ADD CONSTRAINT `tg_vote_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`),
  ADD CONSTRAINT `tg_vote_user_user_id_fk` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `tg_vote_nominee`
--
ALTER TABLE `tg_vote_nominee`
  ADD CONSTRAINT `tg_vote_nominee_added_user_id_fk` FOREIGN KEY (`added_by`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `tg_vote_nominee_tg_vote_tg_vote_id_fk` FOREIGN KEY (`tg_vote_id`) REFERENCES `tg_vote` (`tg_vote_id`),
  ADD CONSTRAINT `tg_vote_nominee_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `tg_vote_points`
--
ALTER TABLE `tg_vote_points`
  ADD CONSTRAINT `_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `tg_vote_nominee_points_tg_vote_nominee_tg_vote_nominee_id_fk` FOREIGN KEY (`tg_vote_nominee_id`) REFERENCES `tg_vote_nominee` (`tg_vote_nominee_id`),
  ADD CONSTRAINT `tg_vote_points_tg_vote_tg_vote_id_fk` FOREIGN KEY (`tg_vote_id`) REFERENCES `tg_vote` (`tg_vote_id`);

--
-- Constraints for table `tg_word`
--
ALTER TABLE `tg_word`
  ADD CONSTRAINT `tg_word_channel_subchat_channel_subchat_id_fk` FOREIGN KEY (`channel_subchat_id`) REFERENCES `channel_subchat` (`channel_subchat_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tg_word_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `twitch_chat_notice`
--
ALTER TABLE `twitch_chat_notice`
  ADD CONSTRAINT `FK_chat_notice_channel_id` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_chat_notice_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `twitch_mass_ban`
--
ALTER TABLE `twitch_mass_ban`
  ADD CONSTRAINT `twitch_mass_ban_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`),
  ADD CONSTRAINT `twitch_mass_ban_user_user_id_fk` FOREIGN KEY (`by_user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `twitch_message`
--
ALTER TABLE `twitch_message`
  ADD CONSTRAINT `twitch_message_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `twitch_message_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `twitch_subdata`
--
ALTER TABLE `twitch_subdata`
  ADD CONSTRAINT `twitch_subdata_channel_channel_id_fk` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `twitch_subdata_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `user_currency`
--
ALTER TABLE `user_currency`
  ADD CONSTRAINT `user_currency_currency_type_currency_type_id_fk` FOREIGN KEY (`currency_type_id`) REFERENCES `currency_type` (`currency_type_id`),
  ADD CONSTRAINT `user_currency_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_right`
--
ALTER TABLE `user_right`
  ADD CONSTRAINT `user_right_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `user_web_right`
--
ALTER TABLE `user_web_right`
  ADD CONSTRAINT `user_web_right_user_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
