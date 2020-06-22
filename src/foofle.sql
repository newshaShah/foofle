-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 22, 2020 at 08:25 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foofle`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user` (IN `FirstName` VARCHAR(20), IN `LastName` VARCHAR(20), IN `Alias` VARCHAR(20), IN `Address` VARCHAR(100), IN `bdate` VARCHAR(10), IN `Phone` CHAR(11), IN `nId` VARCHAR(20), IN `UserName` VARCHAR(20), IN `pass` VARCHAR(20), IN `AccountPhone` CHAR(11))  begin
if not EXISTS(select * from user where UPPER(user.username) = UPPER(UserName) or user.nationalId = nId)
then 
	begin
   	 	if length(pass) >5 
        THEN
        begin
        	if  length(UserName)> 5
            THEN
            BEGIN
            	INSERT INTO user (firstName,lastName,alias,address,birthDate,phone,nationalId,username,password,creationDate,accountPhone)
				values(FirstName,LastName,Alias,Address,bdate,Phone,nId,UserName,md5(pass),current_timestamp(),AccountPhone
); 
				select 'you have signed up successfully';
			end;
			else
				begin 
					select 'username length should be more than 5';
				end;


            end if;
		end;
		else
			begin 
				select 'password length should be more than 5';
			end;
			
        end if;
	end;
	else
		begin
			select 'user already exist';
		end;
		
    end if;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `block_user` (IN `user2` VARCHAR(20))  NO SQL
begin 
	call get_last_login(@user1);
	
	if upper(@user1) in (select upper(user.username) from user) THEN
		BEGIN
			if upper(user2) in (select upper(user.username) from user) then
				begin
					if exists(select * from blocked_users where upper(blocked_users.firstUser) = upper(@user1) and  upper(blocked_users.secondUser) = upper(user2)) then
						begin
							select 'user is already blocked';
						end;
						else 
							begin
								if @user1  = user2 then begin select 'You can not block yourself!!!'; end;
								else
									begin
										insert into blocked_users(firstUser,secondUser) values(@user1,user2);
										select 'you have successfully blocked this user';
									end;
								end if;
							end;
					end if;
					
						
				end;
				else
					begin
						select 'second user was not found';
					end;
				
			end if;
		end;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_account` ()  NO SQL
begin
call get_last_login(@uname);
SET @email = (Select CONCAT (@uname, "@foofle.com"));
DELETE FROM user WHERE upper(user.username)= upper(@uname);
DELETE FROM news WHERE upper(news.account)= upper(@uname);
DELETE FROM blocked_users
WHERE upper( blocked_users.firstUser)= upper(@uname) or   upper(blocked_users.secondUser)= upper(@uname) ;
DELETE FROM logs WHERE upper(logs.user)= upper(@uname);

DELETE from email where upper(@email) = upper(email.sender);
DELETE from emailreceiver where upper(@email) = upper (emailreceiver.sender) or upper(@email) = upper (emailreceiver.receiver);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_inbox_email` (IN `Sender` VARCHAR(20), IN `Time` TIMESTAMP)  NO SQL
BEGIN
	call get_last_login(@Username);
	SET @reciverEmail = (Select CONCAT (@Username, "@foofle.com"));
    SET @senderEmail = (Select CONCAT (Sender,"@foofle.com"));
	delete from emailreceiver
    where emailreceiver.sender = @senderEmail and emailreceiver.receiver =  @reciverEmail and emailreceiver.time = Time;
    
    SET @message = (Select CONCAT ("You have successfully deleted an email from: ",Sender));
    insert into news(news.text,news.account,news.time)
    values(@message,@Username,CURRENT_TIME());
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_sent_email` (IN `Time` TIMESTAMP)  NO SQL
BEGIN
	call get_last_login(@Username);

    SET @senderEmail = (Select CONCAT (@Username,"@foofle.com"));
	update email
	set email.deleteForSender = 1
    where email.sender = @senderEmail and 
    email.time = Time;

    
    SET @message = (Select CONCAT ("You have successfully deleted an email which was sent in: " ,Time));
    insert into news(news.text,news.account,news.time)
    values(@message,@Username,CURRENT_TIME());
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_account` (IN `Firstname` VARCHAR(20), IN `Lastname` VARCHAR(20), IN `Alias` VARCHAR(20), IN `Address` VARCHAR(100), IN `Birthdate` VARCHAR(10), IN `Phone` VARCHAR(11), IN `Nationalid` VARCHAR(20), IN `Password` VARCHAR(40), IN `Accountphone` CHAR(11))  NO SQL
begin
call get_last_login(@Username);
UPDATE user
SET user.firstName = Firstname,
user.lastName=Lastname,
user.alias=Alias,
user.address=Address,
user.birthDate=Birthdate,
user.phone=Phone,
user.nationalId=Nationalid,
user.password=md5(Password),
user.accountPhone=Accountphone
WHERE user.username = @Username;

insert into news(text,account,time)
values('you have successfully edit your account', @Username,CURRENT_TIME());


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `email_inbox` (IN `page` INT(10))  NO SQL
BEGIN
call get_last_login(@Username);
SET @reciverEmail = (Select CONCAT (@Username, "@foofle.com"));
set page = (page  - 1)*10;
SELECT email.sender,email.subject,email.time,emailreceiver.isRead
from emailreceiver,email
where email.sender = emailreceiver.sender and email.time = emailreceiver.time and emailreceiver.receiver = @reciverEmail
order by email.time DESC
LIMIT  10 OFFSET page;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `email_sent` (IN `page` INT(10))  NO SQL
BEGIN
call get_last_login(@Username);
SET @senderEmail = (Select CONCAT (@Username,"@foofle.com"));
set page = (page  - 1)*10;
SELECT email.subject,email.time,emailreceiver.receiver,emailreceiver.isRead,emailreceiver.isCC
from emailreceiver,email
where email.sender = @senderEmail and email.sender=emailreceiver.sender and email.time = emailreceiver.time and email.deleteForSender <>1
order by email.time DESC
LIMIT  10 OFFSET page;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_last_login` (OUT `Username` VARCHAR(20))  NO SQL
select l1.user
from logs as l1
where not EXISTS (select* from logs as l2
                  where l2.time > l1.time) into Username$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_my_inf` ()  BEGIN
	call get_last_login(@username);
      select firstName,lastName,alias,address,birthDate,phone,nationalId,username,accountPhone,creationDate from user where 			upper(user.username)=upper(@username);
      select 'your personal information';
      
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_news` ()  BEGIN
	call get_last_login(@username);
      select text,time
      from news 
      where upper(news.account)=upper(@username)
      
      order by news.time DESC;
   END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_others_inf` (IN `otherUsername` VARCHAR(20))  begin 
	call get_last_login(@myUsername);
		if upper(@myUsername) in (select upper(user.username) from user) THEN
		BEGIN
			if upper(otherUsername) in (select upper(user.username) from user) then
				begin
				
					
					if not exists(select * from blocked_users  where upper(blocked_users.secondUser) = upper(@myUsername) and  upper(blocked_users.firstUser) = upper(otherUsername)) then
						begin
								
							SEt @message = (Select CONCAT (@myUsername, " requested to view your profile and had access to it "));
										
							insert into news(text,account,time)
										values(@message,otherUsername,CURRENT_TIME());
							
							select * from personal_information
								where username = otherUsername;
								
						end;
						else 
							begin
							SEt @message = (Select CONCAT (@myUsername, " requested to view your profile but didn't have access to it "));
										
							insert into news(text,account,time)
										values(@message,otherUsername,CURRENT_TIME());
								select '**********************';
								
								
							end;
					end if;
					
						
				end;
				else
				begin
					select 'user was not found';
				end;
				
				
			end if;
		end;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `uname` VARCHAR(20), IN `pass` VARCHAR(20))  begin
if not EXISTS(select * from user where UPPER(user.username) = UPPER(uname) and user.password= md5(pass))
then 
	begin
		select 'username or password incorrect try again';
       
	end;
	else
		begin
			select 'You have successfully loged in';
			INSERT INTO logs (user,time)
			SELECT * FROM (SELECT uname,current_timestamp()) AS tmp
			WHERE uname In (
			SELECT user.username FROM user WHERE 	  UPPER(user.username) = UPPER(uname) and user.password= md5(pass)
			);

		end;
		
    end if;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `read_inbox_email` (IN `Sender` VARCHAR(20), IN `Time` TIMESTAMP)  NO SQL
BEGIN
call get_last_login(@Username);
SET @senderEmail = (Select CONCAT (Sender, "@foofle.com"));
SET @receiverEmail = (Select CONCAT (@Username, "@foofle.com"));

select text 
from email,emailreceiver 
where email.sender = @senderEmail and email.time = Time and emailreceiver.sender = email.sender and email.time = emailreceiver.time and emailreceiver.receiver = @receiverEmail;

update emailreceiver
set emailreceiver.isRead = 1
where emailreceiver.sender =  @senderEmail
and emailreceiver.time = Time
and emailreceiver.receiver = @receiverEmail;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `read_sent_email` (IN `Time` TIMESTAMP)  NO SQL
BEGIN
call get_last_login(@Username);
SET @senderEmail = (Select CONCAT (@Username,"@foofle.com"));
select text 
from email 
where sender = @senderEmail and email.time = Time and email.deleteForSender = 0;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_email` (IN `Subject` VARCHAR(30), IN `Text` VARCHAR(1000), IN `receiver1` VARCHAR(20), IN `receiver2` VARCHAR(20), IN `receiver3` VARCHAR(20), IN `receivercc1` VARCHAR(20), IN `receivercc2` VARCHAR(20), IN `receivercc3` VARCHAR(20))  BEGIN
	call get_last_login(@sender);
		if upper(@sender) in (select upper(user.username) from user) THEN
			BEGIN
				SET @senderEmail = (Select CONCAT (@sender, "@foofle.com"));
				
				
				if receiver1 <> '' then
				begin
					if upper(receiver1) in (select upper(user.username) from user) THEN
					begin
						SET @receiver1Email = (Select CONCAT (receiver1, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver)
									values(@senderEmail,CURRENT_TIME(),@receiver1Email);
									
									insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
					end;
					else 
						begin
							select 'first receiver was not valid.';
						end;
					end if;
				end;
				end if;
				
				
				if receiver2 <> '' then
				begin
					if upper(receiver2) in (select upper(user.username) from user) THEN
					begin
						SET @receiver2Email = (Select CONCAT (receiver2, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver)
									values(@senderEmail,CURRENT_TIME(),@receiver2Email);
									if not exists(select * from email where upper(email.sender) = upper(@senderEmail) and email.time = Time) then
										begin
											insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
										end;
									end if;
					end;
					else 
						begin
							select 'second receiver was not valid.';
						end;
					end if;
				end;
				end if;
				
				if receiver3 <> '' then
				begin
					if upper(receiver3) in (select upper(user.username) from user) THEN
					begin
						SET @receiver3Email = (Select CONCAT (receiver3, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver)
									values(@senderEmail,CURRENT_TIME(),@receiver3Email);
									if not exists(select * from email where upper(email.sender) = upper(@senderEmail) and email.time = Time) then
										begin
											insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
										end;
									end if;
					end;
					else 
						begin
							select 'third receiver was not valid.';
						end;
					end if;
				end;
				end if;
				
					if receivercc1 <> '' then
				begin
					if upper(receivercc1) in (select upper(user.username) from user) THEN
					begin
						SET @receivercc1Email = (Select CONCAT (receivercc1, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver,isCC)
									values(@senderEmail,CURRENT_TIME(),@receivercc1Email,1);
									if not exists(select * from email where upper(email.sender) = upper(@senderEmail) and email.time = Time)then
										begin
											insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
										end;
									end if;
					end;
					else 
						begin
							select 'cc receiver1  was not valid.';
						end;
					end if;
				end;
				end if;
				
				
							if receivercc2 <> '' then
				begin
					if upper(receivercc2) in (select upper(user.username) from user) THEN
					begin
						SET @receivercc2Email = (Select CONCAT (receivercc2, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver,isCC)
									values(@senderEmail,CURRENT_TIME(),@receivercc2Email,1);
									if not exists(select * from email where upper(email.sender) = upper(@senderEmail) and email.time = Time)then
										begin
											insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
										end;
									end if;
					end;
					else 
						begin
							select 'cc receiver2  was not valid.';
						end;
					end if;
				end;
				end if;
							if receivercc3 <> '' then
				begin
					if upper(receivercc3) in (select upper(user.username) from user) THEN
					begin
						SET @receivercc3Email = (Select CONCAT (receivercc3, "@foofle.com"));
									insert into emailreceiver(sender,time,receiver,isCC)
									values(@senderEmail,CURRENT_TIME(),@receivercc3Email,1);
									if not exists(select * from email where upper(email.sender) = upper(@senderEmail) and email.time = Time)then
										begin
											insert into email(sender,subject,time,text)
									values(@senderEmail,Subject,current_time(),Text);
										end;
									end if;
					end;
					else 
						begin
							select 'cc receiver2  was not valid.';
						end;
					end if;
				end;
				end if;
				
				
			end;
			else 
				begin
					select 'sender was not valid';
				end;
		end if;

	
        
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `unblock_user` (IN `otherUsername` VARCHAR(20))  NO SQL
begin 
		call get_last_login(@myUsername);
		if upper(@myUsername) in (select upper(user.username) from user) THEN
		BEGIN
			if upper(otherUsername) in (select upper(user.username) from user) then
				begin
				
					
					if not exists(select * from blocked_users  where upper(blocked_users.firstUser) = upper(@myUsername) and  upper(blocked_users.secondUser) = upper(otherUsername)) then
						begin
							select 'This user was not in your block list';
								
						end;
						else 
							begin
							
							delete from blocked_users where upper(firstUser) = upper(@myUsername) and upper(secondUser) = upper(otherUsername);
							select 'you have successfully unblocked this user';
								
							end;
					end if;
					
						
				end;
				
				
			end if;
		end;
	end if;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `blocked_users`
--

CREATE TABLE `blocked_users` (
  `firstUser` varchar(20) NOT NULL,
  `secondUser` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `blocked_users`
--

INSERT INTO `blocked_users` (`firstUser`, `secondUser`) VALUES
('royaaaaa', 'newsha'),
('mary78', 'royaaaaa');

-- --------------------------------------------------------

--
-- Table structure for table `email`
--

CREATE TABLE `email` (
  `sender` varchar(40) NOT NULL,
  `subject` varchar(30) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `text` varchar(1000) NOT NULL,
  `deleteForSender` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `email`
--

INSERT INTO `email` (`sender`, `subject`, `time`, `text`, `deleteForSender`) VALUES
('h_shahbodagh@foofle.', 'project', '2020-06-22 18:00:32', 'dear Hossein please come home', 0),
('h_shahbodagh@foofle.', 'project', '2020-06-22 18:00:33', 'dear Hossein please come home', 0),
('k1shah@foofle.com', 'k1email', '2020-06-22 16:18:29', 'this is a test email', 1),
('k1shah@foofle.com', 'blueberry', '2020-06-22 17:46:48', 'werthbvcxa', 0),
('k1shah@foofle.com', 'yellow', '2020-06-22 17:49:57', 'werfcds', 1),
('niloofar@foofle.com', 'email1', '2020-06-18 18:35:40', 'This is a test', 0),
('niloofar@foofle.com', 'email_1', '2020-06-18 18:37:43', 'This is a test', 0),
('rojin88@foofle.com', 'project', '2020-06-22 18:03:52', 'rtyuio', 1),
('rojin88@foofle.com', 'flower', '2020-06-22 18:17:40', 'this is a text', 1),
('tara77@foofle.com', 'tataEmail', '2020-06-22 15:42:18', 'ertyuiolkjhgfdxcvbn', 1),
('tara77@foofle.com', 'taraEmail', '2020-06-22 16:50:37', 'tyuiookjhgfd', 1),
('tara77@foofle.com', 'melon', '2020-06-22 17:25:11', 'buy melon', 0),
('vahi75@foofle.com', 'email2', '2020-06-18 18:39:12', 'This is second email', 0),
('vahi75@foofle.com', 'test', '2020-06-18 18:42:06', 'thtfgvkhvciyfgyhjb', 0),
('vahi75@foofle.com', 'test', '2020-06-18 18:42:36', 'thtfgvkhvciyfgyhjb', 0),
('vahi75@foofle.com', 'test', '2020-06-18 18:42:40', 'thtfgvkhvciyfgyhjb', 0),
('vahi75@foofle.com', 'bread', '2020-06-18 18:46:07', 'please buy bread on your way back home', 0);

-- --------------------------------------------------------

--
-- Table structure for table `emailreceiver`
--

CREATE TABLE `emailreceiver` (
  `sender` varchar(40) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `receiver` varchar(40) NOT NULL,
  `isRead` int(1) NOT NULL DEFAULT 0,
  `isCC` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `emailreceiver`
--

INSERT INTO `emailreceiver` (`sender`, `time`, `receiver`, `isRead`, `isCC`) VALUES
('niloofar@foofle.com', '2020-06-18 18:35:40', 'mary78@foofle.com', 0, 0),
('niloofar@foofle.com', '2020-06-18 18:35:40', 'hasan66@foofle.com', 0, 1),
('niloofar@foofle.com', '2020-06-18 18:35:40', 'niloofar@foofle.com', 0, 1),
('niloofar@foofle.com', '2020-06-18 18:37:43', 'mary78@foofle.com', 0, 0),
('niloofar@foofle.com', '2020-06-18 18:48:12', 'vahi75@foofle.com', 1, 0),
('niloofar@foofle.com', '2020-06-18 18:37:43', 'hasan66@foofle.com', 0, 1),
('niloofar@foofle.com', '2020-06-18 18:37:43', 'niloofar@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:39:12', 'newsha@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:39:12', 'royaaaaa@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:39:12', 'niloofar@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:39:12', 'hasan66@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:39:12', 'mary78@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:42:05', 'mary78@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:06', 'newsha@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:07', 'royaaaaa@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:07', 'hasan66@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:42:07', 'niloofar@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:42:36', 'mary78@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:36', 'newsha@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:36', 'royaaaaa@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:36', 'hasan66@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:42:36', 'niloofar@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-22 15:33:19', 'mary78@foofle.com', 1, 0),
('vahi75@foofle.com', '2020-06-18 18:42:40', 'newsha@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:40', 'royaaaaa@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:42:40', 'hasan66@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:42:40', 'niloofar@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:46:07', 'newsha@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:46:07', 'niloofar@foofle.com', 0, 0),
('vahi75@foofle.com', '2020-06-18 18:46:07', 'hasan66@foofle.com', 0, 1),
('vahi75@foofle.com', '2020-06-18 18:46:07', 'royaaaaa@foofle.com', 0, 1),
('tara77@foofle.com', '2020-06-22 15:37:57', 'newsha@foofle.com', 0, 0),
('tara77@foofle.com', '2020-06-22 15:37:57', 'sarar@foofle.com', 0, 0),
('tara77@foofle.com', '2020-06-22 15:37:57', 'vahi75@foofle.com', 0, 0),
('tara77@foofle.com', '2020-06-22 15:37:57', 'niloofar@foofle.com', 0, 1),
('tara77@foofle.com', '2020-06-22 15:37:57', 'royaaaaa@foofle.com', 0, 1),
('tara77@foofle.com', '2020-06-22 15:37:57', 'mary78@foofle.com', 0, 1),
('k1shah@foofle.com', '2020-06-22 16:39:29', 'tara77@foofle.com', 1, 0),
('k1shah@foofle.com', '2020-06-22 16:16:17', 'newsha@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 16:16:17', 'royaaaaa@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 16:16:17', 'sarar@foofle.com', 0, 1),
('k1shah@foofle.com', '2020-06-22 16:16:17', 'vahi75@foofle.com', 0, 1),
('tara77@foofle.com', '2020-06-22 16:48:33', 'k1shah@foofle.com', 0, 0),
('tara77@foofle.com', '2020-06-22 17:25:11', 'newsha@foofle.com', 0, 0),
('tara77@foofle.com', '2020-06-22 17:28:19', 'k1shah@foofle.com', 1, 0),
('tara77@foofle.com', '2020-06-22 17:25:11', 'royaaaaa@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 17:46:47', 'newsha@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 17:46:48', 'royaaaaa@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 17:46:48', 'tara77@foofle.com', 0, 0),
('k1shah@foofle.com', '2020-06-22 17:49:57', 'tara77@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:03:52', 'tara77@foofle.com', 1, 0),
('rojin88@foofle.com', '2020-06-22 18:03:53', 'k1shah@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:03:53', 'newsha@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:17:40', 'tara77@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:17:40', 'newsha@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:17:40', 'royaaaaa@foofle.com', 0, 0),
('rojin88@foofle.com', '2020-06-22 18:17:40', 'k1shah@foofle.com', 0, 1);

--
-- Triggers `emailreceiver`
--
DELIMITER $$
CREATE TRIGGER `recive_email` AFTER INSERT ON `emailreceiver` FOR EACH ROW begin
SET @receiveEmail = (Select CONCAT ("you have a new email from:  ",new.sender));

set @receiverUsername  = (SELECT TRIM('@foofle.com' FROM  new.receiver) );

insert into news(text,account,time)
values(@receiveEmail,@receiverUsername,CURRENT_TIME());
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `user` varchar(20) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `logs`
--

INSERT INTO `logs` (`user`, `time`) VALUES
('hoda', '2020-06-12 19:49:09'),
('mary78', '2020-06-18 08:07:04'),
('mary78', '2020-06-18 08:14:57'),
('mary78', '2020-06-18 08:19:09'),
('mary78', '2020-06-18 12:40:53'),
('vahi75', '2020-06-18 17:05:02'),
('mary78', '2020-06-18 17:13:24'),
('niloofar', '2020-06-18 18:34:38'),
('vahi75', '2020-06-18 18:38:10'),
('mary78', '2020-06-18 19:12:56'),
('tara77', '2020-06-22 15:35:27'),
('k1shah', '2020-06-22 16:15:14'),
('tara77', '2020-06-22 16:19:19'),
('k1shah', '2020-06-22 16:48:54'),
('tara77', '2020-06-22 16:49:45'),
('k1shah', '2020-06-22 16:51:13'),
('tara77', '2020-06-22 17:00:12'),
('k1shah', '2020-06-22 17:27:05'),
('k1shah', '2020-06-22 17:48:01'),
('tara77', '2020-06-22 17:50:14'),
('k1shah', '2020-06-22 17:50:34'),
('tara77', '2020-06-22 17:53:29'),
('rojin88', '2020-06-22 18:03:26'),
('tara77', '2020-06-22 18:04:33'),
('rojin88', '2020-06-22 18:08:08'),
('tara77', '2020-06-22 18:18:18'),
('rojin88', '2020-06-22 18:21:53'),
('tara77', '2020-06-22 18:22:38');

--
-- Triggers `logs`
--
DELIMITER $$
CREATE TRIGGER `login_news` AFTER INSERT ON `logs` FOR EACH ROW insert into news(text,account,time)
values('User logged in successfully',new.user,CURRENT_TIME())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `news`
--

CREATE TABLE `news` (
  `text` varchar(200) NOT NULL,
  `account` varchar(20) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `news`
--

INSERT INTO `news` (`text`, `account`, `time`) VALUES
('0', 'royaaaaa', '2020-06-13 15:00:55'),
('User signed up successfully', 'hgnvjf', '2020-06-13 15:30:42'),
('0', 'royaaaaa', '2020-06-16 11:24:12'),
('0', 'newsha', '2020-06-16 11:24:34'),
('0', 'newsha', '2020-06-16 11:24:52'),
('0', 'royaaaaa', '2020-06-16 11:25:07'),
('0', 'sarar', '2020-06-16 11:27:43'),
('0', 'newsha', '2020-06-16 11:39:48'),
('0', 'sarar', '2020-06-16 11:40:29'),
('0', 'sarar', '2020-06-16 11:42:38'),
('0', 'newsha', '2020-06-16 11:46:32'),
('0', 'royaaaaa', '2020-06-16 11:46:51'),
('royaaaaarequested to view your profile ', 'newsha', '2020-06-16 16:12:01'),
('newsha requested to view your profile ', 'royaaaaa', '2020-06-16 16:14:32'),
('newsha requested to view your profile but didn\'t have access to it ', 'royaaaaa', '2020-06-16 16:26:07'),
('you have a new email from:  royaaaaa @foofle.com', 'newsha @foofle.com', '2020-06-17 08:10:23'),
('you have a new email from:  royaaaaa @foofle.com', 'hoda @foofle.com', '2020-06-17 08:10:23'),
('you have a new email from:  royaaaaa @foofle.com', 'sarar @foofle.com', '2020-06-17 08:10:23'),
('you have a new email from:  newsha @foofle.com', 'royaaaaa @foofle.com', '2020-06-17 08:21:39'),
('you have a new email from:  newsha @foofle.com', 'tina1 @foofle.com', '2020-06-17 08:21:39'),
('you have a new email from:  newsha @foofle.com', 'sarar @foofle.com', '2020-06-17 08:21:39'),
('you have a new email from:  newsha @foofle.com', 'newsha ', '2020-06-17 08:25:06'),
('you have a new email from:  newsha @foofle.com', 'royaaaaa ', '2020-06-17 08:25:06'),
('you have a new email from:  newsha @foofle.com', 'sarar ', '2020-06-17 08:25:07'),
('You have successfully deleted an email from: royaaaaa', 'newsha', '2020-06-17 13:51:44'),
('you have a new email from:  newsha @foofle.com', 'royaaaaa ', '2020-06-17 14:52:59'),
('you have a new email from:  newsha @foofle.com', 'sarar ', '2020-06-17 14:52:59'),
('you have a new email from:  newsha @foofle.com', 'royaaaaa ', '2020-06-17 14:56:44'),
('you have a new email from:  newsha @foofle.com', 'tina1 ', '2020-06-17 14:56:44'),
('you have a new email from:  newsha @foofle.com', 'sarar ', '2020-06-17 14:56:44'),
('you have a new email from:  newsha @foofle.com', 'newsha ', '2020-06-17 14:56:44'),
('User signed up successfully', 'ahmad123', '2020-06-17 22:34:48'),
('User signed up successfully', 'hadi34', '2020-06-17 22:36:11'),
('User signed up successfully', 'mary78', '2020-06-18 08:06:41'),
('User logged in successfully', 'mary78', '2020-06-18 08:07:04'),
('User logged in successfully', 'mary78', '2020-06-18 08:14:57'),
('User logged in successfully', 'mary78', '2020-06-18 08:19:09'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 11:50:31'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:00:25'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:01:30'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:03:25'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:23:56'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:26:55'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:30:08'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:30:49'),
('hasan66 requested to view your profile and had access to it ', 'Newsha', '2020-06-18 12:31:30'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:32:05'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:33:42'),
('hasan66 requested to view your profile and had access to it ', 'royaaaaa', '2020-06-18 12:40:10'),
('User logged in successfully', 'mary78', '2020-06-18 12:40:53'),
('mary78 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:44:53'),
('hasan66 requested to view your profile and had access to it ', 'newsha', '2020-06-18 12:52:06'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 14:35:56'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 14:35:56'),
('you have a new email from:  mary78 @foofle.com', 'mary78', '2020-06-18 14:35:56'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 15:26:52'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 15:27:44'),
('you have a new email from:  mary78 @foofle.com', 'mary78', '2020-06-18 15:27:44'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 15:30:52'),
('you have a new email from:  mary78 @foofle.com', 'sarar', '2020-06-18 15:30:52'),
('you have a new email from:  mary78 @foofle.com', 'newsha', '2020-06-18 15:59:34'),
('you have a new email from:  mary78 @foofle.com', 'sarar', '2020-06-18 15:59:34'),
('you have a new email from:  mary78 @foofle.com', 'mary78', '2020-06-18 15:59:34'),
('User signed up successfully', 'vahi75', '2020-06-18 17:04:44'),
('User logged in successfully', 'vahi75', '2020-06-18 17:05:02'),
('vahi75 requested to view your profile and had access to it ', 'mary78', '2020-06-18 17:05:55'),
('you have successfully edit your account', 'vahi75', '2020-06-18 17:07:08'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 17:12:53'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 17:12:54'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 17:12:54'),
('User logged in successfully', 'mary78', '2020-06-18 17:13:24'),
('you have a new email from:  mary78@foofle.com', 'mary78', '2020-06-18 17:15:00'),
('you have a new email from:  mary78@foofle.com', 'newsha', '2020-06-18 17:15:00'),
('you have a new email from:  mary78@foofle.com', 'royaaaaa', '2020-06-18 17:15:00'),
('you have a new email from:  mary78@foofle.com', 'vahi75', '2020-06-18 17:15:00'),
('User signed up successfully', 'hasan66', '2020-06-18 18:31:52'),
('User signed up successfully', 'niloofar', '2020-06-18 18:34:21'),
('User logged in successfully', 'niloofar', '2020-06-18 18:34:38'),
('you have a new email from:  niloofar@foofle.com', 'mary78', '2020-06-18 18:35:40'),
('you have a new email from:  niloofar@foofle.com', 'hasan66', '2020-06-18 18:35:40'),
('you have a new email from:  niloofar@foofle.com', 'niloofar', '2020-06-18 18:35:40'),
('you have a new email from:  niloofar@foofle.com', 'mary78', '2020-06-18 18:37:43'),
('you have a new email from:  niloofar@foofle.com', 'vahi75', '2020-06-18 18:37:43'),
('you have a new email from:  niloofar@foofle.com', 'hasan66', '2020-06-18 18:37:43'),
('you have a new email from:  niloofar@foofle.com', 'niloofar', '2020-06-18 18:37:43'),
('User logged in successfully', 'vahi75', '2020-06-18 18:38:10'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 18:39:12'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 18:39:12'),
('you have a new email from:  vahi75@foofle.com', 'niloofar', '2020-06-18 18:39:12'),
('you have a new email from:  vahi75@foofle.com', 'hasan66', '2020-06-18 18:39:12'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 18:39:12'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 18:42:05'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 18:42:06'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 18:42:07'),
('you have a new email from:  vahi75@foofle.com', 'hasan66', '2020-06-18 18:42:07'),
('you have a new email from:  vahi75@foofle.com', 'niloofar', '2020-06-18 18:42:07'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 18:42:36'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 18:42:36'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 18:42:36'),
('you have a new email from:  vahi75@foofle.com', 'hasan66', '2020-06-18 18:42:36'),
('you have a new email from:  vahi75@foofle.com', 'niloofar', '2020-06-18 18:42:36'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 18:42:40'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 18:42:40'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 18:42:40'),
('you have a new email from:  vahi75@foofle.com', 'hasan66', '2020-06-18 18:42:40'),
('you have a new email from:  vahi75@foofle.com', 'niloofar', '2020-06-18 18:42:40'),
('you have a new email from:  vahi75@foofle.com', 'newsha', '2020-06-18 18:46:07'),
('you have a new email from:  vahi75@foofle.com', 'mary78', '2020-06-18 18:46:07'),
('you have a new email from:  vahi75@foofle.com', 'niloofar', '2020-06-18 18:46:07'),
('you have a new email from:  vahi75@foofle.com', 'vahi75', '2020-06-18 18:46:07'),
('you have a new email from:  vahi75@foofle.com', 'hasan66', '2020-06-18 18:46:07'),
('you have a new email from:  vahi75@foofle.com', 'royaaaaa', '2020-06-18 18:46:07'),
('User logged in successfully', 'mary78', '2020-06-18 19:12:56'),
('You have successfully deleted an email from: vahi75', 'mary78', '2020-06-18 19:13:20'),
('User signed up successfully', 'tara77', '2020-06-22 15:35:12'),
('User logged in successfully', 'tara77', '2020-06-22 15:35:27'),
('you have a new email from:  tara77@foofle.com', 'newsha', '2020-06-22 15:37:57'),
('you have a new email from:  tara77@foofle.com', 'sarar', '2020-06-22 15:37:57'),
('you have a new email from:  tara77@foofle.com', 'vahi75', '2020-06-22 15:37:57'),
('you have a new email from:  tara77@foofle.com', 'niloofar', '2020-06-22 15:37:57'),
('you have a new email from:  tara77@foofle.com', 'royaaaaa', '2020-06-22 15:37:57'),
('you have a new email from:  tara77@foofle.com', 'mary78', '2020-06-22 15:37:57'),
('You have successfully deleted an email which was sent in: 2020-06-22 20:07:57', 'tara77', '2020-06-22 15:42:18'),
('User signed up successfully', 'k1shah', '2020-06-22 16:14:53'),
('User logged in successfully', 'k1shah', '2020-06-22 16:15:14'),
('you have a new email from:  k1shah@foofle.com', 'tara77', '2020-06-22 16:16:17'),
('you have a new email from:  k1shah@foofle.com', 'newsha', '2020-06-22 16:16:17'),
('you have a new email from:  k1shah@foofle.com', 'royaaaaa', '2020-06-22 16:16:17'),
('you have a new email from:  k1shah@foofle.com', 'sarar', '2020-06-22 16:16:17'),
('you have a new email from:  k1shah@foofle.com', 'vahi75', '2020-06-22 16:16:17'),
('You have successfully deleted an email which was sent in: 2020-06-22 20:46:17', 'k1shah', '2020-06-22 16:18:29'),
('User logged in successfully', 'tara77', '2020-06-22 16:19:19'),
('you have a new email from:  tara77@foofle.com', 'k1shah', '2020-06-22 16:48:33'),
('User logged in successfully', 'k1shah', '2020-06-22 16:48:54'),
('User logged in successfully', 'tara77', '2020-06-22 16:49:45'),
('You have successfully deleted an email which was sent in: 2020-06-22 21:18:33', 'tara77', '2020-06-22 16:50:38'),
('User logged in successfully', 'k1shah', '2020-06-22 16:51:13'),
('User logged in successfully', 'tara77', '2020-06-22 17:00:12'),
('you have a new email from:  tara77@foofle.com', 'newsha', '2020-06-22 17:25:11'),
('you have a new email from:  tara77@foofle.com', 'k1shah', '2020-06-22 17:25:11'),
('you have a new email from:  tara77@foofle.com', 'royaaaaa', '2020-06-22 17:25:11'),
('User logged in successfully', 'k1shah', '2020-06-22 17:27:05'),
('you have a new email from:  k1shah@foofle.com', 'newsha', '2020-06-22 17:46:47'),
('you have a new email from:  k1shah@foofle.com', 'royaaaaa', '2020-06-22 17:46:48'),
('you have a new email from:  k1shah@foofle.com', 'tara77', '2020-06-22 17:46:48'),
('User logged in successfully', 'k1shah', '2020-06-22 17:48:01'),
('you have a new email from:  k1shah@foofle.com', 'tara77', '2020-06-22 17:49:57'),
('User logged in successfully', 'tara77', '2020-06-22 17:50:14'),
('User logged in successfully', 'k1shah', '2020-06-22 17:50:34'),
('You have successfully deleted an email which was sent in: 2020-06-22 22:19:57', 'k1shah', '2020-06-22 17:52:28'),
('User logged in successfully', 'tara77', '2020-06-22 17:53:29'),
('h_shahbodagh requested to view your profile and had access to it ', 'sarar', '2020-06-22 17:58:56'),
('you have a new email from:  h_shahbodagh@foofle.', 'tara77', '2020-06-22 18:00:32'),
('you have a new email from:  h_shahbodagh@foofle.', 'newsha', '2020-06-22 18:00:32'),
('you have a new email from:  h_shahbodagh@foofle.', 'royaaaaa', '2020-06-22 18:00:33'),
('User signed up successfully', 'rojin88', '2020-06-22 18:02:56'),
('User logged in successfully', 'rojin88', '2020-06-22 18:03:26'),
('you have a new email from:  rojin88@foofle.com', 'tara77', '2020-06-22 18:03:52'),
('you have a new email from:  rojin88@foofle.com', 'k1shah', '2020-06-22 18:03:53'),
('you have a new email from:  rojin88@foofle.com', 'newsha', '2020-06-22 18:03:53'),
('User logged in successfully', 'tara77', '2020-06-22 18:04:33'),
('User logged in successfully', 'rojin88', '2020-06-22 18:08:08'),
('You have successfully deleted an email which was sent in: 2020-06-22 22:33:52', 'rojin88', '2020-06-22 18:16:33'),
('you have a new email from:  rojin88@foofle.com', 'tara77', '2020-06-22 18:17:40'),
('you have a new email from:  rojin88@foofle.com', 'newsha', '2020-06-22 18:17:40'),
('you have a new email from:  rojin88@foofle.com', 'royaaaaa', '2020-06-22 18:17:40'),
('you have a new email from:  rojin88@foofle.com', 'k1shah', '2020-06-22 18:17:40'),
('User logged in successfully', 'tara77', '2020-06-22 18:18:18'),
('User logged in successfully', 'rojin88', '2020-06-22 18:21:53'),
('You have successfully deleted an email which was sent in: 2020-06-22 22:47:40', 'rojin88', '2020-06-22 18:22:06'),
('User logged in successfully', 'tara77', '2020-06-22 18:22:38');

-- --------------------------------------------------------

--
-- Stand-in structure for view `personal_information`
-- (See below for the actual view)
--
CREATE TABLE `personal_information` (
`firstName` varchar(20)
,`lastName` varchar(20)
,`alias` varchar(20)
,`address` varchar(100)
,`birthDate` varchar(10)
,`phone` char(11)
,`nationalId` varchar(20)
,`username` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `systemic_information`
-- (See below for the actual view)
--
CREATE TABLE `systemic_information` (
`username` varchar(20)
,`password` varchar(40)
,`creationDate` timestamp
,`accountPhone` char(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `firstName` varchar(20) NOT NULL,
  `lastName` varchar(20) NOT NULL,
  `alias` varchar(20) NOT NULL,
  `address` varchar(100) NOT NULL,
  `birthDate` varchar(10) NOT NULL,
  `phone` char(11) NOT NULL,
  `nationalId` varchar(20) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(40) NOT NULL,
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `accountPhone` char(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`firstName`, `lastName`, `alias`, `address`, `birthDate`, `phone`, `nationalId`, `username`, `password`, `creationDate`, `accountPhone`) VALUES
('Ahmad', 'Ahmadi', 'Ahmad', 'trfcujgvjhg', '33.4.5', '0987543', '6576576', 'ahmad123', 'e10adc3949ba59abbe56e057f20f883e', '2020-06-17 22:34:48', '0987654'),
('hadi', 'nazari', 'hadi', 'ldncajlkcnlqin', '67.11.4', '098765', '2266764453', 'hadi34', 'fcea920f7412b5da7be0cf42b8c93759', '2020-06-17 22:36:11', '0987654'),
('hasan', 'hasani', 'hasani', 'kjhgfdsdfghjk', '66.3.11', '0987654', '98767890', 'hasan66', '6c44e5cd17f0019c64b042e4a745412a', '2020-06-18 18:31:52', '0987654'),
('f1', 'l1', 'f1', 'jknkjbkjbkjbkjbkj', '67.3.5', '098765432', '0022857739', 'hgnvjf', '3354045a397621cd92406f1f98cde292', '2020-06-13 15:30:42', '0987612534'),
('hoda', 'hadi', 'hh', 'ktgfiyfyi', '81.12.1', '09147852', '7896541', 'hoda', '6ebe76c9fb411be97b3b0d48b791a7c9', '2020-06-12 17:05:39', '09787852414'),
('k1', 'shai', 'kk', 'grfdcvkjhgjyfc', '39.1.1', '098765', '786787', 'k1shah', 'e10adc3949ba59abbe56e057f20f883e', '2020-06-22 16:14:53', '091235678'),
('Maryam', 'Adibi', 'mary', 'jdhfbvjeduwhfjfk', '78.6.31', '0987654321', '234567654', 'mary78', 'e10adc3949ba59abbe56e057f20f883e', '2020-06-18 08:06:41', '098765432'),
('Newsha', 'Shahbodagh', 'New', 'jkhnsduhcbiab', '78.6.24', '098765432', '09876543', 'newsha', 'fc7588193f4e8e5b919d203d2734c58b', '2020-06-11 19:30:00', '0365412854'),
('Niloofar', 'Ahmadi', 'Niloo', 'hkjbkuvjhbljh', '76.5.23', '0987659876', '098765r', 'niloofar', '71b3b26aaa319e0cdf6fdb8429c112b0', '2020-06-18 18:34:21', '09876543'),
('rojin', 'salami', 'rojj', 'sdfhj', '88.2.1', '09876543', '45678', 'rojin88', 'd7251d9b060e8ee32f8a97b908478a3a', '2020-06-22 18:02:56', '09125546874'),
('roya', 'badiiii', 'kjfdjkc', 'lhwdlcnaljsd', '22.22.44', '0987654', '345678', 'royaaaaa', '9e079d89d66d33457fbd0fa039b24deb', '2020-06-13 15:00:55', '0912345678'),
('sara', 'rahimi', 'ss', 'dfkjvn kzjnvfk', '72.4.6', '09437762746', '00332433', 'sarar', 'e10adc3949ba59abbe56', '2020-06-12 16:21:57', '09876543'),
('tara', 'talai', 'tata', 'rtyuiop[\';lkjh', '77.4.12', '09876543', '965923', 'tara77', '4607e782c4d86fd5364d7e4508bb10d9', '2020-06-22 15:35:12', '09785523645'),
('tina', 'mohammadi', 'tt', 'kjzhsvkhsbdk', '88.1.3', '098767', '34567', 'tina1', 'e10adc3949ba59abbe56', '2020-06-11 19:30:00', '09876543'),
('vahid', 'vahidi', 'vah', 'kjhgfghjkl', '76.12.23', '09876543', '878432', 'vahi75', '124bd1296bec0d9d93c7b52a71ad8d5b', '2020-06-18 17:04:44', '098765');

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `sign_up_news` AFTER INSERT ON `user` FOR EACH ROW insert into news(text,account,time)
values('User signed up successfully',new.username,CURRENT_TIME())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `personal_information`
--
DROP TABLE IF EXISTS `personal_information`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `personal_information`  AS  select `user`.`firstName` AS `firstName`,`user`.`lastName` AS `lastName`,`user`.`alias` AS `alias`,`user`.`address` AS `address`,`user`.`birthDate` AS `birthDate`,`user`.`phone` AS `phone`,`user`.`nationalId` AS `nationalId`,`user`.`username` AS `username` from `user` ;

-- --------------------------------------------------------

--
-- Structure for view `systemic_information`
--
DROP TABLE IF EXISTS `systemic_information`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `systemic_information`  AS  select `user`.`username` AS `username`,`user`.`password` AS `password`,`user`.`creationDate` AS `creationDate`,`user`.`accountPhone` AS `accountPhone` from `user` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `email`
--
ALTER TABLE `email`
  ADD PRIMARY KEY (`sender`,`time`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `nationalId` (`nationalId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
