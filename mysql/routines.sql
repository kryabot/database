CREATE FUNCTION `getChannelIdByUserId`(userId int) RETURNS int(11)
BEGIN
  DECLARE returnValue INT DEFAULT 0;

  if userId > 0 THEN
    select channel.channel_id into returnValue from channel where channel.user_id = userId;
  END IF;

    return returnValue;
END ;;

CREATE FUNCTION `getTelegramGroupIdByUserId`(userId int) RETURNS int(11)
BEGIN
  DECLARE returnValue INT DEFAULT 0;
  DECLARE channelId INT default 0;

  if userId > 0 THEN
    select getChannelIdByUserId(userId) into channelId;
    if channelId > 0 THEN
      select channel_subchat.channel_subchat_id into returnValue from channel_subchat where channel_subchat.channel_id = channelId;
    END IF;
  END IF;
    return returnValue;
END ;;

CREATE FUNCTION `getTwitchNameByTgId`(tgId int) RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
BEGIN
  DECLARE userId INT DEFAULT 0;
  DECLARE returnValue TEXT DEFAULT CAST(tgId as CHAR);

  select req.user_id into userId from request req where req.request_id = (SELECT resp.request_id from response resp where resp.tg_id = tgId);  

  if userId > 0 THEN
    select user.name into returnValue from user where user.user_id = userId;
  END IF;
  
    return returnValue;
END ;;

CREATE FUNCTION `getUserLabelByTgId`(tgId int) RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
BEGIN
  DECLARE userId INT DEFAULT 0;
  DECLARE firstName TEXT;
  DECLARE lastName TEXT;
  DECLARE tgUsername TEXT;
  DECLARE returnValue TEXT DEFAULT CAST(tgId as CHAR);

  select gm.tg_username, gm.tg_first_name, gm.tg_second_name, gm.tg_user_id into tgUsername, firstName, lastName, userId from tg_group_member gm where gm.tg_user_id = tgId ORDER BY gm.created_at LIMIT 1;

  if userId > 0 THEN
    SET returnValue = CONCAT(firstName, ' ', lastName, ' (@', tgUsername, ')');
  END IF;
    return returnValue;
END ;;



CREATE PROCEDURE `addCurrencyToChannel`(IN currencyKey VARCHAR(100), IN channelId INT, IN addAmount INT)
BEGIN
    DECLARE currencyId INT;
    DECLARE channelCurrencyId INT;

    select ct.currency_type_id into currencyId from currency_type ct WHERE ct.currency_key = currencyKey and ct.active = 1;

    if currencyId > 0 THEN
      select uc.tg_group_inventory_id into channelCurrencyId from tg_group_inventory uc WHERE uc.currency_id = currencyId and uc.channel_id = channelId;

      IF channelCurrencyId > 0 THEN
          UPDATE tg_group_inventory uc SET uc.amt = uc.amt + addAmount WHERE uc.tg_group_inventory_id = channelCurrencyId;
        ELSE
          INSERT INTO tg_group_inventory (currency_id, channel_id, amt) VALUES (currencyId, channelId, addAmount);
      END IF;
    end if;
end ;;



CREATE PROCEDURE `addCurrencyToChatMembers`(IN currencyKey VARCHAR(100), IN tgChatId INT, IN addAmount INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE userId INT;
    DECLARE memberCursor CURSOR FOR SELECT req.user_id FROM tg_group_member tgm LEFT JOIN response resp on resp.tg_id = tgm.tg_user_id left join request req on req.request_id = resp.request_id WHERE tgm.tg_chat_id = tgChatId and tgm.tg_user_id != 772791779;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN memberCursor;

    loop_members: LOOP
      FETCH memberCursor into userId;
      if done THEN
        LEAVE loop_members;
      END IF;
      CALL addCurrencyToUser(currencyKey, userId, addAmount);
    END LOOP;
  END ;;



CREATE PROCEDURE `addCurrencyToUser`(IN currencyKey VARCHAR(100), IN userId INT, IN addAmount INT)
BEGIN
    DECLARE currencyId INT;
    DECLARE userCurrencyId INT;

    select ct.currency_type_id into currencyId from currency_type ct WHERE ct.currency_key = currencyKey and ct.active = 1;

    if currencyId > 0 THEN
      select uc.user_currency_id into userCurrencyId from user_currency uc WHERE uc.currency_type_id = currencyId and uc.user_id = userId;

      IF userCurrencyId > 0 THEN
          UPDATE user_currency uc SET uc.amount = uc.amount + addAmount WHERE uc.user_currency_id = userCurrencyId;
        ELSE
          INSERT INTO user_currency (currency_type_id, user_id, amount) VALUES (currencyId, userId, addAmount);
      END IF;
    end if;
end ;;


CREATE PROCEDURE `addToList`(IN listName TEXT, IN valueStr TEXT, IN valueInt INT, IN valueDec DECIMAL)
BEGIN
    DECLARE listId INT;

    select list.list_id into listId from list WHERE list.list_name = listName and list.active = 1;

    if listId > 0 THEN
      INSERT INTO list_value (list_id, value_str, value_int, value_dec) VALUES (listId, valueStr, valueInt, valueDec);
    end if;
end ;;



CREATE PROCEDURE `createChannelMessageTable`(IN channelId int)
BEGIN
		DECLARE tableName VARCHAR(30);
		DECLARE existanceCheck INT;
		DECLARE sqlString TEXT;

		SET existanceCheck = 0;

		SELECT channel_name INTO tableName FROM channel WHERE channel.channel_id = channelId;

		SET tableName = concat('message_', tableName);

		SELECT count(*) into existanceCheck  FROM information_schema.tables WHERE table_schema = 'oskarasv_krya' AND table_name = tableName;
		if existanceCheck = 0 THEN
			SET @sqlString = concat('create table oskarasv_krya.', tableName, ' (message_id int(10) auto_increment primary key, user_id int(10) not null, message_text text not null, ts timestamp default CURRENT_TIMESTAMP null, constraint index_message_id unique (message_id) );');

			PREPARE stmt from @sqlString;
			EXECUTE stmt;

			SET @sqlString = concat('create index user_id on ', tableName, ' (user_id);');
			PREPARE stmt from @sqlString;
			EXECUTE stmt;

      SET @sqlString = concat('ALTER TABLE ', tableName,' ADD CONSTRAINT ', tableName, '_user_user_id_fk FOREIGN KEY (user_id) REFERENCES user (user_id);');
      PREPARE stmt from @sqlString;
			EXECUTE stmt;

		END IF;
END ;;



CREATE PROCEDURE `createUser`(IN twitcId int, IN twitchName varchar(200))
BEGIN
    DECLARE existingTwitchUserId int DEFAULT 0;

    select u.user_id into existingTwitchUserId from user u WHERE u.tw_id = twitcId;

    IF existingTwitchUserId = 0 THEN
      INSERT INTO user (tw_id, name) VALUES (twitcId, twitchName);
    END IF;
END ;;



CREATE PROCEDURE `debugMsg`(IN enabled int, IN msg varchar(255))
BEGIN
  IF enabled THEN BEGIN
    select concat("** ", msg) AS '** DEBUG:';
  END; END IF;
END ;;



CREATE PROCEDURE `deleteAllBannedMediaByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;

    select getChannelIdByUserId(userId) into channelId;

    IF channelId>0 THEN
      delete from tg_banned_media where tg_banned_media.channel_id = channelId;
    END IF;

  END ;;



CREATE PROCEDURE `deleteAllBannedWordsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE chatId INT DEFAULT 0;
    
    select getChannelIdByUserId(userId) into channelId;
    select cs.channel_subchat_id INTO chatId FROM channel_subchat cs WHERE cs.channel_id = channelId;
    
    IF chatId>0 THEN
      delete from tg_word where tg_word.channel_subchat_id = chatId;
    END IF;
  END ;;



CREATE PROCEDURE `deleteAllTgAwardsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    IF channelId>0 THEN
      UPDATE tg_award SET tg_award.deleted = 1, tg_award.deleted_by = userId WHERE tg_award.channel_id = channelId;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteBannedMediaByUserId`(IN userId INT, IN mediaId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE requestedChannelId INT DEFAULT 0;
    DECLARE existingMediaId INT DEFAULT 0;

    select getChannelIdByUserId(userId) into channelId;

    select cc.channel_id, cc.tg_banned_media_id into requestedChannelId, existingMediaId from tg_banned_media cc WHERE cc.tg_banned_media_id = mediaId;

    IF channelId>0 and channelId=requestedChannelId and existingMediaId>0 THEN
      DELETE FROM tg_banned_media where tg_banned_media.tg_banned_media_id = mediaId;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteBannedWordByUserId`(IN userId INT, IN wordId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE requestedChatId INT DEFAULT 0;
    DECLARE existingWordId INT DEFAULT 0;
    DECLARE chatId INT DEFAULT 0;

    select getChannelIdByUserId(userId) into channelId;
    select cs.channel_subchat_id INTO chatId FROM channel_subchat cs WHERE cs.channel_id = channelId;
    select w.channel_subchat_id, w.tg_word_id into requestedChatId, existingWordId from tg_word w WHERE w.tg_word_id = wordId;

    IF channelId>0 and chatId=requestedChatId and existingWordId>0 THEN
      DELETE FROM tg_word where tg_word.tg_word_id = wordId;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteChannelCommandByUserId`(IN userId INT, IN commandId INT, OUT sta TINYINT(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE requestedChannelId INT DEFAULT 0;
    DECLARE existingCommandId INT DEFAULT 0;

    set sta = 0;
    select getChannelIdByUserId(userId) into channelId;

    select cc.channel_id, cc.channel_command_id into requestedChannelId, existingCommandId from channel_command cc WHERE cc.channel_command_id = commandId;

    IF channelId>0 and channelId=requestedChannelId and existingCommandId>0 THEN
      DELETE FROM channel_command where channel_command.channel_command_id = commandId;
      SET sta = 1;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteChannelNoticeByUserId`(IN userId INT, IN noticeId INT, OUT sta TINYINT(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE requestedChannelId int default 0;

    set sta = 0;
    select getChannelIdByUserId(userId) into channelId;

    select cn.channel_id into requestedChannelId from channel_notice cn WHERE cn.channel_notice_id = noticeId;

    IF channelId>0 and channelId=requestedChannelId THEN
      DELETE from channel_notice where channel_notice.channel_notice_id = noticeId;
      SET sta = 1;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deletePointRewardByUserId`(IN userId INT, IN rewardId INT, OUT sta TINYINT(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE requestedChannelId int default 0;
    DECLARE existingRewardId INT DEFAULT 0;

    set sta = 0;
    select getChannelIdByUserId(userId) into channelId;

    select cpa.channel_id, cpa.channel_point_action_id into requestedChannelId, existingRewardId from channel_point_action cpa WHERE cpa.channel_point_action_id = rewardId;

    IF channelId>0 and channelId=requestedChannelId and existingRewardId >0 THEN
      DELETE from channel_point_action where channel_point_action.channel_point_action_id = rewardId;
      SET sta = 1;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteReminderById`(IN userId int, IN reminderId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    if channelId > 0 THEN
      DELETE FROM reminder where reminder.channel_id = channelId and reminder.reminder_id = reminderId;
    END IF;
END ;;



CREATE PROCEDURE `deleteTgAwardByUserId`(IN userId INT, IN awardId INT, IN deletedBy INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    IF channelId>0 THEN
      UPDATE tg_award SET tg_award.deleted = 1, tg_award.deleted_by = deletedBy WHERE tg_award.tg_award_id = awardId and tg_award.channel_id = channelId;
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong deletion';
    END IF;
  END ;;



CREATE PROCEDURE `deleteTgGetterByUserId`(IN userId INT, IN getId INT, IN deleterId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) INTO channelId;

    UPDATE tg_get SET tg_get.deleted = 1, tg_get.deleted_by = deleterId WHERE tg_get.channel_id = channelId and tg_get.tg_get_id = getId and tg_get.deleted = 0;
END ;;



CREATE PROCEDURE `deleteTgLink`(IN userId int)
BEGIN
    DECLARE requestId INT DEFAULT 0;
    DECLARE responseId int DEFAULT 0;
    DECLARE tgId BIGINT DEFAULT 0;

  SELECT request.request_id, response.response_id, response.tg_id INTO requestId, responseId, tgId from request left join response on response.request_id = request.request_id where request.user_id = userId;
  if requestId > 0 and responseId > 0 THEN
    UPDATE tg_special_right set tg_special_right.deleted = 1, tg_special_right.deleted_at = CURRENT_TIMESTAMP where tg_special_right.tg_user_id = tgId and tg_special_right.right_type = 'WHITELIST' and tg_special_right.deleted = 0;
    UPDATE tg_special_right set tg_special_right.deleted = 1, tg_special_right.deleted_at = CURRENT_TIMESTAMP where tg_special_right.user_id = userId and tg_special_right.right_type = 'WHITELIST' and tg_special_right.deleted = 0;

    DELETE FROM response where response.response_id = responseId;
    DELETE FROM request where request.request_id = requestId;
  END IF;
end ;;



CREATE PROCEDURE `deleteTgSpecialRight`(IN channelName text, IN tgId int)
BEGIN

    UPDATE tg_special_right set tg_special_right.deleted = 1, tg_special_right.deleted_at = CURRENT_TIMESTAMP where tg_special_right.channel_id = (select channel.channel_id from channel where channel.channel_name = channelName) and tg_special_right.tg_user_id = tgId and tg_special_right.deleted = 0 and tg_special_right.right_type in ('BLACKLIST', 'WHITELIST');
END ;;



CREATE PROCEDURE `deleteTgSpecialRightByUserId`(IN userId text, IN tgId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) into channelId;

    if channelId>0 THEN
      UPDATE tg_special_right set tg_special_right.deleted = 1, tg_special_right.deleted_at = CURRENT_TIMESTAMP where tg_special_right.channel_id = channelId and tg_special_right.tg_user_id = tgId and tg_special_right.deleted = 0;
    END IF;
END ;;


CREATE PROCEDURE `getActiveRequestByCode`(IN inputCode text)
BEGIN
  select r.request_id, r.code from request r where r.code = inputCode and not exists(select 1 from response where response.request_id = r.request_id LIMIT 1);
END ;;



CREATE PROCEDURE `getAllTgGettersByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) INTO channelId;

    SELECT tgg.tg_get_id, tgg.keyword, tgg.original_msg_id, tgg.cache_message_id, tgg.broken, u.name FROM tg_get tgg LEFT JOIN user u on u.user_id = tgg.created_by_user_id WHERE tgg.channel_id = channelId and tgg.deleted = 0;
END ;;



CREATE PROCEDURE `getChannelCommandsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    
    select getChannelIdByUserId(userId) into channelId;
    if channelId > 0 THEN
      SELECT
        cc.channel_command_id,
        cc.channel_id,
        cc.command AS name,
        cc.action,
        cc.level,
        cc.active,
        cc.cooldown,
        cc.repeat_amount,
        cc.reply_message,
        cc.additional_text,
        cc.check_type
      FROM channel_command cc WHERE cc.channel_id = channelId;
    END IF;
END ;;



CREATE PROCEDURE `getChannelNoticesByUserId`(IN userId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

   SELECT cn.channel_notice_id, cn.notice_type_id, cn.count_to, cn.count_from, cn.reply FROM channel_notice cn WHERE cn.channel_id = channelId;
END ;;



CREATE PROCEDURE `getChannelPointRewardsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

   SELECT * FROM channel_point_action cpa WHERE cpa.channel_id = channelId;
END ;;



CREATE PROCEDURE `getChannelTgAwards`(IN channelName text)
BEGIN
    DECLARE channelId INT DEFAULT 0;

    select c.channel_id into channelId from channel c WHERE c.channel_name = channelName;

    if channelId > 0 THEN
      select * from tg_award where tg_award.channel_id = channelId;
    END IF;
END ;;



CREATE PROCEDURE `getChatMessages`(IN userId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;

    SELECT getChannelIdByUserId(userId) into channelId;
    if channelId > 0 THEN
      select tm.twitch_message_id, tm.message, tm.created_at, IFNULL(u.dname, u.name) AS `name` from twitch_message tm LEFT JOIN user u on u.user_id = tm.user_id WHERE tm.channel_id = channelId and u.user_id not in (15774) ORDER BY created_at DESC ;
    end if;
end ;;



CREATE PROCEDURE `getChatMostActiveUser`(IN channelId INT, IN wihinLastSeconds INT)
BEGIN
    SELECT tm.user_id, u.name, u.dname, count(*) AS 'count'
    FROM twitch_message tm
      LEFT JOIN user u ON u.user_id = tm.user_id
    WHERE tm.channel_id = channelId AND tm.created_at >= NOW() - INTERVAL wihinLastSeconds SECOND AND tm.user_id not in (4419, 15774)
    GROUP BY tm.user_id
    ORDER BY count(tm.user_id)
    DESC LIMIT 10;
  END ;;



CREATE PROCEDURE `getCommandIdByName`(IN channelName text, IN commandname text, OUT commandId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;

    select c.channel_id into channelId from channel c WHERE c.channel_name = channelName;
    select cc.channel_command_id into commandId from channel_command cc WHERE cc.command = commandname and cc.channel_id = channelId;
  END ;;



CREATE PROCEDURE `getGlobalEventTopData`(IN eventKey TEXT)
main:BEGIN

    DECLARE eventId INT DEFAULT 0;
    SELECT ge.global_event_id INTO eventId FROM global_event ge WHERE ge.event_key = eventKey ORDER BY ge.active_to DESC LIMIT 1;
    SELECT u.user_id, u.name, u.dname, ger.amount, ger.val from global_event ge left join global_event_reward ger on ge.global_event_id = ger.global_event_id left join user u on u.user_id = ger.user_id WHERE ge.global_event_id = eventId ORDER BY ger.amount desc;
END ;;



CREATE PROCEDURE `getGroupMembersRightsByUserId`(IN userId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) into channelId;

    if channelId>0 THEN
      SELECT sr.right_type, sr.tg_user_id, sr.user_first_name, sr.user_last_name, sr.username, getTwitchNameByTgId(sr.tg_user_id) twitch_name, sr.ts, getUserLabelByTgId(sr.by_tg_user_id) added_by from tg_special_right sr WHERE sr.deleted = 0 and sr.channel_id = channelId;
    END IF;
END ;;



CREATE PROCEDURE `getRemindersByUserId`(IN userId int)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    if channelId > 0 THEN
      select r.reminder_id, r.reminder_key, r.reminder_text, r.completed, r.completed_at from reminder r where r.channel_id = channelId;
    END IF;
END ;;



CREATE PROCEDURE `getRequestsByTwitchId`(IN twitchId int)
BEGIN
  SELECT request_id, code FROM request WHERE request.user_id = (select user.user_id from user where user.tw_id = twitchId);
END ;;



CREATE PROCEDURE `getSudoListForWeb`(IN userId INT)
BEGIN
    SELECT c.channel_id, c.user_id, c.channel_name, cu.tw_id from tg_special_right sr left join channel c on c.channel_id = sr.channel_id left join user cu on cu.user_id = c.user_id WHERE sr.user_id = userId and sr.right_type = 'SUDO' and sr.deleted = 0 and c.allow_web_access = TRUE;
end ;;



CREATE PROCEDURE `getTgAwardsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    SELECT a.tg_award_id, a.award_key, a.award_template, a.ts, u.name, CAST((SELECT COUNT(*) FROM tg_award_user au WHERE au.tg_award_id = a.tg_award_id) AS UNSIGNED) as users, CAST((SELECT SUM(tg_award_user.counter) FROM tg_award_user WHERE tg_award_user.tg_award_id = a.tg_award_id AND tg_award_user.counter > 0) AS UNSIGNED) as total FROM tg_award a LEFT JOIN user u on u.user_id = a.user_id WHERE a.channel_id = channelId and a.deleted = 0;
END ;;



CREATE PROCEDURE `getTgBannedMediaByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    SELECT bm.tg_banned_media_id, bm.channel_id, bm.media_type, bm.media_id, bm.about, bm.ban_ts, u.name FROM tg_banned_media bm LEFT JOIN user u on u.user_id = bm.user_id WHERE bm.channel_id = channelId;
END ;;



CREATE PROCEDURE `getTgBannedWordsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    SELECT tw.tg_word_id, tw.restrict_type_id, tw.word, u.name, tw.created_ts FROM channel c LEFT JOIN channel_subchat cs ON cs.channel_id = c.channel_id LEFT JOIN tg_word tw ON tw.channel_subchat_id = cs.channel_subchat_id LEFT JOIN user u ON u.user_id = tw.user_id WHERE c.channel_id = channelId;
END ;;



CREATE PROCEDURE `getTgGetter`(IN channelId INT, IN kw VARCHAR(100))
BEGIN

  SELECT tgg.tg_get_id, tgg.keyword, tgg.text, tgg.cache_message_id, tgg.original_msg_id, tgg.access FROM tg_get tgg WHERE tgg.channel_id = channelId and tgg.keyword = kw and tgg.deleted = 0;
END ;;



CREATE PROCEDURE `getTgGroupMembersByUserId`(IN userId int)
BEGIN
    DECLARE groupId INT DEFAULT 0;
    
    select getTelegramGroupIdByUserId(userId) into groupId;
    if groupId > 0 THEN 
      SELECT c.tg_chat_id, c.tg_user_id, c.tg_first_name, c.tg_second_name, c.tg_username, c.sub_type, req.user_id, u.name from tg_group_member c
      left join response resp on resp.tg_id = c.tg_user_id
        left join request req on req.request_id = resp.request_id
        left join user u on u.user_id = req.user_id
        where c.tg_chat_id = (SELECT channel_subchat.tg_chat_id FROM channel_subchat WHERE channel_subchat.channel_subchat_id = groupId);
    END IF;
END ;;



CREATE PROCEDURE `getTgStatsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) into channelId;

    SELECT st.type, st.counter, st.when_dt from stats_tg st WHERE st.channel_id = channelId and st.type in ('message', 'join', 'kick', 'sub', 'total');
  END ;;



CREATE PROCEDURE `getTgUserAwards`(IN channelName TEXT, IN tgUserId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select c.channel_id into channelId from channel c WHERE c.channel_name = channelName;

    if channelId > 0 THEN
      select tau.counter, ta.award_key, ta.award_template from tg_award_user tau join tg_award ta on ta.tg_award_id = tau.tg_award_id and ta.channel_id = channelId and ta.deleted = 0 where tau.tg_user_id = tgUserId;
    END IF;
END ;;



CREATE PROCEDURE `getTgUserLastStatsByUserId`(IN userId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    SELECT getChannelIdByUserId(userId) into channelId;

    SELECT st.type, st.counter, st.when_dt FROM stats_tg st WHERE st.channel_id = channelId AND st.when_dt IN (SELECT max(stats_tg.when_dt) FROM stats_tg WHERE stats_tg.channel_id = channelId) AND st.type in ('sub', 'nonsub', 'bots', 'total', 'bls', 'wls');
  END ;;



CREATE PROCEDURE `getTwitchWebLogin`(IN twitchUserId INT)
BEGIN
    select u.user_id, u.tw_id, u.name, u.dname, u.is_admin, u.supporter, c.channel_id, c.allow_web_access from user u left join channel c on c.user_id = u.user_id where u.tw_id = twitchUserId;
end ;;

CREATE PROCEDURE `initNewChannel`(IN twitchName varchar(200), IN twitchId int)
BEGIN
    DECLARE existingTwitchUserId int DEFAULT 0;
    DECLARE existingChannelId INT DEFAULT 0;
    DECLARE existingSubChatId INT DEFAULT 0;

    CALL createUser(twitchId, twitchName);

    select u.user_id into existingTwitchUserId from user u WHERE u.tw_id = twitchId;

    SELECT c.channel_id INTO existingChannelId FROM channel c WHERE c.channel_name = twitchName;
    if existingChannelId = 0 THEN
      INSERT INTO channel (user_id, channel_name, command_symbol, auto_join, save_irc, moobot_react) VALUES (existingTwitchUserId, twitchName, '!', 1, 1, 0);
      SELECT c.channel_id INTO existingChannelId FROM channel c WHERE c.channel_name = twitchName;
    END IF;

    if existingChannelId > 0 THEN
      call createChannelMessageTable(existingChannelId);

      select sc.channel_subchat_id into existingSubChatId from channel_subchat sc WHERE sc.channel_id = existingChannelId;
      if existingSubChatId = 0 THEN
        insert into channel_subchat (channel_id, tg_chat_id, tg_chat_name, join_link, warn_period, clean_period, enabled_join, join_follower_only, join_sub_only, ban_time, bot_lang, last_member_refresh, refresh_status, auto_kick, random_cooldown, random_enabled, welcome_message, auto_mass_kick, last_auto_kick, notify_stream_status, getter_cooldown)
          VALUES (existingChannelId, 0, '', '', 1, 1, 0, 0, 0, 60, 'en', CURRENT_TIMESTAMP, 'DONE', 1, 60, 0, '', 0, CURRENT_TIMESTAMP, 1, 10);
        select sc.channel_subchat_id into existingSubChatId from channel_subchat sc WHERE sc.channel_id = existingChannelId;
      END IF;

    END IF;
END ;;



CREATE PROCEDURE `insertAuth`(IN login text, IN authType text, IN authToken text, IN refreshToken text, IN expiresIn int, IN authCcope text)
BEGIN
   	DECLARE userId INT DEFAULT 0;
    DECLARE authId INT DEFAULT 0;
    DECLARE debug BOOLEAN DEFAULT true;
    DECLARE expiresAt DATETIME DEFAULT CURRENT_TIMESTAMP;
   	SELECT c.user_id INTO userId FROM user c WHERE c.name = login;

    if userId=0 THEN
    	INSERT INTO user (name) values (login);
        SELECT c.user_id INTO userId FROM user c WHERE c.name = login;
    END IF;

    if userId>0 THEN
      SELECT DATE_ADD(expiresAt, INTERVAL expiresIn SECOND) into expiresAt;
    	SELECT a.auth_id INTO authId FROM auth a WHERE a.user_id = userId and a.type = authType;
    	IF authId=0 THEN
          INSERT INTO auth (user_id, type, token, refresh_token, scope, expires_at) VALUES(userId, authType, authToken, refreshToken, authCcope, expiresAt);
      ELSE
          UPDATE auth SET auth.token = authToken, auth.refresh_token = refreshToken, auth.scope = authCcope, auth.expires_at = expiresAt WHERE auth.auth_id = authId;
      END IF;
    END IF;

   	END ;;



CREATE PROCEDURE `insertAuthByUserId`(IN twId      INT, IN authType TEXT, IN authToken TEXT, IN refreshToken TEXT,
                                    IN expiresIn INT, IN authCcope TEXT)
BEGIN
   	DECLARE userId INT DEFAULT 0;
    DECLARE authId INT DEFAULT 0;
    DECLARE channelId INT DEFAULT 0;
    DECLARE expiresAt DATETIME DEFAULT CURRENT_TIMESTAMP;
   	SELECT c.user_id INTO userId FROM user c WHERE c.tw_id = twId;

    if userId=0 THEN
    	INSERT INTO user (tw_id, name, is_admin, tg_about) values (twId, '', 0, NULL);
        SELECT c.user_id INTO userId FROM user c WHERE c.tw_id = twId;
    END IF;

    if userId>0 THEN
      SELECT DATE_ADD(expiresAt, INTERVAL expiresIn SECOND) into expiresAt;
    	SELECT a.auth_id INTO authId FROM auth a WHERE a.user_id = userId and a.type = authType;
    	IF authId=0 THEN
          INSERT INTO auth (user_id, type, token, refresh_token, scope, expires_at) VALUES(userId, authType, authToken, refreshToken, authCcope, expiresAt);
      ELSE
          UPDATE auth SET auth.token = authToken, auth.refresh_token = refreshToken, auth.scope = authCcope, auth.expires_at = expiresAt WHERE auth.auth_id = authId;
      END IF;

      select getChannelIdByUserId(userId) into channelId;
      IF channelId>0 THEN
        UPDATE channel_subchat SET channel_subchat.auth_status = 1 WHERE channel_subchat.channel_id = channelId;
      END IF;
    END IF;

   	END ;;


CREATE PROCEDURE `registerNewTwitchProfile`(IN inputUserId INT)
BEGIN
    DECLARE userId INT;
    DECLARE existingId INT DEFAULT 0;
    
    select u.user_id into userId from user u WHERE u.user_id = inputUserId;
    if userId > 0 THEN
      select pt.profile_twitch_id into existingId from profile_twitch pt WHERE pt.user_id = userId;

      IF existingId = 0 THEN
          INSERT INTO profile_twitch (user_id) VALUES (userId);
      END IF;
    end if;
end ;;



CREATE PROCEDURE `saveChannel`(IN channelName text, IN autoJoin tinyint(1), IN saveIrc tinyint(1), IN symbol varchar(1), OUT sta tinyint(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;

    set sta = 0;

    select c.channel_id into channelId from channel c WHERE c.channel_name = channelName;

    IF channelId>0 THEN
      UPDATE channel SET channel.auto_join = autoJoin, channel.save_irc = saveIrc, channel.command_symbol = symbol WHERE channel.channel_id = channelId;
      set sta = 1;
    END IF;
END ;;



CREATE PROCEDURE `saveChannelNoticeByUserId`(IN userId int, IN noticeId int, IN noticeTypeId int, IN countFrom int, IN countTo int, IN noticeReply text, OUT sta tinyint(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE exitingNoticeId int DEFAULT 0;
    declare overlapId int DEFAULT 0;
    set sta = 0;

    select getChannelIdByUserId(userId) into channelId;
    SELECT cn.channel_notice_id into exitingNoticeId from channel_notice cn WHERE cn.channel_id = channelId and cn.channel_notice_id = noticeId;
    select cn.channel_notice_id into overlapId from channel_notice cn where cn.channel_notice_id != exitingNoticeId and cn.channel_id = channelId and cn.notice_type_id = noticeTypeId and ((cn.count_from <= countFrom AND cn.count_to >= countFrom) OR (cn.count_from <= countTo AND cn.count_to >= countTo)) limit 1;

    if overlapId>0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping notice counters';
    END IF;
    IF channelId>0 and overlapId=0 THEN
      IF exitingNoticeId>0 THEN
        UPDATE channel_notice SET channel_notice.notice_type_id = noticeTypeId, channel_notice.count_from = countFrom, channel_notice.count_to = countTo, channel_notice.reply = noticeReply WHERE channel_notice.channel_notice_id = exitingNoticeId;
      ELSE
        INSERT INTO  channel_notice (channel_id, notice_type_id, count_from, count_to, reply) VALUES (channelId, noticeTypeId, countFrom, countTo, noticeReply);
      END IF;

      set sta = 1;
    END IF;
END ;;



CREATE PROCEDURE `saveCommandByUserId`(IN userId INT,
                                     IN commandId INT,
                                     IN commandName TEXT,
                                     IN commandAction TEXT,
                                     IN commandLevel INT,
                                     IN commandActive INT,
                                     IN commandCooldown INT,
                                     IN commandRepeater INT,
                                     IN commandMessage TEXT,
                                     IN commandAdditional TEXT,
                                     OUT sta TINYINT(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE exitingCommandId int DEFAULT 0;
    DECLARE duplicateId int DEFAULT 0;

    set sta = 0;

    select getChannelIdByUserId(userId) into channelId;

    IF channelId>0 THEN
      IF commandId>0 THEN
        select cc.channel_command_id into exitingCommandId from channel_command cc WHERE cc.channel_command_id = commandId and cc.channel_id = channelId;
      END IF;

      if exitingCommandId=0 THEN
        select cc.channel_command_id into exitingCommandId from channel_command cc WHERE cc.command = commandName and cc.channel_id = channelId;
      END IF;

      select cc.channel_command_id into duplicateId from channel_command cc WHERE cc.command = commandName and cc.channel_id = channelId and cc.channel_command_id != exitingCommandId;

      IF duplicateId=0 THEN
        if exitingCommandId>0 THEN
          UPDATE channel_command SET channel_command.command = commandName,
                                     channel_command.action = commandAction,
                                     channel_command.level = commandLevel,
                                     channel_command.active = commandActive,
                                     channel_command.cooldown = commandCooldown,
                                     channel_command.repeat_amount = commandRepeater,
                                     channel_command.reply_message = commandMessage,
                                     channel_command.additional_text = commandAdditional
                                     WHERE channel_command.channel_command_id = exitingCommandId;
          ELSE
          INSERT INTO channel_command (channel_id, command, action, level, active, cooldown, repeat_amount, reply_message, additional_text)
              VALUES (channelId, commandName, commandAction, commandLevel, commandActive, commandCooldown, commandRepeater, commandMessage, commandAdditional);
        END IF;

        set sta = 1;
      END IF;

    END IF;
END ;;



CREATE PROCEDURE `savePointRewardByUserId`(IN userId        INT, IN rewardId INT, IN rewardAction VARCHAR(100),
                                         IN rewardTitle   TEXT, IN rewardData TEXT, IN rewardAmount INT,
                                         IN rewardEnabled TINYINT(1), IN rewardParentId INT, OUT sta TINYINT(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE existingRewardId int DEFAULT 0;
    set sta = 0;

    select getChannelIdByUserId(userId) into channelId;
    SELECT cpa.channel_point_action_id into existingRewardId from channel_point_action cpa WHERE cpa.channel_id = channelId and cpa.channel_point_action_id = rewardId;
    IF channelId>0 THEN
      IF existingRewardId>0 THEN
        UPDATE channel_point_action SET channel_point_action.channel_id = channelId,
                                        channel_point_action.action = rewardAction,
                                        channel_point_action.title = rewardTitle,
                                        channel_point_action.data = rewardData,
                                        channel_point_action.amount = rewardAmount,
                                        channel_point_action.parent_id = rewardParentId,
                                        channel_point_action.enabled = rewardEnabled,
                                        channel_point_action.updated_at = CURRENT_TIMESTAMP
                                        WHERE channel_point_action.channel_point_action_id = existingRewardId;
      ELSE
        INSERT INTO  channel_point_action (channel_id, action, title, data, amount, parent_id, enabled) VALUES (channelId, rewardAction, rewardTitle, rewardData, rewardAmount, rewardParentId, rewardEnabled);
      END IF;

      set sta = 1;
    END IF;
END ;;



CREATE PROCEDURE `saveReminderByUserId`(IN userId int, IN reminderId int, IN reminderKey varchar(200), IN reminderText text, IN compl tinyint(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE exitingReminderId int DEFAULT 0;
    DECLARE duplicateReminderId int DEFAULT 0;

    select getChannelIdByUserId(userId) into channelId;
    if channelId>0 THEN
      IF reminderId>0 THEN
        select r.reminder_id into exitingReminderId from reminder r WHERE r.reminder_id = reminderId and r.channel_id = channelId;
      END IF;

      if exitingReminderId>0 THEN
        UPDATE reminder SET reminder.reminder_key = reminderKey, reminder.reminder_text = reminderText, reminder.completed = compl, reminder.completed_at = IF(compl, CURRENT_TIMESTAMP, NULL) WHERE reminder.reminder_id = exitingReminderId;
      ELSE
        select r.reminder_id into duplicateReminderId from reminder r WHERE r.reminder_key = reminderKey and r.channel_id = channelId and r.completed_at = NULL;
        if duplicateReminderId=0 THEN
          INSERT INTO reminder (channel_id, reminder_key, reminder_text, completed, completed_at) VALUES (channelId, reminderKey, reminderText, compl, IF(compl, CURRENT_TIMESTAMP, NULL));
        ELSE
          UPDATE reminder SET reminder.reminder_key = reminderKey, reminder.reminder_text = reminderText, reminder.completed = compl, reminder.completed_at = IF(compl, CURRENT_TIMESTAMP, NULL) WHERE reminder.reminder_id = duplicateReminderId;
        END IF;
      END IF;
    END IF;
END ;;



CREATE PROCEDURE `saveRequest`(IN twitchId int, IN inputCode text)
BEGIN
  INSERT INTO request (user_id, code) VALUES ((select user.user_id from user where user.tw_id = twitchId), inputCode);
END ;;



CREATE PROCEDURE `saveTgGroup`(IN channelName text, IN joinLink varchar(50), IN warnPeriod int, IN cleanPeriod int, IN enabledJoin tinyint(1), IN joinSubOnly tinyint(1), IN allowPrime tinyint(1), IN banTime int, IN botLang varchar(10), IN autoKick tinyint(1), OUT sta tinyint(1))
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE exitingChatId int DEFAULT 0;
    SET sta = 0;

    SELECT c.channel_id INTO channelId FROM channel c WHERE c.channel_name = channelName;
    SELECT csb.channel_subchat_id into exitingChatId from channel_subchat csb where csb.channel_id = channelId;

    IF channelId>0 THEN
      IF exitingChatId>0 THEN
        UPDATE channel_subchat SET channel_subchat.join_link = joinLink, channel_subchat.warn_period = warnPeriod, channel_subchat.clean_period = cleanPeriod, channel_subchat.enabled_join = enabledJoin, channel_subchat.join_sub_only = joinSubOnly, channel_subchat.allow_prime = allowPrime, channel_subchat.ban_time = banTime, channel_subchat.bot_lang = botLang, channel_subchat.auto_kick = autoKick WHERE channel_subchat.channel_subchat_id = exitingChatId;
      ELSE
        INSERT INTO  channel_subchat (join_link, warn_period, clean_period, enabled_join, join_sub_only, allow_prime, ban_time, bot_lang, auto_kick) VALUES (joinLink, warnPeriod, cleanPeriod, enabledJoin, joinSubOnly, allowPrime, banTime, botLang, autoKick);
      END IF;

      set sta = 1;
    END IF;
END ;;



CREATE PROCEDURE `saveTgSpecialRight`(IN rightType text, IN channelId int, IN userId int, IN tgUserId int, IN firstname text, IN lastname text, IN tgUsername text, IN byId int, IN comm text)
main:BEGIN
    DECLARE existingChannelId INT DEFAULT 0;
    DECLARE exitingRightId int DEFAULT 0;

    select c.channel_id into existingChannelId from channel c WHERE c.channel_id = channelId;

    IF existingChannelId <= 0 then
      LEAVE main;
    END IF;

    select sr.tg_special_right_id into exitingRightId from tg_special_right sr where sr.channel_id = existingChannelId and sr.user_id = userId and sr.deleted = 0;

    if exitingRightId > 0 THEN
      UPDATE tg_special_right set tg_special_right.right_type = rightType, tg_special_right.user_id = userId, tg_special_right.user_first_name = firstname, tg_special_right.user_last_name = lastname, tg_special_right.username = tgUsername, tg_special_right.by_tg_user_id = byId, tg_special_right.comment = comm, tg_special_right.ts = CURRENT_TIMESTAMP() where tg_special_right.tg_special_right_id = exitingRightId;
    ELSE
      INSERT INTO tg_special_right (channel_id, right_type, tg_user_id, user_first_name, user_last_name, username, by_tg_user_id, user_id, comment) VALUES (existingChannelId, rightType, tgUserId, firstname, lastname, tgUsername, byId, userId, comm);
    END IF;
END ;;



CREATE PROCEDURE `saveTgSpecialRight2`(IN rightType text, IN channelId int, IN userId int, IN tgUserId int, IN firstname text, IN lastname text, IN tgUsername text, IN byId int)
main:BEGIN
    DECLARE existingChannelId INT DEFAULT 0;
    DECLARE exitingRightId int DEFAULT 0;

    select c.channel_id into existingChannelId from channel c WHERE c.channel_id = channelId;

    IF existingChannelId <= 0 then
      LEAVE main;
    END IF;

    select sr.tg_special_right_id into exitingRightId from tg_special_right sr where sr.channel_id = existingChannelId and sr.user_id = userId and sr.deleted = 0;

    if exitingRightId > 0 THEN
      UPDATE tg_special_right set tg_special_right.right_type = rightType, tg_special_right.user_id = userId, tg_special_right.user_first_name = firstname, tg_special_right.user_last_name = lastname, tg_special_right.username = tgUsername, tg_special_right.by_tg_user_id = byId, tg_special_right.ts = CURRENT_TIMESTAMP() where tg_special_right.tg_special_right_id = exitingRightId;
    ELSE
      INSERT INTO tg_special_right (channel_id, right_type, tg_user_id, user_first_name, user_last_name, username, by_tg_user_id, user_id) VALUES (existingChannelId, rightType, tgUserId, firstname, lastname, tgUsername, byId, userId);
    END IF;
END ;;



CREATE PROCEDURE `setGlobalEventRewardForUser`(IN eventId INT, IN userId INT, IN newAmount INT, IN newVel TEXT)
main:BEGIN
    DECLARE existingRecordId INT DEFAULT 0;

    select ger.global_event_reward_id into existingRecordId from global_event_reward ger WHERE ger.global_event_id = eventId and ger.user_id = userId;

    IF existingRecordId > 0 then
      UPDATE global_event_reward ger set ger.amount = newAmount, ger.val = newVel where ger.global_event_reward_id = existingRecordId;
    else
      INSERT INTO global_event_reward (global_event_id, user_id, amount, val) values (eventId, userId, newAmount, newVel);
    end IF;
END ;;



CREATE PROCEDURE `setTgGetter`(IN channelId INT, IN kw VARCHAR(100), IN txt TEXT, IN cachedMsgId TEXT, IN userId INT, IN accessLevel INT)
BEGIN
    DECLARE chanId INT DEFAULT 0;
    DECLARE existingTgKbId INT DEFAULT 0;

    select c.channel_id into chanId from channel c WHERE c.channel_id = channelId;

    if chanId > 0 THEN
      SELECT tg_get.tg_get_id into existingTgKbId FROM tg_get where tg_get.channel_id = chanId and tg_get.keyword = kw and tg_get.deleted = 0;
      if existingTgKbId = 0 THEN
        INSERT into tg_get (channel_id, keyword, cache_message_id, text, created_by_user_id, access) VALUES (chanId, kw, cachedMsgId, txt, userId, accessLevel);
      END IF;
    END IF;
END ;;



CREATE PROCEDURE `updateAuthData`(IN userId INT, IN activeToken VARCHAR(250), refreshToken VARCHAR(250), IN expiresAt INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;
    
    UPDATE auth SET auth.token = activeToken, auth.expires_at = CURRENT_TIMESTAMP + interval expiresAt second, auth.refresh_token = refreshToken where auth.type = 'BOT' and auth.user_id = userId;
    
    IF channelId>0 THEN
      UPDATE channel_subchat SET channel_subchat.auth_status = 1 WHERE channel_subchat.channel_id = channelId;
    END IF;
  END ;;



CREATE PROCEDURE `updateCommandUsage`(IN commandId INT)
BEGIN
    UPDATE channel_command cm SET cm.used = cm.used + 1 where cm.channel_command_id = commandId;
end ;;



CREATE PROCEDURE `updateLastTgReminder`(IN subchatId int)
BEGIN
    UPDATE channel_subchat set channel_subchat.last_reminder = current_timestamp where channel_subchat.channel_subchat_id = subchatId;
END ;;



CREATE PROCEDURE `updateTgAwardByUserId`(IN userId INT, IN awardId INT, IN awardKey TEXT, IN awardTemplate TEXT, IN creatorId INT)
BEGIN
    DECLARE channelId INT DEFAULT 0;
    DECLARE existingAwardId INT DEFAULT 0;
    select getChannelIdByUserId(userId) into channelId;

    SELECT ta.tg_award_id INTO existingAwardId FROM tg_award ta WHERE ta.channel_id = channelId and ta.tg_award_id = awardId and ta.deleted = 0;

    IF existingAwardId > 0 THEN
      UPDATE tg_award SET tg_award.award_key = awardKey,
                          tg_award.award_template = awardTemplate,
                          tg_award.user_id = creatorId
      WHERE tg_award.tg_award_id = awardId;
    ELSE
      INSERT INTO tg_award (channel_id, award_key, award_template, user_id) VALUES(channelId, awardKey, awardTemplate, creatorId);
    END IF;
  END ;;



CREATE PROCEDURE `updateUserTgAward`(IN tgAwardId int, IN tgUserId int, IN cnt int)
BEGIN
    DECLARE existingId INT DEFAULT 0;

    select tg_award_user.tg_award_user_id into existingId from tg_award_user where tg_award_user.tg_award_id = tgAwardId and tg_award_user.tg_user_id = tgUserId;

    if existingId > 0 THEN
      UPDATE tg_award_user SET tg_award_user.counter = GREATEST(tg_award_user.counter + cnt, 0) WHERE tg_award_user.tg_award_user_id = existingId;
      ELSE
      INSERT into tg_award_user (tg_award_id, tg_user_id, counter) VALUES (tgAwardId, tgUserId, cnt);
    END IF;
END ;;



CREATE PROCEDURE `validateBotToken`(IN authToken text, OUT tokenStatus int, OUT channelName text, OUT isAdmin tinyint(1))
BEGIN
    DECLARE userId INT DEFAULT 0;
    DECLARE expiresAt datetime;
    DECLARE webRightId int DEFAULT 0;
    DECLARE userRightId int default 0;
    # 0 - not active
    # 1 - active
    # 2 - expired

    SET tokenStatus = 0;
    SET isAdmin = 0;

    select a.user_id, a.expires_at into userId, expiresAt FROM auth a where a.token = authToken and a.type = 'BOT';
    IF userId>0 THEN
      set tokenStatus = 1;
      select c.name into channelName from user c WHERE c.user_id = userId;
      select r.right_type_id into webRightId from right_type r where r.right_key = 'web_admin';
      select ur.user_web_right_id into userRightId from user_web_right ur where ur.right_type_id =  webRightId and ur.user_id = userId;

      if userRightId>0 THEN
        SET isAdmin = 1;
      END IF;

      if expiresAt<=current_timestamp() then
        SET tokenStatus = 2;
      END IF;
    END IF;
  END ;;



CREATE PROCEDURE `validateToken`(IN authType varchar(10), IN authToken text, OUT tokenStatus int, OUT channelName text, OUT isAdmin tinyint(1))
BEGIN
    DECLARE userId INT DEFAULT 0;
    DECLARE expiresAt datetime;
    DECLARE webRightId int DEFAULT 0;
    DECLARE userRightId int default 0;
    # 0 - not active
    # 1 - active
    # 2 - expired

    SET tokenStatus = 0;
    SET isAdmin = 0;

    select a.user_id, a.expires_at into userId, expiresAt FROM auth a where a.token = authToken and a.type = authType;
    IF userId>0 THEN
      set tokenStatus = 1;
      select c.name into channelName from user c WHERE c.user_id = userId;
      select r.right_type_id into webRightId from right_type r where r.right_key = 'web_admin';
      select ur.user_web_right_id into userRightId from user_web_right ur where ur.right_type_id =  webRightId and ur.user_id = userId;

      if userRightId>0 THEN
        SET isAdmin = 1;
      END IF;

      if expiresAt<=current_timestamp() then
        SET tokenStatus = 2;
      END IF;
    END IF;
  END ;;



CREATE PROCEDURE `validateWebToken`(IN authToken text, OUT tokenStatus int, OUT channelName text, OUT isAdmin tinyint(1))
BEGIN
    DECLARE userId INT DEFAULT 0;
    DECLARE expiresAt datetime;
    DECLARE webRightId int DEFAULT 0;
    DECLARE userRightId int default 0;
    # 0 - not active
    # 1 - active
    # 2 - expired

    SET tokenStatus = 0;
    SET isAdmin = 0;

    select a.user_id, a.expires_at into userId, expiresAt FROM auth a where a.token = authToken and a.type = 'WEB';
    IF userId>0 THEN
      set tokenStatus = 1;
      select c.name into channelName from user c WHERE c.user_id = userId;
      select r.right_type_id into webRightId from right_type r where r.right_key = 'web_admin';
      select ur.user_web_right_id into userRightId from user_web_right ur where ur.right_type_id =  webRightId and ur.user_id = userId;

      if userRightId>0 THEN
        SET isAdmin = 1;
      END IF;

      if expiresAt<=current_timestamp() then
        SET tokenStatus = 2;
      END IF;
    END IF;
  END ;;