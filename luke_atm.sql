CREATE TABLE transactions (
  id int(11) NOT NULL AUTO_INCREMENT,
  identifier varchar(40) NOT NULL,
  comment tinytext DEFAULT NULL,
  amount int(11) NOT NULL,
  recipient varchar(40) DEFAULT NULL,
  type tinytext DEFAULT NULL,
  PRIMARY KEY (id)
)